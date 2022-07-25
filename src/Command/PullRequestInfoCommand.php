<?php

namespace App\Command;

use App\Traits\GithubCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Exception\RuntimeException;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class PullRequestInfoCommand extends Command
{
    use GithubCommand;

    protected function configure(): void
    {
        $this
            ->setName('pr:info')
            ->addArgument('pr-id', InputArgument::REQUIRED, 'Pull Request ID')
            ->setDescription('Initial command as demonstration')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $prId = $input->getArgument('pr-id');
        if (0 === (int)$prId) {
            throw new RuntimeException("Invalid Pull Request ID: $prId");
        }

        try {
            $prInfo = $this->pullRequest('show', [2]);
        } catch (RuntimeException $e) {
            $output->writeln('::set-output name=error::' . $e->getMessage());
            $output->writeln("\n".$e->getMessage());
            return self::FAILURE;
        }

        $output->writeln(print_r($prInfo['title'], true));
        return self::SUCCESS;
    }
}
