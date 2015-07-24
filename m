Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 08FDF6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:56:33 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so16224247pdb.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:56:32 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id am4si21974925pad.93.2015.07.24.09.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 09:56:32 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so17058315pab.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:56:31 -0700 (PDT)
Date: Fri, 24 Jul 2015 09:56:27 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
Message-ID: <20150724165627.GA3458@Sligo.logfs.org>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
 <20150724070420.GF4103@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150724070420.GF4103@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Fri, Jul 24, 2015 at 09:04:21AM +0200, Michal Hocko wrote:
> On Thu 23-07-15 14:54:33, Spencer Baugh wrote:
> > From: Joern Engel <joern@logfs.org>
> > 
> > Mapping large memory spaces can be slow and prevent high-priority
> > realtime threads from preempting lower-priority threads for a long time.
> 
> How can a lower priority task block the high priority one? Do you have
> preemption disabled?

Yes.

Jorn

--
If you're willing to restrict the flexibility of your approach,
you can almost always do something better.
-- John Carmack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
