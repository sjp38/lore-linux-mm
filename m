Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 936136B5757
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:54:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so2435563eda.12
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 00:54:22 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 30 Nov 2018 09:54:20 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2] mm, show_mem: drop pgdat_resize_lock in show_mem()
In-Reply-To: <20181129235532.9328-1-richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129235532.9328-1-richard.weiyang@gmail.com>
Message-ID: <64daff638c221984017fe58b09893386@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-11-30 00:55, Wei Yang wrote:
> Function show_mem() is used to print system memory status when user
> requires or fail to allocate memory. Generally, this is a best effort
> information so any races with memory hotplug (or very theoretically an
> early initialization) should be tolerable and the worst that could
> happen is to print an imprecise node state.
> 
> Drop the resize lock because this is the only place which might hold 
> the
> lock from the interrupt context and so all other callers might use a
> simple spinlock. Even though this doesn't solve any real issue it makes
> the code easier to follow and tiny more effective.
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>
