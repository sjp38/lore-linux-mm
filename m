Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD5A16B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 22:32:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i196so1754902pgd.2
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 19:32:55 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id o29si5368468pfi.90.2017.11.02.19.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Nov 2017 19:32:50 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 02/15] mm, dax: introduce pfn_t_special()
In-Reply-To: <150949210553.24061.5992572975056748512.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com> <150949210553.24061.5992572975056748512.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Fri, 03 Nov 2017 13:32:44 +1100
Message-ID: <87ines6qib.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de, Arnd Bergmann <arnd@arndb.de>

Dan Williams <dan.j.williams@intel.com> writes:

> In support of removing the VM_MIXEDMAP indication from DAX VMAs,
> introduce pfn_t_special() for drivers to indicate that _PAGE_SPECIAL
> should be used for DAX ptes. This also helps identify drivers like
> dccssblk that only want to use DAX in a read-only fashion without
> get_user_pages() support.
>
> Ideally we could delete axonram and dcssblk DAX support, but if we need
> to keep it better make it explicit that axonram and dcssblk only support
> a sub-set of DAX due to missing _PAGE_DEVMAP support.

I sent a patch to remove axonram (sorry meant to Cc you):

  http://patchwork.ozlabs.org/patch/833588/

Will see if there's any feedback.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
