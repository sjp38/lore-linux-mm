Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B13966B0266
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:22:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so10812729wmd.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:22:54 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id z14si1899903wmh.153.2016.11.18.02.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 02:22:53 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id xy5so39560wjc.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:22:53 -0800 (PST)
Date: Fri, 18 Nov 2016 13:22:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/20] mm: Use vmf->address instead of of
 vmf->virtual_address
Message-ID: <20161118102251.GB9430@node>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
 <1479460644-25076-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479460644-25076-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org

On Fri, Nov 18, 2016 at 10:17:06AM +0100, Jan Kara wrote:
> Every single user of vmf->virtual_address typed that entry to unsigned
> long before doing anything with it so the type of virtual_address does
> not really provide us any additional safety. Just use masked
> vmf->address which already has the appropriate type.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
