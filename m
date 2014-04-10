Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC7646B0037
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:24:13 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so4026624pbb.12
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:24:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id et3si2317022pbc.76.2014.04.10.07.24.12
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:24:12 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:23:54 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 15/22] Remove CONFIG_EXT2_FS_XIP and rename
 CONFIG_FS_XIP to CONFIG_FS_DAX
Message-ID: <20140410142354.GJ5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <ff35fb6b662af013eddeb295a01258b42ccaa5ae.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409095918.GG32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409095918.GG32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:59:18AM +0200, Jan Kara wrote:
> On Sun 23-03-14 15:08:41, Matthew Wilcox wrote:
> > The fewer Kconfig options we have the better.  Use the generic
> > CONFIG_FS_DAX to enable XIP support in ext2 as well as in the core.
> > 
> > Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
>   Looks good. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> BTW: Its really only 2KB of code?

I changed it in a later patch ... it's about 5kB of code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
