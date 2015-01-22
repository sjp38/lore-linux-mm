Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BE2A56B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 22:34:30 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so32382262pde.3
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 19:34:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ob9si10708015pbb.57.2015.01.21.19.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 19:34:29 -0800 (PST)
Date: Wed, 21 Jan 2015 19:34:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm:
 mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off.patch is
 causing preemptible splats
Message-Id: <20150121193411.44f96b6c.akpm@linux-foundation.org>
In-Reply-To: <20150122015123.GB21444@js1304-P5Q-DELUXE>
References: <20150121132308.GB23700@dhcp22.suse.cz>
	<CAJKOXPdgSsd8cr7ctKOGCwFTRMxcq71k7Pb5mQgYy--tGW8+_w@mail.gmail.com>
	<20150121141138.GC23700@dhcp22.suse.cz>
	<20150121142107.e26d5ebf3340aa91759fef1f@linux-foundation.org>
	<20150122015123.GB21444@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>, Krzysztof =?UTF-8?Q?Koz=C5=82owski?= <k.kozlowski.k@gmail.com>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 22 Jan 2015 10:51:23 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > The most recent -mmotm was a bit of a trainwreck.  I'm scrambling to
> > get the holes plugged so I can get another mmotm out today.
> 
> Another mmotm will fix many issues from me. :/

I hit a wont-boot-cant-find-init in linux-next so I get to spend
tomorrow bisecting that :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
