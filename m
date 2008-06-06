Subject: Re: [patch 0/7] speculative page references, lockless pagecache,
	lockless gup
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080605094300.295184000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 23:32:44 +0200
Message-Id: <1212787964.19205.74.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-06-05 at 19:43 +1000, npiggin@suse.de wrote:
> Hi,
> 
> I've decided to submit the speculative page references patch to get merged.
> I think I've now got enough reasons to get it merged. Well... I always
> thought I did, I just didn't think anyone else thought I did. If you know
> what I mean.
> 
> cc'ing the powerpc guys specifically because everyone else who probably
> cares should be on linux-mm...
> 
> So speculative page references are required to support lockless pagecache and
> lockless get_user_pages (on architectures that can't use the x86 trick). Other
> uses for speculative page references could also pop up, it is a pretty useful
> concept. Doesn't need to be pagecache pages either.

For patches 1-5

Reviewed-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
