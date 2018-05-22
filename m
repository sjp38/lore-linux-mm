Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 115916B000A
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:22:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y16-v6so6374361wrp.19
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:22:54 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t33-v6si14288511wrc.383.2018.05.21.23.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:22:52 -0700 (PDT)
Date: Tue, 22 May 2018 08:28:06 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
	CONFIG_DEV_PAGEMAP_OPS
Message-ID: <20180522062806.GD7816@lst.de>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com> <20180518094616.GA25838@lst.de> <CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com> <20180521090410.7ygosxzjfhceqrq4@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521090410.7ygosxzjfhceqrq4@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Mon, May 21, 2018 at 11:04:10AM +0200, Jan Kara wrote:
> We definitely do have customers using "execute in place" on s390x from
> dcssblk. I've got about two bug reports for it when customers were updating
> from old kernels using original XIP to kernels using DAX. So we need to
> keep that working.

That is all good an fine, but I think time has come where s390 needs
to migrate to provide the pmem API so that we can get rid of these
special cases.  Especially given that the old XIP/legacy DAX has all
kinds of known bugs at this point in time.
