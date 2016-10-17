Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8076B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:50:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l29so108409468pfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 09:50:18 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n9si28220622pgd.67.2016.10.17.09.50.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 09:50:17 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:50:15 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 08/20] mm: Allow full handling of COW faults in ->fault
 handlers
Message-ID: <20161017165015.GB25175@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-9-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-9-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:12PM +0200, Jan Kara wrote:
> To allow full handling of COW faults add memcg field to struct vm_fault
> and a return value of ->fault() handler meaning that COW fault is fully
> handled and memcg charge must not be canceled. This will allow us to
> remove knowledge about special DAX locking from the generic fault code.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
