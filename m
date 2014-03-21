Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 17C1C6B0287
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 19:40:48 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so3016091pad.21
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 16:40:47 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id pa10si4549035pbc.65.2014.03.21.16.40.44
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 16:40:45 -0700 (PDT)
Date: Fri, 21 Mar 2014 23:40:24 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 2/3] kmemleak: remove redundant code
Message-ID: <20140321234023.GA21429@arm.com>
References: <5326750E.1000004@huawei.com>
 <53267520.4030503@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53267520.4030503@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 17, 2014 at 04:08:00AM +0000, Li Zefan wrote:
> - remove kmemleak_padding().
> - remove kmemleak_release().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
