Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 968846B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:22:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so18889309lff.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 10:22:33 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id f98si2683211lfi.314.2016.10.11.10.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 10:22:32 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id l131so2242415lfl.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 10:22:31 -0700 (PDT)
Date: Tue, 11 Oct 2016 19:22:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
Message-ID: <20161011172228.GA30403@dhcp22.suse.cz>
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: tj@kernel.org, akpm@linux-foundation.org, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On Tue 11-10-16 21:24:50, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> the LSB of a chunk->map element is used for free/in-use flag of a area
> and the other bits for offset, the sufficient and necessary condition of
> this usage is that both size and alignment of a area must be even numbers
> however, pcpu_alloc() doesn't force its @align parameter a even number
> explicitly, so a odd @align maybe causes a series of errors, see below
> example for concrete descriptions.

Is or was there any user who would use a different than even (or power of 2)
alighment? If not is this really worth handling?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
