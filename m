Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 50D4D6B0255
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 03:31:34 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so103309913wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:31:33 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id n7si29323841wjb.50.2015.07.27.00.31.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 00:31:33 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so127120933wic.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:31:32 -0700 (PDT)
Date: Mon, 27 Jul 2015 10:31:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V5 5/7] mm: mmap: Add mmap flag to request VM_LOCKONFAULT
Message-ID: <20150727073129.GE11657@node.dhcp.inet.fi>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-6-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437773325-8623-6-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Paul Gortmaker <paul.gortmaker@windriver.com>, Chris Metcalf <cmetcalf@ezchip.com>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Fri, Jul 24, 2015 at 05:28:43PM -0400, Eric B Munson wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
> 
> Now that we have the new VMA flag for the locked but not present state,
> expose it as an mmap option like MAP_LOCKED -> VM_LOCKED.

As I mentioned before, I don't think this interface is justified.

MAP_LOCKED has known issues[1]. The MAP_LOCKED problem is not necessary
affects MAP_LOCKONFAULT, but still.

Let's not add new interface unless it's demonstrably useful.

[1] http://lkml.kernel.org/g/20150114095019.GC4706@dhcp22.suse.cz

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
