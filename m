Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 620576B0022
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:19:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z20so70881pfn.11
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:19:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si2589212plj.275.2018.04.10.05.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:19:06 -0700 (PDT)
Date: Tue, 10 Apr 2018 05:19:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: __GFP_LOW
Message-ID: <20180410121904.GD22118@bombadil.infradead.org>
References: <20180405153240.GO6312@dhcp22.suse.cz>
 <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz>
 <20180405201557.GA3666@bombadil.infradead.org>
 <20180406060953.GA8286@dhcp22.suse.cz>
 <20180408042709.GC32632@bombadil.infradead.org>
 <20180409073407.GD21835@dhcp22.suse.cz>
 <20180409155157.GC11756@bombadil.infradead.org>
 <20180409181400.GO21835@dhcp22.suse.cz>
 <CA+JonM0HG9kWb6-0iyDQ8UMxTeR-f=+ZL89t5DvvDULDC8Sfyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+JonM0HG9kWb6-0iyDQ8UMxTeR-f=+ZL89t5DvvDULDC8Sfyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JTQvNC40YLRgNC40Lkg0JvQtdC+0L3RgtGM0LXQsg==?= <dm.leontiev7@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, Apr 10, 2018 at 03:12:37PM +0300, D?D 1/4 D,N?N?D,D1 D?DuD 3/4 D 1/2 N?N?DuD2 wrote:
> First, I've noticed the network drivers were allocating memory in interrupt
> handlers. That sounds strange to me, because as far as I know, this
> behaviour is discouraged and may lead to DDOS attack.

Linux supports allocating memory in interrupt context.  We also support
allocating memory while holding locks.

Doing it any other way would require the network stack to preallocate
all of the memory it's going to use.  You can pop over to the netdev
mailing list and ask them to stop this behaviour, but I don't think
they'll be very sympathetic.
