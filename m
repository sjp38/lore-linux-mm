Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0306B0038
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 16:31:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fn2so124406445pad.7
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 13:31:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f74si19778259pfe.260.2016.10.14.13.31.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 13:31:48 -0700 (PDT)
Date: Fri, 14 Oct 2016 14:31:47 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 05/20] mm: Trim __do_fault() arguments
Message-ID: <20161014203147.GD27575@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-6-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:09PM +0200, Jan Kara wrote:
> Use vm_fault structure to pass cow_page, page, and entry in and out of
> the function. That reduces number of __do_fault() arguments from 4 to 1.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

In looking at this I realized that vmf->entry is actually unused, as is the
entry we used to return back via __do_fault().  I guess they must have been in
there because at one point they were needed for dax_unlock_mapping_entry()?
Anyway, looking ahead I see patch 10 removes vmf->entry altogether. :)

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
