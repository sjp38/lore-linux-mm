Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0VIJ8UW029721
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 13:19:08 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0VIHD1F272244
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 11:17:13 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0VIJ76L017134
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 11:19:07 -0700
Subject: Re: [ckrm-tech] [PATCH 1/8] Add the __GFP_NOLRU flag
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060131023005.7915.10365.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
	 <20060131023005.7915.10365.sendpatchset@debian>
Content-Type: text/plain
Date: Tue, 31 Jan 2006 10:18:53 -0800
Message-Id: <1138731533.6424.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-31 at 11:30 +0900, KUROSAWA Takahiro wrote:
> This patch adds the __GFP_NOLRU flag.  This option should be used 
> for GFP_USER/GFP_HIGHUSER page allocations that are not maintained
> in the zone LRU lists.

Is this simply to mark pages which will never end up in the LRU?  Why is
this important?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
