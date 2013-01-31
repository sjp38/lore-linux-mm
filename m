Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0F1DB6B0002
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 03:23:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so1617182pad.36
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:23:12 -0800 (PST)
Message-ID: <1359620590.1391.5.camel@kernel>
Subject: Support variable-sized huge pages
From: Ric Mason <ric.masonn@gmail.com>
Date: Thu, 31 Jan 2013 02:23:10 -0600
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>

Hi all,

It seems that Andi's "Support more pagesizes for
MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
patch, x86 will support 2MB and 1GB huge pages. But I just see 
hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
Where is 1GB huge pages?

Regards,
Ric  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
