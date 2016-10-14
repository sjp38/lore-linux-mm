Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 365996B0038
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 14:02:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h24so64548068pfh.0
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 11:02:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 191si15963366pgb.303.2016.10.14.11.02.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 11:02:37 -0700 (PDT)
Date: Fri, 14 Oct 2016 12:02:35 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 01/20] mm: Change type of vmf->virtual_address
Message-ID: <20161014180235.GA27575@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:05PM +0200, Jan Kara wrote:
> Every single user of vmf->virtual_address typed that entry to unsigned
> long before doing anything with it. So just change the type of that
> entry to unsigned long immediately.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
