Date: Thu, 25 Mar 2004 11:17:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.5-rc2-mm3 blizzard of "bad: scheduling while atomic" with
 PREEMPT
Message-Id: <20040325111700.432aff4a.akpm@osdl.org>
In-Reply-To: <20040325190612.GA12383@elte.hu>
References: <1080237733.2269.31.camel@spc0.esa.lanl.gov>
	<20040325103506.19129deb.akpm@osdl.org>
	<20040325190612.GA12383@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: elenstev@mesatop.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> wrote:
>
>  ok, this replacement patch should fix it:
> 
>    http://redhat.com/~mingo/scheduler-patches/sched-2.6.5-rc2-mm2-A5

Thanks, I swapped out the old one for this.

There are rejects against ppc64 files.  But I dropped the ppc64
sched-domain patches from rc2-mm2, so I'm not sure what's going on there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
