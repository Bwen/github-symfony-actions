<?php

namespace App\Traits;

use Exception;
use Github\Client as GitHub;

trait GithubCommand
{
    protected GitHub $github;
    private string $org;
    private string $repo;

    /**
     * @required
     */
    public function setGitHub(string $githubOrg, string $githubRepo, GitHub $github): void
    {
        $this->github = $github;
        $this->org = $githubOrg;
        $this->repo = $githubRepo;
    }

    protected function pullRequest(string $function, array $args): array
    {
        $pr = $this->github->pullRequest();
        if (!method_exists($pr, $function)) {
            throw new Exception('Github\Client: Invalid function for pull_request');
        }

        return $pr->{$function}($this->org, $this->repo, ...$args);
    }
}
