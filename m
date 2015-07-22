Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 490286B0258
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 11:45:35 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so108935800wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:45:34 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id k2si3138650wjz.180.2015.07.22.08.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 08:45:33 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so108934614wib.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:45:33 -0700 (PDT)
Date: Wed, 22 Jul 2015 18:45:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V4 5/6] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150722154529.GA9107@node.dhcp.inet.fi>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-6-git-send-email-emunson@akamai.com>
 <20150722112558.GC8630@node.dhcp.inet.fi>
 <20150722143220.GB3203@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722143220.GB3203@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Wed, Jul 22, 2015 at 10:32:20AM -0400, Eric B Munson wrote:
> On Wed, 22 Jul 2015, Kirill A. Shutemov wrote:
> 
> > On Tue, Jul 21, 2015 at 03:59:40PM -0400, Eric B Munson wrote:
> > > The cost of faulting in all memory to be locked can be very high when
> > > working with large mappings.  If only portions of the mapping will be
> > > used this can incur a high penalty for locking.
> > > 
> > > Now that we have the new VMA flag for the locked but not present state,
> > > expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.
> > 
> > What is advantage over mmap() + mlock(MLOCK_ONFAULT)?
> 
> There isn't one, it was added to maintain parity with the
> mlock(MLOCK_LOCK) -> mmap(MAP_LOCKED) set.  I think not having will lead
> to confusion because we have MAP_LOCKED so why don't we support
> LOCKONFAULT from mmap as well.

I don't think it's ia good idea to spend bits in flags unless we have a
reason for that.

BTW, you have typo on sparc: s/0x8000/0x80000/.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
