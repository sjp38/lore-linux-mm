Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9196B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:51:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c19-v6so2188655edt.4
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:51:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4-v6si2301722edb.348.2018.07.04.05.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:51:22 -0700 (PDT)
Date: Wed, 4 Jul 2018 14:51:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Message-ID: <20180704125121.GO22503@dhcp22.suse.cz>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz>
 <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
 <20180704123627.GM22503@dhcp22.suse.cz>
 <20180704124335.GE4352@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704124335.GE4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 04-07-18 15:43:35, Mike Rapoport wrote:
> On Wed, Jul 04, 2018 at 02:36:27PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 03d48d8835ba..2acec4033389 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -227,7 +227,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> >  		 * so we use WARN_ONCE() here to see the stack trace if
> >  		 * fail happens.
> >  		 */
> > -		WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
> > +		WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> > +					"memblock: bottom-up allocation failed, memory hotremove may be affected\n");
> 
> nit: isn't the warning indented too much?

this is what vim did for me. The string doesn't fit into 80 even if I
indented it to the first bracket. If you feel strongly I can do that
though.

-- 
Michal Hocko
SUSE Labs
