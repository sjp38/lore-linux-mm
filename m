Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C66B9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F0F02080F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:18:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="bmWmtlOA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F0F02080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DEF36B0007; Mon, 25 Mar 2019 19:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18EEC6B0008; Mon, 25 Mar 2019 19:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0569A6B000A; Mon, 25 Mar 2019 19:18:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0A996B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:18:17 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w139so4514248oiw.21
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BDLk+jh0wm55D8ztyKQQjdMiusc96JMbtw9zCEj3y6A=;
        b=OMdWS7gCMz0QJ1z8vytjocpf7qM7jpaBlb1Cy6XetSJtLgMTw4b5ym/UvSrToWc5ps
         ORe6Uqz/5+aX1Aft4DDh59P7el++bTHHNibZZm4ETCOEr0ItxxpQJv03PsEabiWQB69l
         TnCRiZQnSz1e4QhPvmDGTqEXTXOHYo9w2dQ3jprbljKgi+hfG5s4+e451SqwjxYp63f/
         pV/Wyl+l8K5eGJh7+whw/e9oZVD8suEre7ReaF6KQ/i3a5Iz+VETBQ4+j09RSbyCq3WE
         T57zhPTwR7HOkcCYnpadFwiNukKoUVLnXrv9in7Ilgf2NUwKNtgercSY7y6/dbaDTZWr
         QTwA==
X-Gm-Message-State: APjAAAUWPwnHnc35g2KQ2PguD+qfTF41OualXfir7dZUSB9pZTZR/OzT
	C2Z1oo+oWyLizx5qG7r6l/Y82xZb7oY5vmqXPM6at3KkzxpzQs0Q+ayVGjCIGqR3jTnVT5C7lAP
	CmbHp6NyJ3AFJRpxQDbEpL/e+awGXAtkNO/Goxdj+BvMA04xSt24xqCtJi6ypJemkNA==
X-Received: by 2002:aca:e689:: with SMTP id d131mr3370556oih.132.1553555897381;
        Mon, 25 Mar 2019 16:18:17 -0700 (PDT)
X-Received: by 2002:aca:e689:: with SMTP id d131mr3370524oih.132.1553555896573;
        Mon, 25 Mar 2019 16:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553555896; cv=none;
        d=google.com; s=arc-20160816;
        b=o+IhXSkglBxRfVGZNyscXOIBel7bZTRp9McOI04gMn2DW7U7ShMdovBQkMsbriLxbI
         lcz5vZrkRC7QsuD6GpZgAoO/2bnkSDN5uant8cmUQJ7dN1Dr3uzB8rr4Af1K8lf388he
         A4XxL+Ytcg2N10fUGmikE3Gm+uDoDVawzSJyxmgSeHKH9KoPSkH9lZov45DxVELWqKK3
         8YKvdG5ta/w1Wud5WN4bEGvwg8z6m6u6AvNuO3Na0Lhg/J3jmBiBDBpJeL8I6zwrheBy
         Cj+WIURn+dmH86UlLfsY9KV6kZdceIMqHtFcdAgq80wbG1E40za9AEmwjqGyIfPGaQgI
         MYcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BDLk+jh0wm55D8ztyKQQjdMiusc96JMbtw9zCEj3y6A=;
        b=cCDlNlFzRa7hrqgMIAiYcCzmMEbE/jbLj4c+YCZT9LFRoq8s1r/1Lo7BJVAQzaNekq
         25pOcbqAxoAZOT7nNqmoGi5YXru7vI4y3vGL75qEg1xltWwPBtTsFbv0t7cUa0yHjDPL
         Tk88O7+h6AIhrlpTU95twU6yAVrGpoDJxDegLC9Cu71zMkR1nEeAm0zK1QYsFSPBUig0
         10stc7T1U6oQZ8u7mZaZPU1DNSzX/ZlZpsboXdjuAPto9CxU0KHXZUPof8eWE7+Uot9J
         2BkxnSG4Fd7LyZtd1yQQr2uPpftjsFKyuEIMwdst19Uqsd/avBLZmEpeLXh4/YZlHDSE
         5HQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bmWmtlOA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l25sor8428805otp.122.2019.03.25.16.18.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 16:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bmWmtlOA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BDLk+jh0wm55D8ztyKQQjdMiusc96JMbtw9zCEj3y6A=;
        b=bmWmtlOAfTKBgIkAV4K73DnNnvKLXfnnZaIk5Csh5dgshTgCKm/M1xryTKHq9HRx+9
         dhfR0DJy4SFcZfYzPjzPO1tzxGr8+/UqlIdiLnFC4QxVfnB2Zboaw9Po9hneBmzjsojy
         09UJ+4jx2az1c121Hp4cjizVAdaTIimVGF34xvc1vHZnfd79kxZJl7peyySjd17HEFzJ
         M5jpsWKZEjrkYQu6gVasCkWeZPtpUR5rZXHi+uByOGwSYMEGb1EPOGw119GsMJ4WqjDd
         Q4AJrkeVaRNCtcEndaloOGysrz1p2xFiifiUH1ZzTZOFMqykD97ylfpbTFs3oSmM+27Z
         K+Rg==
X-Google-Smtp-Source: APXvYqxsQkP9wLF6Yl5w1yQJ8nJBIcMw0TELYRMa6MegAkNnD+70dwmUNmfysSws+BWUu5Xm2PiqA2KHF8fLGkQux1k=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr20779320ota.214.1553555896212;
 Mon, 25 Mar 2019 16:18:16 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
 <CAPcyv4g5RoHhXhkKQaYkqYLN1y3KavbGeM1zVus-3fY5Q+JdxA@mail.gmail.com> <688dffbc-2adc-005d-223e-fe488be8c5fc@linux.alibaba.com>
In-Reply-To: <688dffbc-2adc-005d-223e-fe488be8c5fc@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 16:18:04 -0700
Message-ID: <CAPcyv4g3xzuS8hP9jOX_BXWyFEH32YfCEDs3a_K_VRODfATc=Q@mail.gmail.com>
Subject: Re: [PATCH 01/10] mm: control memory placement by nodemask for two
 tier main memory
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 12:28 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
>
> On 3/23/19 10:21 AM, Dan Williams wrote:
> > On Fri, Mar 22, 2019 at 9:45 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
> >> When running applications on the machine with NVDIMM as NUMA node, the
> >> memory allocation may end up on NVDIMM node.  This may result in silent
> >> performance degradation and regression due to the difference of hardware
> >> property.
> >>
> >> DRAM first should be obeyed to prevent from surprising regression.  Any
> >> non-DRAM nodes should be excluded from default allocation.  Use nodemask
> >> to control the memory placement.  Introduce def_alloc_nodemask which has
> >> DRAM nodes set only.  Any non-DRAM allocation should be specified by
> >> NUMA policy explicitly.
> >>
> >> In the future we may be able to extract the memory charasteristics from
> >> HMAT or other source to build up the default allocation nodemask.
> >> However, just distinguish DRAM and PMEM (non-DRAM) nodes by SRAT flag
> >> for the time being.
> >>
> >> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> >> ---
> >>   arch/x86/mm/numa.c     |  1 +
> >>   drivers/acpi/numa.c    |  8 ++++++++
> >>   include/linux/mmzone.h |  3 +++
> >>   mm/page_alloc.c        | 18 ++++++++++++++++--
> >>   4 files changed, 28 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> >> index dfb6c4d..d9e0ca4 100644
> >> --- a/arch/x86/mm/numa.c
> >> +++ b/arch/x86/mm/numa.c
> >> @@ -626,6 +626,7 @@ static int __init numa_init(int (*init_func)(void))
> >>          nodes_clear(numa_nodes_parsed);
> >>          nodes_clear(node_possible_map);
> >>          nodes_clear(node_online_map);
> >> +       nodes_clear(def_alloc_nodemask);
> >>          memset(&numa_meminfo, 0, sizeof(numa_meminfo));
> >>          WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
> >>                                    MAX_NUMNODES));
> >> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> >> index 867f6e3..79dfedf 100644
> >> --- a/drivers/acpi/numa.c
> >> +++ b/drivers/acpi/numa.c
> >> @@ -296,6 +296,14 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
> >>                  goto out_err_bad_srat;
> >>          }
> >>
> >> +       /*
> >> +        * Non volatile memory is excluded from zonelist by default.
> >> +        * Only regular DRAM nodes are set in default allocation node
> >> +        * mask.
> >> +        */
> >> +       if (!(ma->flags & ACPI_SRAT_MEM_NON_VOLATILE))
> >> +               node_set(node, def_alloc_nodemask);
> > Hmm, no, I don't think we should do this. Especially considering
> > current generation NVDIMMs are energy backed DRAM there is no
> > performance difference that should be assumed by the non-volatile
> > flag.
>
> Actually, here I would like to initialize a node mask for default
> allocation. Memory allocation should not end up on any nodes excluded by
> this node mask unless they are specified by mempolicy.
>
> We may have a few different ways or criteria to initialize the node
> mask, for example, we can read from HMAT (when HMAT is ready in the
> future), and we definitely could have non-DRAM nodes set if they have no
> performance difference (I'm supposed you mean NVDIMM-F  or HBM).
>
> As long as there are different tiers, distinguished by performance, for
> main memory, IMHO, there should be a defined default allocation node
> mask to control the memory placement no matter where we get the information.

I understand the intent, but I don't think the kernel should have such
a hardline policy by default. However, it would be worthwhile
mechanism and policy to consider for the dax-hotplug userspace
tooling. I.e. arrange for a given device-dax instance to be onlined,
but set the policy to require explicit opt-in by numa binding for it
to be an allocation / migration option.

I added Vishal to the cc who is looking into such policy tooling.

> But, for now we haven't had such information ready for such use yet, so
> the SRAT flag might be a choice.
>
> >
> > Why isn't default SLIT distance sufficient for ensuring a DRAM-first
> > default policy?
>
> "DRAM-first" may sound ambiguous, actually I mean "DRAM only by
> default". SLIT should just can tell us what node is local what node is
> remote, but can't tell us the performance difference.

I think it's a useful semantic, but let's leave the selection of that
policy to an explicit userspace decision.

