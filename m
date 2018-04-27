Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD8D36B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:36:26 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z128so1771360qka.8
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:36:26 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id v57-v6si1743093qtj.154.2018.04.27.09.36.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 09:36:26 -0700 (PDT)
Date: Fri, 27 Apr 2018 11:36:23 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
In-Reply-To: <20180427161813.GD8161@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804271136030.11686@nuc-kabylake>
References: <20180426215406.GB27853@wotan.suse.de> <20180427053556.GB11339@infradead.org> <20180427071843.GB17484@dhcp22.suse.cz> <alpine.DEB.2.20.1804271103160.11686@nuc-kabylake> <20180427161813.GD8161@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, 27 Apr 2018, Matthew Wilcox wrote:

> Some devices have incredibly bogus hardware like 28 bit addressing
> or 39 bit addressing.  We don't have a good way to allocate memory by
> physical address other than than saying "GFP_DMA for anything less than
> 32, GFP_DMA32 (or GFP_KERNEL on 32-bit) for anything less than 64 bit".
>
> Even CMA doesn't have a "cma_alloc_phys()".  Maybe that's the right place
> to put such an allocation API.

The other way out of this would be to require a IOMMU?
