Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C52F08E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 01:56:27 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so15366012edz.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:56:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f27-v6si2125700ejh.100.2018.12.18.22.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 22:56:26 -0800 (PST)
Date: Wed, 19 Dec 2018 07:56:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: clear zone_movable_pfn if the node
 doesn't have ZONE_MOVABLE
Message-ID: <20181219065625.GC10480@dhcp22.suse.cz>
References: <20181216125624.3416-1-richard.weiyang@gmail.com>
 <20181217102534.GF30879@dhcp22.suse.cz>
 <20181217141802.4bl4icg3mvwtmhqe@master>
 <20181218121451.GK30879@dhcp22.suse.cz>
 <20181218143943.ufuqzawibqyabzzl@master>
 <20181218144724.GM30879@dhcp22.suse.cz>
 <20181218202743.i5wvlzipzdl54fuq@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218202743.i5wvlzipzdl54fuq@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@techsingularity.net, osalvador@suse.de

On Tue 18-12-18 20:27:43, Wei Yang wrote:
[...]
> BTW, would this eat lower zone's memory? For example, has less DMA32?

Yes I think so. If the distribution should be even and some node(s) span
only lower 32b address range then there is no other option than shrink
the DMA32 zone. There is a note
			In the
			event, a node is too small to have both ZONE_NORMAL and
			ZONE_MOVABLE, kernelcore memory will take priority and
			other nodes will have a larger ZONE_MOVABLE.
which explains that this might not be the case though.

Btw. I have to say I quite do not like this interface not to mention the
implementation. THere are users to rely on it though so we cannot remove
it. There is a lot of room for cleanups there.
-- 
Michal Hocko
SUSE Labs
