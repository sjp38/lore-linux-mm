Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D440C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:02:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a192so12330206pge.1
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 11:02:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v85si5633895pfa.570.2017.10.23.11.02.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 11:02:34 -0700 (PDT)
Date: Mon, 23 Oct 2017 20:02:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171023180232.luayzqacnkepnm57@dhcp22.suse.cz>
References: <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-10-17 19:52:27, C.Wehrmeyer wrote:
[...]
> > or you can mmap a larger block and
> > munmap the initial unaligned part.
> 
> And how is that supposed to be transparent? When I hear "transparent" I
> think of a mechanism which I can put under a system so that it benefits from
> it, while the system does not notice or at least does not need to be aware
> of it. The system also does not need to be changed for it.

How do you expect to get a huge page when the mapping itself is not
properly aligned? Sure if you have a large mapping then you probably do
not care about first and last chunk being not 2MB aligned but in order
to get a THP you really need a 2MB aligned address.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
