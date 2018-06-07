Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE126B026C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:50:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k12-v6so5709905wrl.21
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:50:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d55-v6si2150922ede.97.2018.06.07.08.50.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 08:50:04 -0700 (PDT)
Date: Thu, 7 Jun 2018 17:50:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 04/12] device-dax: Set page->index
Message-ID: <20180607155003.dwndud2xsnpqpcxl@quack2.suse.cz>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152815392126.39010.6403368422475215562.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152815392126.39010.6403368422475215562.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

On Mon 04-06-18 16:12:01, Dan Williams wrote:
> In support of enabling memory_failure() handling for device-dax
> mappings, set ->index to the pgoff of the page. The rmap implementation
> requires ->index to bound the search through the vma interval tree.
> 
> The ->index value is never cleared. There is no possibility for the
> page to become associated with another pgoff while the device is
> enabled. When the device is disabled the 'struct page' array for the
> device is destroyed and ->index is reinitialized to zero.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
