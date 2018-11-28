Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30F566B4BF6
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:19:46 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i14so4495939edf.17
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 00:19:46 -0800 (PST)
Message-ID: <1543393167.2911.2.camel@suse.de>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
From: Oscar Salvador <osalvador@suse.de>
Date: Wed, 28 Nov 2018 09:19:27 +0100
In-Reply-To: <20181128002952.x2m33nvlunzij5tk@master>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
	 <20181127062514.GJ12455@dhcp22.suse.cz>
	 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
	 <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
	 <20181128002952.x2m33nvlunzij5tk@master>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

> My current idea is :

I do not want to hold you back.
I think that if you send a V2 detailing why we should be safe removing
the pgdat lock it is fine (memhotplug lock protects us).

We can later on think about the range locking, but that is another
discussion.
Sorry for having brought in that topic here, out of scope.

-- 
Oscar Salvador
SUSE L3
