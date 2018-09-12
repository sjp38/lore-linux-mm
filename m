Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B33EF8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:39:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so1273032plb.15
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:39:24 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o18-v6si1546199pfa.15.2018.09.12.09.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 09:39:23 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w8CGdMJp195439
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:39:22 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2mc72qu8bg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:39:22 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w8CGdHec011681
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:39:18 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w8CGdH1E021945
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:39:17 GMT
From: Todd Vierling <todd.vierling@oracle.com>
Subject: linux-mm wiki drop_caches doc is incomplete
Message-ID: <01b0bc19-3326-05b9-166a-61445654a62f@oracle.com>
Date: Wed, 12 Sep 2018 12:39:17 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>

I've traced back several bad uses of drop_caches to users and bloggers
who have used this doc page as a reference:

https://linux-mm.org/Drop_Caches

Of course, *we* know that this knob is intended for benchmarking and
debugging, but many less experienced system administrators don't. To a
more green admin, "free" memory might be considered a "good" thing,
never mind the entire purpose of reclaimable caches.

As this is not an editable moinmoin page, will someone with the proper
perms please fix this page, to include the next two paragraphs from the
kernel doc where it came from?:

===

https://www.kernel.org/doc/Documentation/sysctl/vm.txt

...

This file is not a means to control the growth of the various kernel
caches (inodes, dentries, pagecache, etc...)  These objects are
automatically reclaimed by the kernel when memory is needed elsewhere on
the system.

Use of this file can cause performance problems.  Since it discards
cached objects, it may cost a significant amount of I/O and CPU to
recreate the dropped objects, especially if they were under heavy use.
Because of this, use outside of a testing or debugging environment is
not recommended.

-- 
-- Todd Vierling <todd.vierling@oracle.com> +1-770-730-4426
