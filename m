Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6FE3C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:24:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6299B217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:24:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6299B217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F13B56B0005; Thu, 18 Apr 2019 17:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9C336B0006; Thu, 18 Apr 2019 17:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D65BD6B0007; Thu, 18 Apr 2019 17:24:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1A76B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:24:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d15so2070224pgt.14
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:24:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mHZVDH+/kvkLagi0jvAER50aM/ZCH5BsopbdyKUul4c=;
        b=rQJW3ghwa2dK2M8sgNG/605XfRkDLecZaRUNNMyLEiILbiFvW6wEdC5KiquE4A7tGD
         s05v4PCo4VQZsR5cdkt7lAPQli/iAgCqELhIspwtE5QqOzcVoh4FcVfbH0VH6qqYXglE
         FMX8TQ9xj2RHt6pajbBjrhgdUesYPxpNp9xXcWXpVJrp8cEqh4Tu7jkOZi8b/ll6zQdZ
         yjpNjU9m8zRp0Axh4NqL3EnOuLsWqh8cS0opfrujI6gLHaIoZ/yrR1gcmL10Pn8bDiLV
         MXho2hKCxJblNmddHVdMYItzlW01Kq1FV0m1OKFQ7KJrkMT9EoCUoSSwACd7OMROCZ32
         XkWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAVrUY+A3lxxO8dQZn1ETdlU2SjaykS6UHIb7M5CzHscxp7jfand
	lBMpOqhDsdp9gsmQTCcn6SwBMa6ppVkLffJf+ws/lw5j+yCBu5tl+cVvlxt5stdtEegQN0loi6s
	STLHq+7r1qlEBkWZdFA7p2vNId30B0l57s/nKRJRqgVI4D3AxnOgJIZupr/YG5J4=
X-Received: by 2002:a65:6282:: with SMTP id f2mr174262pgv.152.1555622690185;
        Thu, 18 Apr 2019 14:24:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC/kuztseuT93xmfG/BmWlM/CgMhVpETACi9ZEqOXODpzatePD5K6UGaXiAP+wNZmpq0wb
X-Received: by 2002:a65:6282:: with SMTP id f2mr174218pgv.152.1555622689468;
        Thu, 18 Apr 2019 14:24:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555622689; cv=none;
        d=google.com; s=arc-20160816;
        b=y1qdqhLmwG+Ilo5B4aMNs/YRUvZLNrBct/4XGsG0qO2RzM9d6J8iIxPWQy03exPJ4v
         IAfiNf0uxN2Jd2QK4C2hVmN+Gw4XdoARWFU90waail6s667Xh+heMLD7HNZ6Q7Toy8oF
         wiFOM18AslKNM9StA/SOgosIEWpnkUvJPMuamP71sBCbGOq2bPqxgUEeL9GHQcymLLOC
         bDhGZAvbTIqR64HnnIExOT00kqUnXHnGnoP3abiHF9WX6eNa/jjkAd3WzhsjZNrUnJhR
         Jj8pdYbqGbvHOEjXszxenkt+GqRh/cRUXCNIEDHo1jjPxXLbLt6ZDy/3ItzbohgmA8h2
         KXew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=mHZVDH+/kvkLagi0jvAER50aM/ZCH5BsopbdyKUul4c=;
        b=Pow8BQPopSnfzzTtqgZUUx2OkN5f9MD3EFmzKh2XrJzGFWhNhbsdQjcrftpYl/aR1m
         iOlNr2eRLu39lvL2EN04/hGpT4uAsynlC/DtnHalbrDi6fA9QCYJEtuAHxrCfCOO14Kj
         Dv1JGyM2dPg3KNrS4Wl2ScagyfLzIGDTGoqC2L4FpWqHVdov0W97cpjsKUzdP14qzIbA
         UzU43tLtixDH+MzFTyObUpNNiIVTZMLXk24WnxX+hm+Sb4M0fiHoZd7WMcyn43ufTPRk
         xXeHFwpi4UChi5F0rq7MZZb0ZFz4KGfmeWy/2tf6DiSxfZcARcgA3Uwvmuj7korLY5Zy
         ZUQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k91si3274967pld.87.2019.04.18.14.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:24:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DB27A205ED;
	Thu, 18 Apr 2019 21:24:45 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:24:43 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, x86@kernel.org, Andy Lutomirski
 <luto@kernel.org>, Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
Message-ID: <20190418172443.30ec83e3@gandalf.local.home>
In-Reply-To: <alpine.DEB.2.21.1904182313470.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084253.142712304@linutronix.de>
	<20190418135721.5vwd6ngxagrrrrtt@treble>
	<alpine.DEB.2.21.1904182313470.3174@nanos.tec.linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 23:14:45 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 18 Apr 2019, Josh Poimboeuf wrote:
> 
> > On Thu, Apr 18, 2019 at 10:41:20AM +0200, Thomas Gleixner wrote:  
> > > - Remove the extra array member of stack_dump_trace[]. It's not required as
> > >   the stack tracer stores at max array size - 1 entries so there is still
> > >   an empty slot.  
> > 
> > What is the empty slot used for?  
> 
> I was trying to find an answer but failed. Maybe it's just historical
> leftovers or Steven knows where the magic is in this maze.
>

I believe it was for historical leftovers (there was a time it was
required), and left there for "paranoid" sake. But let me apply the
patch and see if it is really needed.

-- Steve

