Date: Wed, 12 Sep 2007 05:34:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09 of 24] fallback killing more tasks if tif-memdie
 doesn't go away
Message-Id: <20070912053446.e819717a.akpm@linux-foundation.org>
In-Reply-To: <20070912053022.b7d152c3.akpm@linux-foundation.org>
References: <patchbomb.1187786927@v2.random>
	<9bf6a66eab3c52327daa.1187786936@v2.random>
	<20070912053022.b7d152c3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 05:30:22 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> Something like this...
> 
> 
>  include/linux/swap.h |    1 +
>  kernel/exit.c        |   11 +++++------
>  mm/oom_kill.c        |   11 ++++++-----
>  3 files changed, 12 insertions(+), 11 deletions(-)

urgh, that caused a great mess in later patches which I can't be assed fixing
up right now.

It's really much much easier if people just get trivial stuff like this right
first time :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
