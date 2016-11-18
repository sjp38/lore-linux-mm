Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA0C26B03F0
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:23:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so10656507wms.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:23:54 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 18si1914915wmq.97.2016.11.18.02.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 02:23:53 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a20so4629251wme.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:23:53 -0800 (PST)
Date: Fri, 18 Nov 2016 13:23:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 12/20] mm: Pass vm_fault structure into do_page_mkwrite()
Message-ID: <20161118102351.GC9430@node>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
 <1479460644-25076-13-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479460644-25076-13-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org

On Fri, Nov 18, 2016 at 10:17:16AM +0100, Jan Kara wrote:
> We will need more information in the ->page_mkwrite() helper for DAX to
> be able to fully finish faults there. Pass vm_fault structure to
> do_page_mkwrite() and use it there so that information propagates
> properly from upper layers.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
