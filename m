Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B69D26B4C0C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:42:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w15so12164968edl.21
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 00:42:00 -0800 (PST)
Date: Wed, 28 Nov 2018 08:41:57 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181128084157.2komhfl2vgx5abqy@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
 <20181128002952.x2m33nvlunzij5tk@master>
 <1543393167.2911.2.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543393167.2911.2.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Wed, Nov 28, 2018 at 09:19:27AM +0100, Oscar Salvador wrote:
>> My current idea is :
>
>I do not want to hold you back.
>I think that if you send a V2 detailing why we should be safe removing
>the pgdat lock it is fine (memhotplug lock protects us).

Fine.

>
>We can later on think about the range locking, but that is another
>discussion.
>Sorry for having brought in that topic here, out of scope.
>
>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me
