Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 160D46B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 05:16:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so15016069wrc.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 02:16:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si3138382wmg.191.2017.09.27.02.16.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 02:16:23 -0700 (PDT)
Date: Wed, 27 Sep 2017 11:16:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
Message-ID: <20170927091619.lkhfhwv3uu3km3sv@dhcp22.suse.cz>
References: <20170927082038.3782-1-jthumshirn@suse.de>
 <20170927082038.3782-2-jthumshirn@suse.de>
 <20170927084251.kxves5ce76jz5skr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1709270358400.30866@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709270358400.30866@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>

On Wed 27-09-17 04:03:01, Cristopher Lameter wrote:
> On Wed, 27 Sep 2017, Michal Hocko wrote:
> 
> > > Introduce a combination of the two above cases to have a NUMA-node aware
> > > version of kmalloc_array() and kcalloc().
> >
> > Yes, this is helpful. I am just wondering why we cannot have
> > kmalloc_array to call kmalloc_array_node with the local node as a
> > parameter. Maybe some sort of an optimization?
> 
> Well the regular kmalloc without node is supposed to follow memory
> policies. An explicit mentioning of a node requires allocation from that
> node and will override memory allocation policies.

I see. Thanks for the clarification

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
