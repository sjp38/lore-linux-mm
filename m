Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 9251F6B0032
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 11:23:54 -0400 (EDT)
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r6KFNq3X014556
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:23:53 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFNpUw025657
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:23:52 GMT
Received: from abhmt104.oracle.com (abhmt104.oracle.com [141.146.116.56])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFNpCN019498
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:23:51 GMT
Message-ID: <51EAAB84.6000905@oracle.com>
Date: Sat, 20 Jul 2013 23:23:48 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Fwd: [PATCH 0/2] zcache: a new start for upstream
References: <1374331018-11045-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1374331018-11045-1-git-send-email-bob.liu@oracle.com>
Content-Type: multipart/mixed;
 boundary="------------040800030806030200060107"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------040800030806030200060107
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

A extra space in my git script cause linux-mm missed!

-------- Original Message --------
Subject: [PATCH 0/2] zcache: a new start for upstream
Date: Sat, 20 Jul 2013 22:36:56 +0800
From: Bob Liu <lliubbo@gmail.com>
CC: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com,
gregkh@linuxfoundation.org, ngupta@vflare.org, minchan@kernel.org,
  konrad.wilk@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de,
  riel@redhat.com, penberg@kernel.org, akpm@linux-foundation.org,
 Bob Liu <bob.liu@oracle.com>

We already have zswap helps reducing the swap out/in IO operations by
compressing anon pages.
It has been merged into v3.11-rc1 together with the zbud allocation layer.

However there is another kind of pages(clean file pages) suitable for
compression as well. Upstream has already merged its frontend(cleancache).
Now we are lacking of a backend of cleancache as zswap to frontswap.

Furthermore, we need to balance the number of compressed anon and file
pages,
E.g. it's unfair to normal file pages if zswap pool occupies too much
memory for
the storage of compressed anon pages.

Although the current version of zcache in staging tree has already done
those
works mentioned above, the implementation is too complicated to be
merged into
upstream.

What I'm looking for is a new way for zcache towards upstream.
The first change is no more staging tree.
Second is implemented a simple cleancache backend at first, which is
based on
the zbud allocation same as zswap.

At the end, I hope we can combine the new cleancache backend with
zswap(frontswap backend), in order to have a generic in-kernel memory
compression solution in upstream.

Bob Liu (2):
  zcache: staging: %s/ZCACHE/ZCACHE_OLD
  mm: zcache: core functions added

 drivers/staging/zcache/Kconfig  |   12 +-
 drivers/staging/zcache/Makefile |    4 +-
 mm/Kconfig                      |   18 +
 mm/Makefile                     |    1 +
 mm/zcache.c                     |  840
+++++++++++++++++++++++++++++++++++++++
 5 files changed, 867 insertions(+), 8 deletions(-)
 create mode 100644 mm/zcache.c

-- 
1.7.10.4


-- 
Regards,
-Bob



--------------040800030806030200060107
Content-Type: text/plain; charset=UTF-8;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------040800030806030200060107--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
