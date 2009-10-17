Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9122C6B004F
	for <linux-mm@kvack.org>; Sat, 17 Oct 2009 16:30:15 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
Date: Sat, 17 Oct 2009 22:30:11 +0200
References: <hbd4dk$5ac$1@ultimate100.geggus.net>
In-reply-To: <hbd4dk$5ac$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910172230.13162.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello Sven,

Sven Geggus wrote:
> I can reproducible crash my machine by writing bulk data from a
> socket to an encrypted partition. It always crashes after a few
> Gigabytes have been written.
> 
> The Partition in charge is using dm-crypt+xfs filesystem.

This is without any doubt related to an issue that's already being 
investigated. I have to warn you that the thread is very long:

http://thread.gmane.org/gmane.linux.kernel/896714

What is the _exact_ command sequence you use to reproduce it? I already 
have a testcase, but a second test case, or a simpler one, may be useful.

In all cases reported so far, and also in your case, networking is involved 
in the actual allocation errors.

It would also be useful if you could try to bisect the issue independently. 
For me bisection has proven difficult because the symptoms change 
between .30 and .31. The suspicion is that more than one change is 
involved in the regression.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
