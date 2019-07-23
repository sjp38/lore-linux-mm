Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D2DC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:25:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B5221849
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:25:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="n21hbjdI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B5221849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370B38E0002; Tue, 23 Jul 2019 10:25:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB0C6B000D; Tue, 23 Jul 2019 10:25:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9728E0002; Tue, 23 Jul 2019 10:25:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA2726B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:25:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so26298925pfi.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:25:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wJZ801ANBKnPIKQYwYJaIw5FVuF7oY1lEYc4x9KCGg8=;
        b=YBolS4F+kdCg5IOWbJCfxr7d7TbrlN5wdIX6xjyyEVJH0InElUz2GaOIpdDA/fBJJs
         4reJq7gwgYm/6BGmYeNYeUCKxJw5QbuXg+wL4ByiV49Aki4yJEIm8PyJwL6IArRHZ0xm
         1WbQeWF2wttbDvTKOC/GsVkfYvBnLnIItLGEJFZsL8ZE7VGhS4Hpx9fQBpN6oFBbRqOa
         JykqBvMd1Piar9bIjA/qS1itVTTFvW/62YokDZMipJKTOqvE3/AzpVD0qDT57EsbarIm
         cSfhxqsPvuiQXC81m2KdfKDI1RiO49G4iP1g9pajkOuWFI+3kx/7kbApKeJXR27TxVlK
         UmmQ==
X-Gm-Message-State: APjAAAX5trl3LIURtL58ELAEEE9+36bbowGcGLJfJ/QoOW44wLV/v1oO
	cv/bRrDSYrpexwVoa+UR4lB+D2v9zHy6JNE82xduG5zdbFV0JRx8zCl9FCuZkXTxk49UkxlrGZh
	8KjgNHxauewUUExlSzoSz1qrmGN4FdOEv6EhmdDwVpZ/xphEAvF+nvyrWDf0CyrQvEg==
X-Received: by 2002:a63:1046:: with SMTP id 6mr78859893pgq.111.1563891950453;
        Tue, 23 Jul 2019 07:25:50 -0700 (PDT)
X-Received: by 2002:a63:1046:: with SMTP id 6mr78859839pgq.111.1563891949752;
        Tue, 23 Jul 2019 07:25:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563891949; cv=none;
        d=google.com; s=arc-20160816;
        b=a2N3be46adJEalqsRCvDVvmuJhT3O2FFfsVSWfGPEEXff8osjEuj/v4CJpVt91yXEb
         k20M+t9y+cHCDGwGrhWlwR062BYwJyfMK8RjoV9WPCOd01b67J2hQx/W7QrkOm+AH76k
         2YmqHT6hVFCcHdiqaP2asENZGDSkXvNs7VOpC9IG9KYmykej428fUC3s0w7gio6iMTLM
         qDPe/80YUBNHCje7HR7rERJBo5WKuVsjfrA9+p95a8yR/XgMWhdIfp6XPs0vBp80poZN
         hS5TLB/5i72rh+yoLi5wRK2M6iplSlAOpJTsfIIsFg+0SeWwgRgwH3nEAONZiPhauehm
         S10Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wJZ801ANBKnPIKQYwYJaIw5FVuF7oY1lEYc4x9KCGg8=;
        b=C4Zb6FOKcgJ8ief/tc0PRw27pZbb0bR/yJc8i3O4WyXL4dnwSKwYY5AGKnbQGxWav2
         lKFCRzCMFkeku4XDr2ghEPPmVtN4m7hTTFZEiDej3SWehLjP3pdaGkxx9uLGdivHr4yR
         yqqBMAUE3FMOHmk/qkQ8XqxUhacRb3qESzfQs0iJp+vPCvM/nouSnEwA99wUZTzVAzUk
         RTV36JyNVA0XuhWRApCK3kv/8uvizl12bsPf/S4YqUP61jCXEItcF9KXk/DfZE9Do/fI
         5iiUwsGvMq0p0Dv0vGdrt9eEbCYUHCdTsEYtoZnIX5ruJSO7v2CZY737k/m0IKtiVMNy
         nwDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=n21hbjdI;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor43200194plc.47.2019.07.23.07.25.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 07:25:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=n21hbjdI;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wJZ801ANBKnPIKQYwYJaIw5FVuF7oY1lEYc4x9KCGg8=;
        b=n21hbjdIvqGA7so7xre9KxtX9A25carBopCDVVwJ0cju9rZ3C2askKWnyx4AV63WUb
         GQqOeqF99/UITIYGwZ1M4TCxAN1tds/splo04dXVQcH4Vk3/O+CDH9c5jALBwmi129aX
         nexyLOhLqykV1k4gcufHhkE98OYvN4BYMRZ+U=
X-Google-Smtp-Source: APXvYqzTB9qvvsmDg4Qv92Ie0WxPkNg5+9vi47JkPUPkzdmySjr1W+rQOyNBacsorNKTD8yGc5TgoQ==
X-Received: by 2002:a17:902:8203:: with SMTP id x3mr81493411pln.304.1563891949369;
        Tue, 23 Jul 2019 07:25:49 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p27sm64054292pfq.136.2019.07.23.07.25.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 07:25:48 -0700 (PDT)
Date: Tue, 23 Jul 2019 10:25:47 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm/page_idle: simple idle page tracking for virtual
 memory
Message-ID: <20190723142547.GD104199@google.com>
References: <156388286599.2859.5353604441686895041.stgit@buzz>
 <20190723134647.GA104199@google.com>
 <53719394-2679-81ae-686e-c138522c0dfc@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53719394-2679-81ae-686e-c138522c0dfc@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:59:07PM +0300, Konstantin Khlebnikov wrote:
> 
> 
> On 23.07.2019 16:46, Joel Fernandes wrote:
> > On Tue, Jul 23, 2019 at 02:54:26PM +0300, Konstantin Khlebnikov wrote:
> > > The page_idle tracking feature currently requires looking up the pagemap
> > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > This is quite cumbersome and can be error-prone too. If between
> > > accessing the per-PID pagemap and the global page_idle bitmap, if
> > > something changes with the page then the information is not accurate.
> > > More over looking up PFN from pagemap in Android devices is not
> > > supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> > > the PFN.
> > > 
> > > This patch adds simplified interface which works only with mapped pages:
> > > Run: "echo 6 > /proc/pid/clear_refs" to mark all mapped pages as idle.
> > > Pages that still idle are marked with bit 57 in /proc/pid/pagemap.
> > > Total size of idle pages is shown in /proc/pid/smaps (_rollup).
> > > 
> > > Piece of comment is stolen from Joel Fernandes <joel@joelfernandes.org>
> > 
> > This will not work well for the problem at hand, the heap profiler
> > (heapprofd) only wants to clear the idle flag for the heap memory area which
> > is what it is profiling. There is no reason to do it for all mapped pages.
> > Using the /proc/pid/page_idle in my patch, it can be done selectively for
> > particular memory areas.
> > 
> > I had previously thought of having an interface that accepts an address
> > range to set the idle flag, however that is also more complexity.
> 
> Profiler could look into particular area in /proc/pid/smaps
> or count idle pages via /proc/pid/pagemap.
> 
> Selective /proc/pid/clear_refs is not so hard to add.
> Somthing like echo "6 561214d03000-561214d29000" > /proc/pid/clear_refs
> might be useful for all other operations.

This seems really odd of an interface. Also I don't see how you can avoid
looking up reverse maps to determine if a page is really idle.

What is also more odd is that traditionally clear_refs does interfere with
reclaim due to clearing of accessed bit. Now you have one of the interfaces
with clear_refs that does not interfere with reclaim. That is makes it very
inconsistent. Also in this patch you have 2 interfaces to solve this, where
as my patch added a single clean interface that is easy to use and does not
need parsing of address ranges.

All in all, I don't see much the point of this honestly. But thanks for
poking at it.

thanks,

 - Joel

