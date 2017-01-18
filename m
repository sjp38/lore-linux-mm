Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B74A56B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:22:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so24278409pfb.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:22:18 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j85si824082pfk.49.2017.01.18.09.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 09:22:17 -0800 (PST)
Date: Wed, 18 Jan 2017 10:22:16 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [LSF/MM TOPIC] Future direction of DAX
Message-ID: <20170118172216.GA20111@linux.intel.com>
References: <20170114002008.GA25379@linux.intel.com>
 <20170118052533.GA18349@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118052533.GA18349@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@bombadil.infradead.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 17, 2017 at 09:25:33PM -0800, willy@bombadil.infradead.org wrote:
> On Fri, Jan 13, 2017 at 05:20:08PM -0700, Ross Zwisler wrote:
> > We still have a lot of work to do, though, and I'd like to propose a discussion
> > around what features people would like to see enabled in the coming year as
> > well as what what use cases their customers have that we might not be aware of.
> 
> +1 to the discussion
> 
> > - Jan suggested [2] that we could use the radix tree as a cache to service DAX
> >   faults without needing to call into the filesystem.  Are there any issues
> >   with this approach, and should we move forward with it as an optimization?
> 
> Ahem.  I believe I proposed this at last year's LSFMM.  And I sent
> patches to start that work.  And Dan blocked it.  So I'm not terribly
> amused to see somebody else given credit for the idea.
> 
> It's not just an optimisation.  It's also essential for supporting
> filesystems which don't have block devices.  I'm aware of at least two
> customer demands for this in different domains.
> 
> 1. Embedded uses with NOR flash
> 2. Cloud/virt uses with multiple VMs on a single piece of hardware

Yea, I didn't mean the full move to having PFNs in the tree, just using the
sector number in the radix tree instead of calling into the filesystem.

My apologies if you feel I didn't give you proper credit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
