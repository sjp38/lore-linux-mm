Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 414486B003D
	for <linux-mm@kvack.org>; Sun, 16 Mar 2014 23:13:42 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id n16so5090707oag.31
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 20:13:41 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id z8si7696244oex.74.2014.03.16.20.13.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Mar 2014 20:13:41 -0700 (PDT)
Message-ID: <53266854.5080605@huawei.com>
Date: Mon, 17 Mar 2014 11:13:24 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] kmemleak: allow freeing internal objects after disabling
 kmemleak
References: <53215492.40701@huawei.com> <20140313121459.GJ30339@arm.com>
In-Reply-To: <20140313121459.GJ30339@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2014/3/13 20:14, Catalin Marinas wrote:
> On Thu, Mar 13, 2014 at 06:47:46AM +0000, Li Zefan wrote:
>> +Freeing kmemleak internal objects
>> +---------------------------------
>> +
>> +To allow access to previosuly found memory leaks even when an error fatal
>> +to kmemleak happens, internal kmemleak objects won't be freed when kmemleak
>> +is disabled, and those objects may occupy a large part of physical
>> +memory.
>> +
>> +If you want to make sure they're freed before disabling kmemleak:
>> +
>> +  # echo scan=off > /sys/kernel/debug/kmemleak
>> +  # echo off > /sys/kernel/debug/kmemleak
> 
> I would actually change the code to do a stop_scan_thread() as part of
> the "off" handling so that scan=off is not required (we can't put it as
> part of the kmemleak_disable because we need scan_mutex held).
> 

Sounds reasonable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
