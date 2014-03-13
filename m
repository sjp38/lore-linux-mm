Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 49CC06B0031
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:15:17 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id e16so957715qcx.6
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 05:15:17 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id u4si1130179qat.92.2014.03.13.05.15.16
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 05:15:16 -0700 (PDT)
Date: Thu, 13 Mar 2014 12:14:59 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/3] kmemleak: allow freeing internal objects after
 disabling kmemleak
Message-ID: <20140313121459.GJ30339@arm.com>
References: <53215492.40701@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53215492.40701@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 13, 2014 at 06:47:46AM +0000, Li Zefan wrote:
> +Freeing kmemleak internal objects
> +---------------------------------
> +
> +To allow access to previosuly found memory leaks even when an error fatal
> +to kmemleak happens, internal kmemleak objects won't be freed when kmemleak
> +is disabled, and those objects may occupy a large part of physical
> +memory.
> +
> +If you want to make sure they're freed before disabling kmemleak:
> +
> +  # echo scan=off > /sys/kernel/debug/kmemleak
> +  # echo off > /sys/kernel/debug/kmemleak

I would actually change the code to do a stop_scan_thread() as part of
the "off" handling so that scan=off is not required (we can't put it as
part of the kmemleak_disable because we need scan_mutex held).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
