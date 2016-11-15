Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDD26B02E3
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:57:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so10295742wma.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:57:16 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id f125si4791408wmf.44.2016.11.15.14.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:57:14 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so4990531wma.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:57:14 -0800 (PST)
Date: Wed, 16 Nov 2016 01:57:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 17/21] mm: Change return values of finish_mkwrite_fault()
Message-ID: <20161115225711.GQ23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-18-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-18-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:13AM +0100, Jan Kara wrote:
> Currently finish_mkwrite_fault() returns 0 when PTE got changed before
> we acquired PTE lock and VM_FAULT_WRITE when we succeeded in modifying
> the PTE. This is somewhat confusing since 0 generally means success, it
> is also inconsistent with finish_fault() which returns 0 on success.
> Change finish_mkwrite_fault() to return 0 on success and VM_FAULT_NOPAGE
> when PTE changed. Practically, there should be no behavioral difference
> since we bail out from the fault the same way regardless whether we
> return 0, VM_FAULT_NOPAGE, or VM_FAULT_WRITE. Also note that
> VM_FAULT_WRITE has no effect for shared mappings since the only two
> places that check it - KSM and GUP - care about private mappings only.
> Generally the meaning of VM_FAULT_WRITE for shared mappings is not well
> defined and we should probably clean that up.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Sounds right.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
