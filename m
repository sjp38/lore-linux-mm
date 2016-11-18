Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCA46B03EA
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:22:14 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so75218wjc.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:22:14 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id m141si1934289wmd.20.2016.11.18.02.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 02:22:12 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id u144so4647617wmu.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:22:12 -0800 (PST)
Date: Fri, 18 Nov 2016 13:22:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/20] mm: Join struct fault_env and vm_fault
Message-ID: <20161118102210.GA9430@node>
References: <1479460644-25076-1-git-send-email-jack@suse.cz>
 <1479460644-25076-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479460644-25076-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org

On Fri, Nov 18, 2016 at 10:17:05AM +0100, Jan Kara wrote:
> Currently we have two different structures for passing fault information
> around - struct vm_fault and struct fault_env. DAX will need more
> information in struct vm_fault to handle its faults so the content of
> that structure would become event closer to fault_env. Furthermore it
> would need to generate struct fault_env to be able to call some of the
> generic functions. So at this point I don't think there's much use in
> keeping these two structures separate. Just embed into struct vm_fault
> all that is needed to use it for both purposes.
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
