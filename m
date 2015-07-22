Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8675A9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:26:04 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so167466654wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:26:04 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id i7si24184169wiz.121.2015.07.22.04.26.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 04:26:02 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so149647046wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:26:01 -0700 (PDT)
Date: Wed, 22 Jul 2015 14:25:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4 5/6] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150722112558.GC8630@node.dhcp.inet.fi>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-6-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437508781-28655-6-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Jul 21, 2015 at 03:59:40PM -0400, Eric B Munson wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
> 
> Now that we have the new VMA flag for the locked but not present state,
> expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.

What is advantage over mmap() + mlock(MLOCK_ONFAULT)?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
