Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 786376B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 15:35:43 -0400 (EDT)
Date: Tue, 9 Jun 2009 12:36:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] proc.txt: Update kernel filesystem/proc.txt
 documentation
Message-Id: <20090609123641.f4733d8b.akpm@linux-foundation.org>
In-Reply-To: <1244543758.13948.5.camel@wall-e>
References: <1238511505.364.61.camel@matrix>
	<20090401193135.GA12316@elte.hu>
	<1244543758.13948.5.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 09 Jun 2009 12:35:58 +0200
Stefani Seibold <stefani@seibold.net> wrote:

> This is a patch against the file Documentation/filesystem/proc.txt.
> 
> It is an update for the "Process-Specific Subdirectories" to reflect 
> the changes till kernel 2.6.30. It also introduce the my 
> "provide stack information for threads".

Sorry, but it would be much preferable to do this as two patches.  The
first fixes up proc.txt and the second adds the
stack-information-for-threads material.

This is because the two changes are quite conceptually distinct, and we
might end up wanting to merge one chage and not the other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
