Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4BE6B4F2F
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:07:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so12957397pgb.7
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 14:07:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u16si9504618plk.192.2018.11.28.14.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 14:07:57 -0800 (PST)
Date: Wed, 28 Nov 2018 14:07:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-Id: <20181128140751.e79de952a3fdfdac3aab75e9@linux-foundation.org>
In-Reply-To: <20181128210815.2134-1-richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, jweiner@fb.com, linux-mm@kvack.org

On Thu, 29 Nov 2018 05:08:15 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> Function show_mem() is used to print system memory status when user
> requires or fail to allocate memory. Generally, this is a best effort
> information and not willing to affect core mm subsystem.
> 
> The data protected by pgdat_resize_lock is mostly correct except there is:
> 
>    * page struct defer init
>    * memory hotplug

What is the advantage in doing this?  What problem does the taking of
that lock cause?
