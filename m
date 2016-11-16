Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA00D6B028C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 15:00:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so93221709pfx.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 12:00:27 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g68si33277104pfc.88.2016.11.16.12.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 12:00:24 -0800 (PST)
Date: Wed, 16 Nov 2016 13:00:23 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 07/21] mm: Add orig_pte field into vm_fault
Message-ID: <20161116200023.GD31337@linux.intel.com>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-8-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-8-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:03AM +0100, Jan Kara wrote:
> Add orig_pte field to vm_fault structure to allow ->page_mkwrite
> handlers to fully handle the fault. This also allows us to save some
> passing of extra arguments around.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
