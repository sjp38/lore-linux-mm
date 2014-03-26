Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id B10756B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:43:40 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so653896igb.11
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:43:40 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id p9si2744321igr.51.2014.03.26.08.43.39
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 08:43:40 -0700 (PDT)
Date: Wed, 26 Mar 2014 10:43:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <53321CB6.5050706@oracle.com>
Message-ID: <alpine.DEB.2.10.1403261042360.2057@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc> <53321CB6.5050706@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Mar 2014, Sasha Levin wrote:

> I'm not sure if there's anything special about this cache, codewise it's
> created as follows:
>
>
>         inode_cachep = kmem_cache_create("inode_cache",
>                                          sizeof(struct inode),
>                                          0,
>                                          (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
>                                          SLAB_MEM_SPREAD),
>                                          init_once);
>
>
> I'd be happy to dig up any other info required, I'm just not too sure
> what you mean by options for the cache?

Slab parameters can be change in /sys/kernel/slab/inode. Any debug
parameters active? More information about what was actually going on when
the gpf occured?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
