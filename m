Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 47A086B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:18:18 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so96332289igb.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:18:18 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id b16si16102755icr.6.2015.07.27.08.18.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 08:18:17 -0700 (PDT)
Received: by igbpg9 with SMTP id pg9so96331843igb.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:18:17 -0700 (PDT)
Date: Mon, 27 Jul 2015 08:18:14 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
Message-ID: <20150727151814.GR9641@Sligo.logfs.org>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
 <20150724070420.GF4103@dhcp22.suse.cz>
 <20150724165627.GA3458@Sligo.logfs.org>
 <20150727070840.GB11317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150727070840.GB11317@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Mon, Jul 27, 2015 at 09:08:42AM +0200, Michal Hocko wrote:
> On Fri 24-07-15 09:56:27, JA?rn Engel wrote:
> > On Fri, Jul 24, 2015 at 09:04:21AM +0200, Michal Hocko wrote:
> > > On Thu 23-07-15 14:54:33, Spencer Baugh wrote:
> > > > From: Joern Engel <joern@logfs.org>
> > > > 
> > > > Mapping large memory spaces can be slow and prevent high-priority
> > > > realtime threads from preempting lower-priority threads for a long time.
> > > 
> > > How can a lower priority task block the high priority one? Do you have
> > > preemption disabled?
> > 
> > Yes.

We have kernel preemption disabled.  A lower-priority task in a system
call will block higher-priority tasks.

JA?rn

--
After Iraq, if a PM said there are trees in the rainforest youa??d need
to send for proof.
-- Alex Thompson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
