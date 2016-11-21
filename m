Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2346B04C7
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 23:39:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so373656397pgd.3
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 20:39:24 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r77si20674603pfb.73.2016.11.20.20.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 20:39:23 -0800 (PST)
Date: Sun, 20 Nov 2016 21:39:22 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 10/20] mm: Move handling of COW faults into DAX code
Message-ID: <20161121043922.GA31960@linux.intel.com>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
 <1479460644-25076-11-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479460644-25076-11-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org

On Fri, Nov 18, 2016 at 10:17:14AM +0100, Jan Kara wrote:
> Move final handling of COW faults from generic code into DAX fault
> handler. That way generic code doesn't have to be aware of peculiarities
> of DAX locking so remove that knowledge and make locking functions
> private to fs/dax.c.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
