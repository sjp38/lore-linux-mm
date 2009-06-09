Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 832756B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:03:20 -0400 (EDT)
Date: Tue, 9 Jun 2009 14:13:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] proc.txt: Update kernel filesystem/proc.txt
 documentation
Message-Id: <20090609141323.aae795a9.akpm@linux-foundation.org>
In-Reply-To: <1244580807.30614.10.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244543758.13948.5.camel@wall-e>
	<20090609123641.f4733d8b.akpm@linux-foundation.org>
	<1244580807.30614.10.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 09 Jun 2009 22:53:27 +0200
Stefani Seibold <stefani@seibold.net> wrote:

> Am Dienstag, den 09.06.2009, 12:36 -0700 schrieb Andrew Morton:
> > On Tue, 09 Jun 2009 12:35:58 +0200
> > Stefani Seibold <stefani@seibold.net> wrote:
> > 
> > > This is a patch against the file Documentation/filesystem/proc.txt.
> > > 
> > > It is an update for the "Process-Specific Subdirectories" to reflect 
> > > the changes till kernel 2.6.30. It also introduce the my 
> > > "provide stack information for threads".
> > 
> > Sorry, but it would be much preferable to do this as two patches.  The
> > first fixes up proc.txt and the second adds the
> > stack-information-for-threads material.
> > 
> 
> That is really frustrating. I did everything that you and ingo molnar
> had complained.
> 
> What is wrong with the "provide stack information for threads"? It is a
> very tiny patch which did not harm.
> 
> The only reason to fix and update the proc.txt was that you told me that
> this is the last thing that you miss.

It's more a procedural thing really.  We've learnt that it's best to
avoid mixing more than a single "concept" into a single patch.  For a
whole pile of reasons: reviewability, bisectability, revertability,
testability, etc.

In this case, it's unobvious which parts of the patch were specific to
the stack-information-for-threads changes and which parts were not. 
This makes it hard to review your proposed changes.

> > This is because the two changes are quite conceptually distinct, and we
> > might end up wanting to merge one chage and not the other.
> > 
> 
> Okay, if the other patch will not included than it makes no sense for me
> to get in the other.
> 
> Simple question: will you accept the thread stack info patch or not? If
> yes, i will spent the time to split proc.txt patch.
> 

It looks OK to me now.  If it passes testing and nobody has fatal
objections then yes, I expect it'll be merged in 2.6.31.

The way to organise these changes is

[patch 1/2] fix proc.txt
[patch 2/2] procfs: provide stack information for threads

The second patch will contain a small update to proc.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
