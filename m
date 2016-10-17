Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 938716B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:04:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b75so96381593lfg.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:04:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv4si40214327wjb.235.2016.10.17.02.04.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 02:04:53 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:04:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/20] mm: Trim __do_fault() arguments
Message-ID: <20161017090451.GF3359@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-6-git-send-email-jack@suse.cz>
 <20161014203147.GD27575@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161014203147.GD27575@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 14-10-16 14:31:47, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:09PM +0200, Jan Kara wrote:
> > Use vm_fault structure to pass cow_page, page, and entry in and out of
> > the function. That reduces number of __do_fault() arguments from 4 to 1.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> In looking at this I realized that vmf->entry is actually unused, as is the
> entry we used to return back via __do_fault().  I guess they must have been in
> there because at one point they were needed for dax_unlock_mapping_entry()?
> Anyway, looking ahead I see patch 10 removes vmf->entry altogether. :)

Yes :).

> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Thanks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
