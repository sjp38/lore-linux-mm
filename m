Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DB38C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:43:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3D5E20881
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:43:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3D5E20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506546B0003; Mon, 22 Apr 2019 10:43:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48CD86B0006; Mon, 22 Apr 2019 10:43:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32C756B0007; Mon, 22 Apr 2019 10:43:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4386B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 10:43:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u66so10595180qkh.9
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 07:43:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hKzp6G+BuD1ybxuuIBvZB41JgdLcVDTr2+aqMG7ut9E=;
        b=iam0TzjoRWcdBNaEUWUHL6j7QMvCUnuDhAFSa1EBVvzOdCH5LlbY68pMABhdPNe0sG
         UpmY0z87e14tEkANnb/FeT32xIIRO7Z7k8HeEsahhIftBglMgS96oDz8DI+iIdkBS/So
         pzq2BNQRItOYVo3j+andC8RDJBdbKnIfJTX1ExZMpDjcUlWIhpl//vmiX1c54v1qwLio
         XdXh0Q/HyrhftE53YkRAZmYU0l3zJ3qYvzGszVL+Us6nV2+Vgm9WdZ2ToMqNqUTcGkAn
         EktrTqIADVOAylleI9lDTRGJSjDUecfmZI86kR3Jp1sue/RitNGm21eeI4/r13wDwLrz
         rvwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW5xq5WO6kKhiGhqSyAffe/rgAYbAvjLzZe39a5BNtfp0cQKD81
	l/jmCkLqz+yIZpu29O8RTpHPV3aJB28KZ6a9X2+d7Psdo61nKDfIG4edskg6SCH/TUNHsTfUWXd
	falIg+RHOBGGZYYLK51mfAiBc6obx2JhHbzUmtMXBNHmTED9Tq4GUQmETre52yauMWg==
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr15785681qvc.37.1555944226755;
        Mon, 22 Apr 2019 07:43:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUJs3HDusGXcegDZ4ZK2Ij05I8gasHuS1ZwTmairGP/YedrlIzMPQ+4kbjQTOFaHYIO5vn
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr15785618qvc.37.1555944225751;
        Mon, 22 Apr 2019 07:43:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555944225; cv=none;
        d=google.com; s=arc-20160816;
        b=lWMPbr+1/pSeg3Xt/wZ2TnaabIsGai6VxYUafWLAPqtxp0FBx2YX023MC02FEZ5bOp
         9+eqmyXDWMfDcUAvNmab0oYcP0eIJW+dxFWbGznINOg+LGJ1WGBSwAqXMyJ0b/7zba3/
         wajnV/ua0wE2c8dvWrGzo43WqS5I+MacYABQFYe2HMprFDjQYBIeMIBgWmQCJ7GUjILr
         idPSWqW34XVdd0nuyKuP16vVrFhmb4Dn5Hvbr7RMr0L43vFVs0NMarFQBx79igjDnL/H
         sWEIuKBT8E575f56v2weL7Bs6xiM2E2PkIEJqEWcsmXEPN7AefCP3iD7r4mttZ/7LNnk
         ZUgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=hKzp6G+BuD1ybxuuIBvZB41JgdLcVDTr2+aqMG7ut9E=;
        b=BDJ+yD+O94DmExIIhYaxIzi6G1Ixn0W6wimA3f+xu1XonPiv72tdhZLcNZ4Y2xxKYS
         UAw9BAcnhVSbLRmLwnroiwD1J5JMg787Jh4lYVF2Mpvqllw1dZBpzq/29J0zPyev1FW3
         nL5HadAHiyJMII4Oy/5bv0+En8G5WPwsOs2vW8DnK1prXJc1HC3jdWwKHdu8H9Jkm23S
         p01qYyuUOVYkvEQpIPVfINtxoD3k/zekI8IKLypvsgo5Kn1udbjmib4KzNlr9MBJwJZf
         YiGD9NzSVdVmjD81aM6ROyBGEP5kNiwL/a3rLcY1tBH4/+D7Aiaf5BRkajJyLiVF1OS1
         0Dyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q51si3172696qvc.222.2019.04.22.07.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 07:43:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0FD6830917EF;
	Mon, 22 Apr 2019 14:43:44 +0000 (UTC)
Received: from carbon (ovpn-200-19.brq.redhat.com [10.40.200.19])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6F12161D06;
	Mon, 22 Apr 2019 14:43:35 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:43:33 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Michal Hocko <mhocko@kernel.org>, Brendan Gregg
 <brendan.d.gregg@gmail.com>
Cc: brouer@redhat.com, Pekka Enberg <penberg@iki.fi>, "Tobin C. Harding"
 <me@tobin.cc>, Vlastimil Babka <vbabka@suse.cz>, "Tobin C. Harding"
 <tobin@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph
 Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo
 <tj@kernel.org>, Qian Cai <cai@lca.pw>, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Alexander Duyck
 <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190422164333.4e838ad6@carbon>
In-Reply-To: <20190417133852.GL5878@dhcp22.suse.cz>
References: <20190410024714.26607-1-tobin@kernel.org>
	<f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
	<20190410081618.GA25494@eros.localdomain>
	<20190411075556.GO10383@dhcp22.suse.cz>
	<262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
	<20190417105018.78604ad8@carbon>
	<20190417133852.GL5878@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 22 Apr 2019 14:43:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019 15:38:52 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 17-04-19 10:50:18, Jesper Dangaard Brouer wrote:
> > On Thu, 11 Apr 2019 11:27:26 +0300
> > Pekka Enberg <penberg@iki.fi> wrote:
> >   
> > > Hi,
> > > 
> > > On 4/11/19 10:55 AM, Michal Hocko wrote:  
> > > > Please please have it more rigorous then what happened when SLUB was
> > > > forced to become a default    
> > > 
> > > This is the hard part.
> > > 
> > > Even if you are able to show that SLUB is as fast as SLAB for all the 
> > > benchmarks you run, there's bound to be that one workload where SLUB 
> > > regresses. You will then have people complaining about that (rightly so) 
> > > and you're again stuck with two allocators.
> > > 
> > > To move forward, I think we should look at possible *pathological* cases 
> > > where we think SLAB might have an advantage. For example, SLUB had much 
> > > more difficulties with remote CPU frees than SLAB. Now I don't know if 
> > > this is the case, but it should be easy to construct a synthetic 
> > > benchmark to measure this.  
> > 
> > I do think SLUB have a number of pathological cases where SLAB is
> > faster.  If was significantly more difficult to get good bulk-free
> > performance for SLUB.  SLUB is only fast as long as objects belong to
> > the same page.  To get good bulk-free performance if objects are
> > "mixed", I coded this[1] way-too-complex fast-path code to counter
> > act this (joined work with Alex Duyck).
> > 
> > [1] https://github.com/torvalds/linux/blob/v5.1-rc5/mm/slub.c#L3033-L3113  
> 
> How often is this a real problem for real workloads?

First let me point out that I have a benchmark[2] that test this
worse-case behavior, and micro-benchmark wise it was a big win.  I did
limit the "lookahead" based on this benchmark balance/bound worse-case
behavior.

 [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test03.c#L4-L8

Second, I do think this happens for real workloads. As production
systems will have many sockets where SKBs (SLAB objects) can be queued,
and an unpredictable traffic pattern, that could cause this "mixed"
SLAB-object from different pages. The skbuff_head_cache size is 256 and
is using a order-1 page (8192/256=) 32 objects per page.  Netstack bulk
free mostly happens from (DMA) TX completion which have ring-sizes
usually between 512 to 1024 packets, although we do limit bulk free to
64 objects.


> > > For example, have a userspace process that does networking, which is 
> > > often memory allocation intensive, so that we know that SKBs traverse 
> > > between CPUs. You can do this by making sure that the NIC queues are 
> > > mapped to CPU N (so that network softirqs have to run on that CPU) but 
> > > the process is pinned to CPU M.  
> > 
> > If someone want to test this with SKBs then be-aware that we netdev-guys
> > have a number of optimizations where we try to counter act this. (As
> > minimum disable TSO and GRO).
> > 
> > It might also be possible for people to get inspired by and adapt the
> > micro benchmarking[2] kernel modules that I wrote when developing the
> > SLUB and SLAB optimizations:
> > 
> > [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm  
> 
> While microbenchmarks are good to see pathological behavior, I would be
> really interested to see some numbers for real world usecases.

Yes, I would love to see that too, but there is a gap between kernel
developers with the knowledge to diagnose/make-sense of this, and
people running production systems...

(Cc Brendan Gregg)
Maybe we should create some tracepoints that makes it possible to
measure, e.g. how often SLUB fast-path vs slow-path is hit (or other
behavior _you_ want to know about), and then create some easy to use
trace-tools that sysadms can run.  I bet Brendan could write some
bpftrace[3] script that does this, if someone can describe what we want
to measure...

[3] https://github.com/iovisor/bpftrace

 
> > > It's, of course, worth thinking about other pathological cases too. 
> > > Workloads that cause large allocations is one. Workloads that cause lots 
> > > of slab cache shrinking is another.  
> > 
> > I also worry about long uptimes when SLUB objects/pages gets too
> > fragmented... as I said SLUB is only efficient when objects are
> > returned to the same page, while SLAB is not.  
> 
> Is this something that has been actually measured in a real deployment?

This is also something that would be interesting to have a tool for,
that can answer: how fragmented are the SLUB objects in my production
system(?)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

