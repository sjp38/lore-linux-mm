Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D14E16B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 04:42:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v69so5543570wrb.3
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 01:42:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h59si5727592edd.454.2017.12.01.01.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 01:42:16 -0800 (PST)
Date: Fri, 1 Dec 2017 10:42:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: check pfn_valid first in zero_resv_unavail
Message-ID: <20171201094215.aenoqa5jepdc3jd5@dhcp22.suse.cz>
References: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
 <20171130093521.3yxyq6xvo6zgaifc@dhcp22.suse.cz>
 <20171201085657.GA2291@dhcp-128-65.nay.redhat.com>
 <20171201091930.5ddygjl23owfovrz@dhcp22.suse.cz>
 <20171201092951.GA2943@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201092951.GA2943@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, pasha.tatashin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 01-12-17 17:29:51, Dave Young wrote:
> On 12/01/17 at 10:19am, Michal Hocko wrote:
> > On Fri 01-12-17 16:56:57, Dave Young wrote:
> > > On 11/30/17 at 10:35am, Michal Hocko wrote:
> > [...]
> > > > Can we exclude that range from the memblock allocator instead? E.g. what
> > > > happens if somebody allocates from that range?
> > > 
> > > It is a EFI BGRT image buffer provided by firmware, they are reserved
> > > always and can not be used to allocate memory.
> > 
> > Hmm, I see but I was actually suggesting to remove this range from the
> > memblock allocator altogether (memblock_remove) as it shouldn't be there
> > in the first place.
> 
> Oh, I'm not sure because it is introduced as a way for efi to reserve
> boot services areas to be persistent across kexec reboot. See
> drivers/firmware/efi/efi.c: efi_mem_reserve(), BGRT is only one user
> of it, there is esrt and maybe other users, I do not know if it is safe
> :(

Hmm, so it this range ever backed by a valid pfn?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
