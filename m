Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 452396B02FD
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 07:56:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z1so19104074pgs.10
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 04:56:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i3si81616pld.582.2017.07.06.04.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 04:56:25 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v66BsNqa101410
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 07:56:25 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bhm96s98e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jul 2017 07:56:24 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.vnet.ibm.com>;
	Thu, 6 Jul 2017 21:56:21 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v66Bu9TX5243242
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 21:56:17 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v66Btibd031931
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 21:55:45 +1000
Subject: Re: [PATCH v2 05/10] tmpfs: define integrity_read method
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Date: Thu, 06 Jul 2017 07:55:20 -0400
In-Reply-To: <20170628143858.GD2359@lst.de>
References: <1498069110-10009-1-git-send-email-zohar@linux.vnet.ibm.com>
	 <1498069110-10009-6-git-send-email-zohar@linux.vnet.ibm.com>
	 <20170628143858.GD2359@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <1499342120.5500.3.camel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, linux-fsdevel@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, 2017-06-28 at 16:38 +0200, Christoph Hellwig wrote:
> On Wed, Jun 21, 2017 at 02:18:25PM -0400, Mimi Zohar wrote:
> > Define an ->integrity_read file operation method to read data for
> > integrity hash collection.
> 
> should be folded into patch 2.

I was hoping to get some Acks/sign-off's from the individual
filesystem maintainers before squashing them. A The next version will
be squashed.

Mimi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
