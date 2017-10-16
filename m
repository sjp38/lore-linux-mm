Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F81C6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:18:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v2so13257839pfa.10
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:18:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k126si1541188pfc.348.2017.10.16.05.18.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 05:18:14 -0700 (PDT)
Date: Mon, 16 Oct 2017 14:18:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171016121808.m4sq3g5nxeyxoymc@dhcp22.suse.cz>
References: <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <20171015065856.GC3916@xo-6d-61-c0.localdomain>
 <20171016081804.yiqck2g4bwlbdqi6@dhcp22.suse.cz>
 <20171016095447.GA4639@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171016095447.GA4639@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 16-10-17 11:54:47, Pavel Machek wrote:
> On Mon 2017-10-16 10:18:04, Michal Hocko wrote:
> > On Sun 15-10-17 08:58:56, Pavel Machek wrote:
[...]
> > > So you'd suggest using ioctl() for allocating memory?
> > 
> > Why not using standard mmap on the device fd?
> 
> No, sorry, that's something very different work, right? Lets say I
> have a disk, and I'd like to write to it, using continguous memory for
> performance.
> 
> So I mmap(MAP_CONTIG) 1GB working of working memory, prefer some data
> structures there, maybe recieve from network, then decide to write
> some and not write some other.

Why would you want this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
