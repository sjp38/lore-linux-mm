Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D09DA6B020A
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 18:08:02 -0400 (EDT)
Received: from cpe00142a336e11-cm001ac318e826.cpe.net.cable.rogers.com ([174.113.191.234] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1NyXz7-0004f6-Sv
	for linux-mm@kvack.org; Sun, 04 Apr 2010 18:08:01 -0400
Date: Sun, 4 Apr 2010 18:05:48 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: mm/ routines:  to EXPORT or not to EXPORT
Message-ID: <alpine.LFD.2.00.1004041802210.5133@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  sorry, i didn't mean to start such an animated discussion, but from
a newbie perspective (someone who's just recently started to peruse
the mm/code), it seems like there are some real inconsistencies.

  for instance, in filemap.c, we have:

EXPORT_SYMBOL(add_to_page_cache_locked);

curiously, though, what seems to be the converse routine,
remove_from_page_cache(), is *not* exported.  that just seems odd but
maybe i just have to read further.

rday
--

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
