Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CAE296B01EF
	for <linux-mm@kvack.org>; Sat, 17 Apr 2010 03:07:34 -0400 (EDT)
Received: from [109.160.183.100] (port=19825 helo=borjch.rnk)
	by gator1121.hostgator.com with esmtpa (Exim 4.69)
	(envelope-from <buildroot@browserseal.com>)
	id 1O327n-000411-I6
	for linux-mm@kvack.org; Sat, 17 Apr 2010 02:07:31 -0500
Message-ID: <4BC95E2E.5040801@browserseal.com>
Date: Sat, 17 Apr 2010 10:07:26 +0300
From: Sasha Sirotkin <buildroot@browserseal.com>
MIME-Version: 1.0
Subject: question about COW
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There is an "early COW" mechanism in __do_fault() which, if the page is 
not present and the fault is FAULT_PAGE_WRITE goes ahead and copies the 
page in order to prevent the next exception.

The question - why the code in __do_fault() does not decrease the shared 
map count of the old page as do_wp_page does ? And while we are at it, 
while this "early COW" code is much more simple than do_wp_page()?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
