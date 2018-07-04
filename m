Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D32A16B0269
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:57:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v7-v6so2595561wrn.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:57:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g8-v6si2877477wru.338.2018.07.04.05.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:57:31 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64CsFxX010901
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 08:57:30 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0wbx3g2u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:57:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 13:57:28 +0100
Date: Wed, 4 Jul 2018 15:57:21 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz>
 <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
 <20180704123627.GM22503@dhcp22.suse.cz>
 <20180704124335.GE4352@rapoport-lnx>
 <20180704125121.GO22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704125121.GO22503@dhcp22.suse.cz>
Message-Id: <20180704125720.GG4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jul 04, 2018 at 02:51:21PM +0200, Michal Hocko wrote:
> On Wed 04-07-18 15:43:35, Mike Rapoport wrote:
> > On Wed, Jul 04, 2018 at 02:36:27PM +0200, Michal Hocko wrote:
> [...]
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 03d48d8835ba..2acec4033389 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -227,7 +227,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> > >  		 * so we use WARN_ONCE() here to see the stack trace if
> > >  		 * fail happens.
> > >  		 */
> > > -		WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
> > > +		WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> > > +					"memblock: bottom-up allocation failed, memory hotremove may be affected\n");
> > 
> > nit: isn't the warning indented too much?
> 
> this is what vim did for me. The string doesn't fit into 80 even if I
> indented it to the first bracket. If you feel strongly I can do that
> though.

Not really. With wrapping if looks better like this :) 
 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
