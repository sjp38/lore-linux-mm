Subject: Re: [PATCH 04 of 16] serialize oom killer
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <baa866fedc79cb333b90.1181332982@v2.random>
References: <baa866fedc79cb333b90.1181332982@v2.random>
Content-Type: text/plain
Date: Sat, 09 Jun 2007 08:43:47 +0200
Message-Id: <1181371427.7348.293.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-08 at 22:03 +0200, Andrea Arcangeli wrote:
> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1181332960 -7200
> # Node ID baa866fedc79cb333b90004da2730715c145f1d5
> # Parent  532a5f712848ee75d827bfe233b9364a709e1fc1
> serialize oom killer
> 
> It's risky and useless to run two oom killers in parallel, let serialize it to
> reduce the probability of spurious oom-killage.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -400,12 +400,15 @@ void out_of_memory(struct zonelist *zone
>  	unsigned long points = 0;
>  	unsigned long freed = 0;
>  	int constraint;
> +	static DECLARE_MUTEX(OOM_lock);

I thought we depricated that construct in favour of DEFINE_MUTEX. Also,
putting it in a function like so is a little icky IMHO.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
