Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KaBtm-0006Wa-VI
	for linux-mm@kvack.org; Mon, 01 Sep 2008 16:05:02 +0000
Received: from 87.114.164.140.plusnet.thn-ag1.dyn.plus.net ([87.114.164.140])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 01 Sep 2008 16:05:02 +0000
Received: from sitsofe by 87.114.164.140.plusnet.thn-ag1.dyn.plus.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 01 Sep 2008 16:05:02 +0000
From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Anonymous memory on machines without swap
Date: Mon, 01 Sep 2008 16:59:39 +0100
Message-ID: <g9h3h5$gkb$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Is it worth having the anonymous memory option turned on in kconfig when
using the kernel on a machine which has no swap/swapfiles? Does it
improve memory decisions in some secret way (even though there is no
swap available) or would it just be completely redundant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
