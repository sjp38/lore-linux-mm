Date: Mon, 25 Sep 2000 15:57:31 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925155650.F22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251555420.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> -		sync_page(page);
>  		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> +		sync_page(page);

> -		run_task_queue(&tq_disk);
>  		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> +		run_task_queue(&tq_disk);

these look like genuine fixes, but i dont think they can explain the hangs
i had yesterday - those were simple VM deadlocks. I dont see any deadlocks
today - but i'm running the unsafe B2 variant of the vmfixes patch. (and i
have no swapping enabled which simplifies my VM setup.)

but one of these two fixes could explain the slowdown i saw on and off for
quite some time, seeing very bad read performance occasionally. (do you
remember my sched.c tq_disc hack?)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
