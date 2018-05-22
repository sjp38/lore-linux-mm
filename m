Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 954746B0007
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:20:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v12-v6so8800550wmc.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:20:44 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m1-v6si11359180wmd.104.2018.05.21.23.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:20:43 -0700 (PDT)
Date: Tue, 22 May 2018 08:25:57 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v11 2/7] mm: introduce MEMORY_DEVICE_FS_DAX and
	CONFIG_DEV_PAGEMAP_OPS
Message-ID: <20180522062557.GB7816@lst.de>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com> <152669370288.34337.17897113760758005456.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152669370288.34337.17897113760758005456.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
