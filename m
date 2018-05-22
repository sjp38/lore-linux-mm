Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F40F26B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:21:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i11-v6so12951939wre.16
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:21:52 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 90-v6si5481752wrd.244.2018.05.21.23.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:21:51 -0700 (PDT)
Date: Tue, 22 May 2018 08:27:05 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v11 7/7] xfs, dax: introduce xfs_break_dax_layouts()
Message-ID: <20180522062705.GC7816@lst.de>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com> <152669372916.34337.4066620800998291994.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152669372916.34337.4066620800998291994.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
