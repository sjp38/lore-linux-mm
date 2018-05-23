Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7E886B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:50:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x18-v6so8341852wrl.21
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:50:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i18-v6si2252132wmh.82.2018.05.23.11.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 11:50:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4NIhqO1100295
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:50:24 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j5bnqe08k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:50:24 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 23 May 2018 19:50:22 +0100
Date: Wed, 23 May 2018 20:50:17 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
 CONFIG_DEV_PAGEMAP_OPS
In-Reply-To: <20180522062806.GD7816@lst.de>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20180518094616.GA25838@lst.de>
	<CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com>
	<20180521090410.7ygosxzjfhceqrq4@quack2.suse.cz>
	<20180522062806.GD7816@lst.de>
MIME-Version: 1.0
Message-Id: <20180523205017.0f2bc83e@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, 22 May 2018 08:28:06 +0200
Christoph Hellwig <hch@lst.de> wrote:

> On Mon, May 21, 2018 at 11:04:10AM +0200, Jan Kara wrote:
> > We definitely do have customers using "execute in place" on s390x from
> > dcssblk. I've got about two bug reports for it when customers were updating
> > from old kernels using original XIP to kernels using DAX. So we need to
> > keep that working.  
> 
> That is all good an fine, but I think time has come where s390 needs
> to migrate to provide the pmem API so that we can get rid of these
> special cases.  Especially given that the old XIP/legacy DAX has all
> kinds of known bugs at this point in time.

I haven't yet looked at this patch series, but I can feel that this
FS_DAX_LIMITED workaround is beginning to cause some headaches, apart
from being quite ugly of course.

Just to make sure I still understand the basic problem, which I thought
was missing struct pages for the dcssblk memory, what exactly do you
mean with "provide the pmem API", is there more to do?

I do have a prototype patch lying around that adds struct pages, but
didn't yet have time to fully test/complete it. Of course we initially
introduced XIP as a mechanism to reduce memory consumption, and that
is probably the use case for the remaining customer(s). Adding struct
pages would somehow reduce that benefit, but as long as we can still
"execute in place", I guess it will be OK.

Regards,
Gerald
