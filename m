Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9D6D6B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:42:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4-v6so1709284wme.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:42:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x15-v6sor626047wmh.68.2018.07.31.07.41.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 07:41:59 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:41:57 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731144157.GA1499@techadventures.net>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue, Jul 31, 2018 at 08:49:11AM -0400, Pavel Tatashin wrote:
> Hi Oscar,
> 
> Have you looked into replacing __paginginit via __meminit ? What is
> the reason to keep both?
Hi Pavel,

Actually, thinking a bit more about this, it might make sense to remove
__paginginit altogether and keep only __meminit.
Looking at the original commit, I think that it was put as a way to abstract it.

After the patchset [1] has been applied, only two functions marked as __paginginit
remain, so it will be less hassle to replace that with __meminit.

I will send a v2 tomorrow to be applied on top of [1].

[1] https://patchwork.kernel.org/patch/10548861/

Thanks
-- 
Oscar Salvador
SUSE L3
