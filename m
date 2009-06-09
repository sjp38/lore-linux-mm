Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B66016B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:52:08 -0400 (EDT)
Subject: Re: [patch] proc.txt: Update kernel filesystem/proc.txt
 documentation
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090609123641.f4733d8b.akpm@linux-foundation.org>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu> <1244543758.13948.5.camel@wall-e>
	 <20090609123641.f4733d8b.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 09 Jun 2009 22:53:27 +0200
Message-Id: <1244580807.30614.10.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Am Dienstag, den 09.06.2009, 12:36 -0700 schrieb Andrew Morton:
> On Tue, 09 Jun 2009 12:35:58 +0200
> Stefani Seibold <stefani@seibold.net> wrote:
> 
> > This is a patch against the file Documentation/filesystem/proc.txt.
> > 
> > It is an update for the "Process-Specific Subdirectories" to reflect 
> > the changes till kernel 2.6.30. It also introduce the my 
> > "provide stack information for threads".
> 
> Sorry, but it would be much preferable to do this as two patches.  The
> first fixes up proc.txt and the second adds the
> stack-information-for-threads material.
> 

That is really frustrating. I did everything that you and ingo molnar
had complained.

What is wrong with the "provide stack information for threads"? It is a
very tiny patch which did not harm.

The only reason to fix and update the proc.txt was that you told me that
this is the last thing that you miss.

> This is because the two changes are quite conceptually distinct, and we
> might end up wanting to merge one chage and not the other.
> 

Okay, if the other patch will not included than it makes no sense for me
to get in the other.

Simple question: will you accept the thread stack info patch or not? If
yes, i will spent the time to split proc.txt patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
