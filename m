Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 881F36810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:02:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 83so1466452pgb.1
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:02:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f3si4897197pgn.632.2017.08.25.09.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 09:02:45 -0700 (PDT)
Date: Fri, 25 Aug 2017 09:02:36 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
Message-ID: <20170825160236.GA2561@infradead.org>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org>
 <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
 <20170825130011.GA30072@infradead.org>
 <20170825155803.4km7wttzadfqw2vb@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825155803.4km7wttzadfqw2vb@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org

On Fri, Aug 25, 2017 at 06:58:03PM +0300, Kirill A. Shutemov wrote:
> Not all archs are ready for this:
> 
> arch/parisc/include/uapi/asm/mman.h:#define MAP_TYPE    0x03            /* Mask for type of mapping */
> arch/parisc/include/uapi/asm/mman.h:#define MAP_FIXED   0x04            /* Interpret addr exactly */

I'd be happy to say that we should not care about parisc for
persistent memory.  We'll just have to find a way to exclude
parisc without making life too ugly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
