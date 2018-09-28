Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 964088E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:35:27 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q12-v6so6478383otf.20
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:35:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s205-v6si1897916oia.249.2018.09.28.01.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 01:35:26 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8S8Y5EY143727
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:35:25 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2msfkuk19r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:35:25 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <chandan@linux.vnet.ibm.com>;
	Fri, 28 Sep 2018 09:35:23 +0100
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce super_operations->write_metadata
Date: Fri, 28 Sep 2018 14:07:41 +0530
In-Reply-To: <2857272.fAFXmvyrml@dhcp-9-109-247-21>
References: <20171212180534.c5f7luqz5oyfe7c3@destiny> <20180103162922.rxs2jpvmpxa62usa@destiny> <2857272.fAFXmvyrml@dhcp-9-109-247-21>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <139844049.hOcP8gZF7I@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: Josef Bacik <josef@toxicpanda.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org

On Monday, January 29, 2018 2:36:15 PM IST Chandan Rajendra wrote:
> On Wednesday, January 3, 2018 9:59:24 PM IST Josef Bacik wrote:
> > On Wed, Jan 03, 2018 at 05:26:03PM +0100, Jan Kara wrote:
> 
> > 
> > Oh ok well if that's the case then I'll fix this up to be a ratio, test
> > everything, and send it along probably early next week.  Thanks,
> > 
> 
> Hi Josef,
> 
> Did you get a chance to work on the next version of this patchset?
> 
> 
> 

Josef,  Any updates on this and the "Kill Btree inode" patchset?

-- 
chandan
