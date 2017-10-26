Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 559236B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:24:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j3so2822299pga.5
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:24:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si3372409pgn.211.2017.10.26.06.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 06:24:04 -0700 (PDT)
Date: Thu, 26 Oct 2017 15:24:02 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and
 MAP_SYNC
Message-ID: <20171026132402.GB31161@quack2.suse.cz>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-19-jack@suse.cz>
 <20171024211007.GA1611@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
In-Reply-To: <20171024211007.GA1611@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 24-10-17 15:10:07, Ross Zwisler wrote:
> On Tue, Oct 24, 2017 at 05:24:15PM +0200, Jan Kara wrote:
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> This looks unchanged since the previous version?

Ah, thanks for checking. I forgot to commit modifications. Attached is
really updated patch.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--GvXjxJ+pjyke8COw
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mmap.2-Add-description-of-MAP_SHARED_VALIDATE-and-MA.patch"


--GvXjxJ+pjyke8COw--
