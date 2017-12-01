Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E10616B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 04:19:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y15so5465700wrc.6
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 01:19:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g27si4468566edf.169.2017.12.01.01.19.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 01:19:31 -0800 (PST)
Date: Fri, 1 Dec 2017 10:19:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: check pfn_valid first in zero_resv_unavail
Message-ID: <20171201091930.5ddygjl23owfovrz@dhcp22.suse.cz>
References: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
 <20171130093521.3yxyq6xvo6zgaifc@dhcp22.suse.cz>
 <20171201085657.GA2291@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201085657.GA2291@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, pasha.tatashin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 01-12-17 16:56:57, Dave Young wrote:
> On 11/30/17 at 10:35am, Michal Hocko wrote:
[...]
> > Can we exclude that range from the memblock allocator instead? E.g. what
> > happens if somebody allocates from that range?
> 
> It is a EFI BGRT image buffer provided by firmware, they are reserved
> always and can not be used to allocate memory.

Hmm, I see but I was actually suggesting to remove this range from the
memblock allocator altogether (memblock_remove) as it shouldn't be there
in the first place.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
