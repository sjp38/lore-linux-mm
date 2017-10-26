Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B41886B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 14:22:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s75so3394326pgs.12
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 11:22:09 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r84si4018615pfa.352.2017.10.26.11.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 11:22:08 -0700 (PDT)
Date: Thu, 26 Oct 2017 12:22:05 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and
 MAP_SYNC
Message-ID: <20171026182205.GA8048@linux.intel.com>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-19-jack@suse.cz>
 <20171024211007.GA1611@linux.intel.com>
 <20171026132402.GB31161@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026132402.GB31161@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 26, 2017 at 03:24:02PM +0200, Jan Kara wrote:
> On Tue 24-10-17 15:10:07, Ross Zwisler wrote:
> > On Tue, Oct 24, 2017 at 05:24:15PM +0200, Jan Kara wrote:
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > This looks unchanged since the previous version?
> 
> Ah, thanks for checking. I forgot to commit modifications. Attached is
> really updated patch.
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

> From 59eeec2998ed9b3840aab951f213148cb1d053a5 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Thu, 19 Oct 2017 14:44:55 +0200
> Subject: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and MAP_SYNC
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks good, you can add: 

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
