Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B37F76B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 00:25:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so4755402pfx.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:25:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q21si27185894pgg.333.2017.01.17.21.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 21:25:36 -0800 (PST)
Date: Tue, 17 Jan 2017 21:25:33 -0800
From: willy@bombadil.infradead.org
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170118052533.GA18349@bombadil.infradead.org>
References: <20170114002008.GA25379@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114002008.GA25379@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 13, 2017 at 05:20:08PM -0700, Ross Zwisler wrote:
> We still have a lot of work to do, though, and I'd like to propose a discussion
> around what features people would like to see enabled in the coming year as
> well as what what use cases their customers have that we might not be aware of.

+1 to the discussion

> - Jan suggested [2] that we could use the radix tree as a cache to service DAX
>   faults without needing to call into the filesystem.  Are there any issues
>   with this approach, and should we move forward with it as an optimization?

Ahem.  I believe I proposed this at last year's LSFMM.  And I sent
patches to start that work.  And Dan blocked it.  So I'm not terribly
amused to see somebody else given credit for the idea.

It's not just an optimisation.  It's also essential for supporting
filesystems which don't have block devices.  I'm aware of at least two
customer demands for this in different domains.

1. Embedded uses with NOR flash
2. Cloud/virt uses with multiple VMs on a single piece of hardware

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
