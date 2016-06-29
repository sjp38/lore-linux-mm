Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 02B18828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 16:29:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so58278748wmr.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:29:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v198si628809wmf.69.2016.06.29.13.29.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 13:29:22 -0700 (PDT)
Date: Wed, 29 Jun 2016 22:29:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] mm: Export follow_pte()
Message-ID: <20160629202920.GD16831@quack2.suse.cz>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
 <1466523915-14644-3-git-send-email-jack@suse.cz>
 <20160624215512.GB20730@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624215512.GB20730@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Fri 24-06-16 15:55:12, Ross Zwisler wrote:
> On Tue, Jun 21, 2016 at 05:45:14PM +0200, Jan Kara wrote:
> > DAX will need to implement its own version of check_page_address(). To
> 						page_check_address()

Thanks. Fixed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
