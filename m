Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3684D6B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 19:41:55 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
Date: Mon, 19 Oct 2009 01:41:49 +0200
References: <hbd4dk$5ac$1@ultimate100.geggus.net> <200910172230.13162.elendil@planet.nl> <hbd9v8$7rf$1@ultimate100.geggus.net>
In-reply-To: <hbd9v8$7rf$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910190141.50752.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

(Sven: For kernel mailing lists please always do a "reply to all".
Although some other communities do not want that, it is standard for the 
kernel community. It is needed because otherwise, with the huge amount of 
traffic on the linux-kernel list, people are too likely to miss replies.)

Sven Geggus wrote:
> Frans Pop <elendil@planet.nl> wrote:
> 
>> What is the _exact_ command sequence you use to reproduce it? I already
>> have a testcase, but a second test case, or a simpler one, may be
>> useful. 
> 
> Not a particular easy testcase. This is what I did:
> 
> On the crashing machine with the dm-encrypted xfs volume:
> ionice -c 3 socat TCP4-LISTEN:5555 - >backup.tar
> 
> On the source machine:
> tar cv dir |socat - TCP4:targetmachine:5555
> 
> You will certainly not need to use tar.
> 
> socat /dev/zero TCP4:targetmachine:5555 should work as well.
> 
> I don't know if TCP traffic is really needed probably it is.

Thanks.

In the mean time I've been able to trace the culprit. Could you please try 
if reverting 373c0a7e + 8aa7e847 [1] on top of 2.6.31 fixes the issue for 
you?

Cheers,
FJP

[1] The first commit is a build fix for the second.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
