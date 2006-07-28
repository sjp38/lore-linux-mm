Date: Fri, 28 Jul 2006 00:44:10 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 0/9] oom: various fixes and improvements for 2.6.18-rc2
Message-Id: <20060728004410.63bba676.akpm@osdl.org>
In-Reply-To: <20060515210529.30275.74992.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jul 2006 09:20:44 +0200 (CEST)
Nick Piggin <npiggin@suse.de> wrote:

> These are some various OOM killer fixes that I have accumulated. Some of
> the more important ones are in SLES10, and were developed in response to
> issues coming up in stress testing.
> 
> The other small fixes haven't been widely tested, but they're issues I
> spotted when working in this area.
> 
> Comments?

They all look good to me (although I haven't grappled with the cpuset ones
yet).

The "oom: reclaim_mapped on oom" one is kinda funny.  Back in 2.5.early I
decided that we were probably donig too much scanning before declaring oom
so I randomly reduced it by a factor of, iirc, four.  Under the assumption
that someone would start hitting early ooms and would get in there and tune
it for real.  It took five years ;)

Which of these patches have been well-tested and which are the more
speculative ones?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
