Date: Tue, 13 May 2003 17:15:36 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm4
Message-ID: <20030514001536.GE8978@holomorphy.com>
References: <20030512225504.4baca409.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030512225504.4baca409.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 12, 2003 at 10:55:04PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm4/
> Lots of small things.
> thread-info-in-task_struct.patch
>   allow thread_info to be allocated as part of task_struct

AIUI the task_cache is meant to prevent certain task_t (dear gawd I
can't stand those _struct suffixes) refcounting pathologies because
the task_t has its final put done by the task itself or something
on that order, so it may be better for ia64 to adapt the task_cache to
their purposes instead of wiping it entirely. Also, making the
task_cache treatment uniform apart from its declaration would allow the
#ifdef to be shoved in a header.

Alternatively, one could alter the timing of the final put on a task_t
so as to handle it similarly to the final mmput() (though here, too it
might be more sightly to #ifdef the necessary bits in headers).

I think there are already outstanding task_t refcounting bugs, so I'm
not entirely sure where we stand wrt. changing final put mechanics.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
