Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12975C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 23:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF8A52064A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 23:20:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="o0QO+B7F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF8A52064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4582A6B0003; Thu,  2 May 2019 19:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408816B0005; Thu,  2 May 2019 19:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CEDA6B0007; Thu,  2 May 2019 19:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 055666B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 19:20:17 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h13so1752542otq.2
        for <linux-mm@kvack.org>; Thu, 02 May 2019 16:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vaw/ORyOIX+LivDFjdzavvVFdSzrsfQ8T1otSWpVSIU=;
        b=eQAZnj4lNVwy5PctI4Ac4b/az24b4xq3zE95jLB5Zz0NH26qKCoMvDMzPH5JAsRGMY
         mrxFO4uk11s9MVcKVCy0qmvx0lhGGxaocgJF8EwjK+FYb4erFPgIoRArZ+vaOI2PC1Ih
         EsOAKYSUQc/efTf2l09o4oCXJnfom1JBlaE5bW1gX+tOCIOj6Vyq7lH0Rq1tBBXkpA0w
         2hHb8qZGf1fDg3jYDuqUge8rZBZIeCiLvBbYbeJXl4dhZGPwWPsYASRrl2GkqHyfgn+g
         AYfd1w9AjwrL27zFfHw967Qg2weChKXoZO9/qGx8isr6S49h/FPvgrUu3Q12/IZ/a4gI
         n+8w==
X-Gm-Message-State: APjAAAVSz0vCGbUTrprRGFSRBen6Xje3UisyygBAS6qcaFlEMg+LIBOR
	q8sXQ6n8Z5ewjH2+Ac/Y6P2+eZGxxHLl3v9kWbHr+m8O3ulLNq5gMbquvbT8E5g2DpWWBoEFEWJ
	5pH5+64McgG2WCNQl6CK6pILFW/tNIUhbGvZyfjaCCo9Kdied87OUcKnfq9AfzFeHIw==
X-Received: by 2002:aca:61c3:: with SMTP id v186mr4251143oib.27.1556839216576;
        Thu, 02 May 2019 16:20:16 -0700 (PDT)
X-Received: by 2002:aca:61c3:: with SMTP id v186mr4251100oib.27.1556839215742;
        Thu, 02 May 2019 16:20:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556839215; cv=none;
        d=google.com; s=arc-20160816;
        b=Qb+GtMtQigQHv2ZFa9i89ywLv3DnDnV2SmThwgK9AjeJINVsOaKwiqQoB2YThhl3Q1
         fe9nspUZfCX7/sqopdJpmztFMeyyZCnl44mlQN4QzEWN0xiy8TEPuidwOY/xUu2h5W4c
         zkEGkUb0w8Hu8fvCNJ9EiJ85xdeSmcdo9XU/+Wg+y1eA0/yH3SyNyvrltFArq9upcAi/
         lPWTPnlgIhqJoVT/nGTDYFzHkIbT/+JF05V69n4bj1LgYrKTOwIi7bo5KLo3LPid3/yJ
         F6ogWvGf/jNhp3LJ/52+3rkvc4qb0RKpSRaCehIGqdKXKsh73xbETrVJoQD21wJ6Jq9m
         j+Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vaw/ORyOIX+LivDFjdzavvVFdSzrsfQ8T1otSWpVSIU=;
        b=VfTTB03dE3xVHO0dVfCQfRUCDoy3p42yBzDVsvkHINDmf+vz6DQWHiWy1W7+WF/eLi
         /29NaYtyuNK9jlUA1x2O2thVAgUZSeQG0jQLLDjDBy2DiFMGjR5pX/pF0jE6x4Vs9Ln1
         WCwA/krfqUZ4+xsJMOHPB40NrsJQJpVtH9tqeAU91+YE5DuvJSzUWURzRwSSArXtegZ5
         E5YU86FrpNgiruTySjj+y8zWCM+JeHYKMa8r3s5cyOt2Cm8tiRtnDF/89eFfXodjz6Sc
         xrCc7B6cBejrgaeDoplR1jQvmAcd7RLZ97ZEW2KOlwPHtJXmSSaWSmyxxMDXYWpHDPB7
         6T6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=o0QO+B7F;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u127sor215494oib.153.2019.05.02.16.20.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 16:20:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=o0QO+B7F;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vaw/ORyOIX+LivDFjdzavvVFdSzrsfQ8T1otSWpVSIU=;
        b=o0QO+B7FpHVFXwLKbb17bFFqRW1e+qzOjokLhCa27tCA1lJSASdWhA4P/c4NjmHrqa
         GOOsRFhnMSC4lUYLJvgInQ6SVvEFblUsDEPZ8ydtIHrpEPx3GuSL/RdaPG2JoFOe4NEe
         hZl/zdyQUbrHeQuzhQYwqG1rNDOKwqDmtTeAsyxa+01dfkWFPMTmg8v6VfafeW0LRWoY
         eKOtN2mSnXVe4884pA8yQaBlyW7qSdHDi5TOp8WB42EmRk2DFs+J7zvgxkCbO0IJMGye
         k2byHYMgYhgXNQtcT2yeAEvkkg0b+TAfCF2UzrtO+4BxVi0uTXN0nuyzPTimga99l9js
         BHKA==
X-Google-Smtp-Source: APXvYqyR93jgYdljX7eIKXZzIfYL0esJbUsyTF/5NB+UbuV9bKgSCs+g8m9GOZjm7n5rkAFiUqQBlviACfilFseyMts=
X-Received: by 2002:aca:de57:: with SMTP id v84mr4398622oig.149.1556839214939;
 Thu, 02 May 2019 16:20:14 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bBT=goxf5KWLhca7uQutUj9670aL9r02_+BsJ+bLkjj=g@mail.gmail.com>
In-Reply-To: <CA+CK2bBT=goxf5KWLhca7uQutUj9670aL9r02_+BsJ+bLkjj=g@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 2 May 2019 16:20:03 -0700
Message-ID: <CAPcyv4gWZxSepaACiyR43qytA1jR8fVaeLy1rv7dFJW-ZE63EA@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 3:46 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>
> Hi Dan,
>
> How do you test these patches? Do you have any instructions?

Yes, I briefly mentioned this in the cover letter, but here is the
test I am using:

>
> I see for example that check_hotplug_memory_range() still enforces
> memory_block_size_bytes() alignment.
>
> Also, after removing check_hotplug_memory_range(), I tried to online
> 16M aligned DAX memory, and got the following panic:

Right, this functionality is currently strictly limited to the
devm_memremap_pages() case where there are guarantees that the memory
will never be onlined. This is due to the fact that the section size
is entangled with the memblock api. That said I would have expected
you to trigger the warning in subsection_check() before getting this
far into the hotplug process.
>
> # echo online > /sys/devices/system/memory/memory7/state
> [  202.193132] WARNING: CPU: 2 PID: 351 at drivers/base/memory.c:207
> memory_block_action+0x110/0x178
> [  202.193391] Modules linked in:
> [  202.193698] CPU: 2 PID: 351 Comm: sh Not tainted
> 5.1.0-rc7_pt_devdax-00038-g865af4385544-dirty #9
> [  202.193909] Hardware name: linux,dummy-virt (DT)
> [  202.194122] pstate: 60000005 (nZCv daif -PAN -UAO)
> [  202.194243] pc : memory_block_action+0x110/0x178
> [  202.194404] lr : memory_block_action+0x90/0x178
> [  202.194506] sp : ffff000016763ca0
> [  202.194592] x29: ffff000016763ca0 x28: ffff80016fd29b80
> [  202.194724] x27: 0000000000000000 x26: 0000000000000000
> [  202.194838] x25: ffff000015546000 x24: 00000000001c0000
> [  202.194949] x23: 0000000000000000 x22: 0000000000040000
> [  202.195058] x21: 00000000001c0000 x20: 0000000000000008
> [  202.195168] x19: 0000000000000007 x18: 0000000000000000
> [  202.195281] x17: 0000000000000000 x16: 0000000000000000
> [  202.195393] x15: 0000000000000000 x14: 0000000000000000
> [  202.195505] x13: 0000000000000000 x12: 0000000000000000
> [  202.195614] x11: 0000000000000000 x10: 0000000000000000
> [  202.195744] x9 : 0000000000000000 x8 : 0000000180000000
> [  202.195858] x7 : 0000000000000018 x6 : ffff000015541930
> [  202.195966] x5 : ffff000015541930 x4 : 0000000000000001
> [  202.196074] x3 : 0000000000000001 x2 : 0000000000000000
> [  202.196185] x1 : 0000000000000070 x0 : 0000000000000000
> [  202.196366] Call trace:
> [  202.196455]  memory_block_action+0x110/0x178
> [  202.196589]  memory_subsys_online+0x3c/0x80
> [  202.196681]  device_online+0x6c/0x90
> [  202.196761]  state_store+0x84/0x100
> [  202.196841]  dev_attr_store+0x18/0x28
> [  202.196927]  sysfs_kf_write+0x40/0x58
> [  202.197010]  kernfs_fop_write+0xcc/0x1d8
> [  202.197099]  __vfs_write+0x18/0x40
> [  202.197187]  vfs_write+0xa4/0x1b0
> [  202.197295]  ksys_write+0x64/0xd8
> [  202.197430]  __arm64_sys_write+0x18/0x20
> [  202.197521]  el0_svc_common.constprop.0+0x7c/0xe8
> [  202.197621]  el0_svc_handler+0x28/0x78
> [  202.197706]  el0_svc+0x8/0xc
> [  202.197828] ---[ end trace 57719823dda6d21e ]---
>
> Thank you,
> Pasha

