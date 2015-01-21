Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id C0E7D6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 09:11:40 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gf13so40278102lab.7
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:11:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si11898057wiw.7.2015.01.21.06.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 06:11:39 -0800 (PST)
Date: Wed, 21 Jan 2015 15:11:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm:
 mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off.patch is
 causing preemptible splats
Message-ID: <20150121141138.GC23700@dhcp22.suse.cz>
References: <20150121132308.GB23700@dhcp22.suse.cz>
 <CAJKOXPdgSsd8cr7ctKOGCwFTRMxcq71k7Pb5mQgYy--tGW8+_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJKOXPdgSsd8cr7ctKOGCwFTRMxcq71k7Pb5mQgYy--tGW8+_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof =?utf-8?Q?Koz=C5=82owski?= <k.kozlowski.k@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 21-01-15 15:06:03, Krzysztof KozA?owski wrote:
[...]
> Same here :) [1] . So actually only ARM seems affected (both armv7 and
> armv8) because it is the only one which uses smp_processor_id() in
> my_cpu_offset.

This was on x86_64 with CONFIG_DEBUG_PREEMPT so it is not only ARM
specific.
 
> [1] https://lkml.org/lkml/2015/1/20/162

Sorry, have missed this post.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
