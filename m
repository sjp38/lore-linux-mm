Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 42A286B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:06:23 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so4759850pdb.6
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:06:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b7si14185741pas.195.2015.01.22.16.06.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:06:21 -0800 (PST)
Date: Thu, 22 Jan 2015 16:06:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: provide a find_special_page vma operation
Message-Id: <20150122160620.e5e3f98ad58020832d899352@linux-foundation.org>
In-Reply-To: <1421682443-20509-2-git-send-email-david.vrabel@citrix.com>
References: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
	<1421682443-20509-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 Jan 2015 15:47:22 +0000 David Vrabel <david.vrabel@citrix.com> wrote:

> The optional find_special_page VMA operation is used to lookup the
> pages backing a VMA.  This is useful in cases where the normal
> mechanisms for finding the page don't work.  This is only called if
> the PTE is special.
> 
> One use case is a Xen PV guest mapping foreign pages into userspace.
> 
> In a Xen PV guest, the PTEs contain MFNs so get_user_pages() (for
> example) must do an MFN to PFN (M2P) lookup before it can get the
> page.  For foreign pages (those owned by another guest) the M2P lookup
> returns the PFN as seen by the foreign guest (which would be
> completely the wrong page for the local guest).
> 
> This cannot be fixed up improving the M2P lookup since one MFN may be
> mapped onto two or more pages so getting the right page is impossible
> given just the MFN.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
