Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1388A6B02BE
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:01:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so9152843wms.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:01:46 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ce10si26648591wjd.29.2016.11.15.14.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:01:44 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id u144so4630034wmu.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:01:44 -0800 (PST)
Date: Wed, 16 Nov 2016 01:01:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 03/21] mm: Use pgoff in struct vm_fault instead of
 passing it separately
Message-ID: <20161115220142.GC23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:24:59AM +0100, Jan Kara wrote:
> struct vm_fault has already pgoff entry. Use it instead of passing pgoff
> as a separate argument and then assigning it later.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Okay, makes sense.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
