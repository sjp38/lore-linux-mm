Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C3F0B6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:38:50 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1NklPi-0007N8-69
	for linux-mm@kvack.org; Thu, 25 Feb 2010 22:38:30 +0100
Received: from 85-222-76-212.home.aster.pl ([85.222.76.212])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 22:38:30 +0100
Received: from zenblu by 85-222-76-212.home.aster.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 22:38:30 +0100
From: Zenek <zenblu@wp.pl>
Subject: Re: vmapping user pages - feasible?
Date: Thu, 25 Feb 2010 21:38:18 +0000 (UTC)
Message-ID: <hm6qka$rqp$3@dough.gmane.org>
References: <hm6l5q$rqp$1@dough.gmane.org>
	<alpine.DEB.2.00.1002251455550.18861@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010 14:58:52 -0600, Christoph Lameter wrote:

Ah, and one more question if I may:
 Can vmalloc()ed memory be swapped out? From Uderstanding the Linux 
Kernel I understand that no kernel memory can be swapped out... Can 
anything besides what have been allocated by user be swapped out?

Thank you!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
