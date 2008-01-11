Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0BCrglh019210
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 07:53:42 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BCpqoF136024
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 07:51:52 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BCpqwc024744
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 07:51:52 -0500
Date: Fri, 11 Jan 2008 18:21:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch 18/19] account mlocked pages
Message-ID: <20080111125109.GC19814@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080108205939.323955454@redhat.com> <20080108210019.684039300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080108210019.684039300@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

* Rik van Riel <riel@redhat.com> [2008-01-08 15:59:57]:

The following patch is required to compile the code with
CONFIG_NORECLAIM enabled and CONFIG_NORECLAIM_MLOCK disabled.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c8ccf8f..fb08ee8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -88,6 +88,8 @@ enum zone_stat_item {
 	NR_NORECLAIM,	/*  "     "     "   "       "         */
 #ifdef CONFIG_NORECLAIM_MLOCK
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
+#else
+	NR_MLOCK=NR_ACTIVE_FILE,	/* avoid compiler errors... */
 #endif
 #else
 	NR_NORECLAIM=NR_ACTIVE_FILE,	/* avoid compiler errors in dead code */

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
