Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 443826B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 04:05:37 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id b8so7921067qtj.21
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 01:05:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i185si823557qkf.277.2018.01.29.01.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 01:05:36 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0T95S2C002615
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 04:05:35 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fsuhpate9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 04:05:33 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <chandan@linux.vnet.ibm.com>;
	Mon, 29 Jan 2018 09:04:55 -0000
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce super_operations->write_metadata
Date: Mon, 29 Jan 2018 14:36:15 +0530
In-Reply-To: <20180103162922.rxs2jpvmpxa62usa@destiny>
References: <20171212180534.c5f7luqz5oyfe7c3@destiny> <20180103162603.GO4911@quack2.suse.cz> <20180103162922.rxs2jpvmpxa62usa@destiny>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2857272.fAFXmvyrml@dhcp-9-109-247-21>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wednesday, January 3, 2018 9:59:24 PM IST Josef Bacik wrote:
> On Wed, Jan 03, 2018 at 05:26:03PM +0100, Jan Kara wrote:

> 
> Oh ok well if that's the case then I'll fix this up to be a ratio, test
> everything, and send it along probably early next week.  Thanks,
> 

Hi Josef,

Did you get a chance to work on the next version of this patchset?


-- 
chandan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
