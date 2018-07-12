Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29EE56B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:32:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5-v6so2815700edh.16
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 05:32:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o11-v6si2069871edi.441.2018.07.12.05.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 05:32:29 -0700 (PDT)
Date: Thu, 12 Jul 2018 14:32:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180712123228.GK32648@dhcp22.suse.cz>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
 <20180711124008.GF2070@MiWiFi-R3L-srv>
 <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
 <20180712060115.GD6742@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712060115.GD6742@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, vbabka@suse.cz, mgorman@techsingularity.net

On Thu 12-07-18 14:01:15, Chao Fan wrote:
> On Thu, Jul 12, 2018 at 01:49:49PM +0800, Dou Liyang wrote:
> >Hi Baoquan,
> >
> >At 07/11/2018 08:40 PM, Baoquan He wrote:
> >> Please try this v3 patch:
> >> >>From 9850d3de9c02e570dc7572069a9749a8add4c4c7 Mon Sep 17 00:00:00 2001
> >> From: Baoquan He <bhe@redhat.com>
> >> Date: Wed, 11 Jul 2018 20:31:51 +0800
> >> Subject: [PATCH v3] mm, page_alloc: find movable zone after kernel text
> >> 
> >> In find_zone_movable_pfns_for_nodes(), when try to find the starting
> >> PFN movable zone begins in each node, kernel text position is not
> >> considered. KASLR may put kernel after which movable zone begins.
> >> 
> >> Fix it by finding movable zone after kernel text on that node.
> >> 
> >> Signed-off-by: Baoquan He <bhe@redhat.com>
> >
> >
> >You fix this in the _zone_init side_. This may make the 'kernelcore=' or
> >'movablecore=' failed if the KASLR puts the kernel back the tail of the
> >last node, or more.
> 
> I think it may not fail.
> There is a 'restart' to do another pass.
> 
> >
> >Due to we have fix the mirror memory in KASLR side, and Chao is trying
> >to fix the 'movable_node' in KASLR side. Have you had a chance to fix
> >this in the KASLR side.
> >
> 
> I think it's better to fix here, but not KASLR side.
> Cause much more code will be change if doing it in KASLR side.
> Since we didn't parse 'kernelcore' in compressed code, and you can see
> the distribution of ZONE_MOVABLE need so much code, so we do not need
> to do so much job in KASLR side. But here, several lines will be OK.

I am not able to find the beginning of the email thread right now. Could
you summarize what is the actual problem please?
-- 
Michal Hocko
SUSE Labs
