Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 821BE6B0287
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 19:44:33 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so2945596pdj.18
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 16:44:33 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id gt10si4037684pbc.208.2014.03.21.16.44.32
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 16:44:32 -0700 (PDT)
Date: Fri, 21 Mar 2014 23:44:07 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 3/3] kmemleak: change some global variables to int
Message-ID: <20140321234407.GB21429@arm.com>
References: <5326750E.1000004@huawei.com>
 <53267560.5060803@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53267560.5060803@huawei.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 17, 2014 at 04:09:04AM +0000, Li Zefan wrote:
> They don't have to be atomic_t, because they are simple boolean
> toggles.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

A reason for which I had atomic_t was to avoid compiler optimisations
but I don't immediately see how it could go wrong. Assuming that you
have tested it,

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
