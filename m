Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 490966B5014
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 20:52:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so344936ede.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 17:52:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor159376edq.15.2018.11.28.17.52.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 17:52:07 -0800 (PST)
Date: Thu, 29 Nov 2018 01:52:05 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129015205.rrwzakileopkrxaa@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181128140751.e79de952a3fdfdac3aab75e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128140751.e79de952a3fdfdac3aab75e9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, jweiner@fb.com, linux-mm@kvack.org

On Wed, Nov 28, 2018 at 02:07:51PM -0800, Andrew Morton wrote:
>On Thu, 29 Nov 2018 05:08:15 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> Function show_mem() is used to print system memory status when user
>> requires or fail to allocate memory. Generally, this is a best effort
>> information and not willing to affect core mm subsystem.
>> 
>> The data protected by pgdat_resize_lock is mostly correct except there is:
>> 
>>    * page struct defer init
>>    * memory hotplug
>
>What is the advantage in doing this?  What problem does the taking of
>that lock cause?

Michal and I had a discussion in https://patchwork.kernel.org/patch/10689759/

The purpose of this is to see whehter it is nessary to make
pgdat_resize_lock IRQ context safe. After went through the code, most of
the users are not from IRQ context.

If my understanding is correct, Michal's suggestion is to drop the lock
here. (The second last reply from Michal.)

-- 
Wei Yang
Help you, Help me
