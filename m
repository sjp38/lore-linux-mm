Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43EDFC43387
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 18:28:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5B0E20866
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 18:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jUG6U8gy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5B0E20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9818E0049; Fri, 28 Dec 2018 13:28:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 299A58E0001; Fri, 28 Dec 2018 13:28:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188578E0049; Fri, 28 Dec 2018 13:28:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFA538E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 13:28:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y83so27248070qka.7
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 10:28:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OTNffT1eaQTcLAFvhNIeVKJ7Ks4jO89gQtFc2V6+jxc=;
        b=FoBaGAyhoBoVnr5FuGtYDIeRVgplJDkvyXgNwjizB9KKlWv9FwxEtKMf1DpoqOGWLj
         GBSaRwrD56MhUApzQHI0mHG5f7zpwQwvSELGszMwvsWWvHARNjdCp2W4q2dZHss5sRvr
         TLiS98eBnsq6xBT7RrK2punUdAr6V6KZJ+D30km4jm6Aw3aySvNlL9Uw8mT9ok2PmnUh
         51tYZQe8wRpoFcGBWee5hLjPkl9IG/bdddT//STI+UupLu3e3Tc1L7U9ur3/Z68A5rL+
         xiCKirXKR2ASVdYInoGMjSIR59m+zUeKnbubQZCckwMPSG1PAFz/tpBnxDWBTw0yf/8s
         jXrg==
X-Gm-Message-State: AJcUukfzgQXLRUqv4PZGdOYPQG2kdsLUIQD6Y/wYYeMIgul2aSIkPCo/
	uwlKsIvbKxDo28raZYxs19o5Q3kpCLPCg1IL5IW6hS6/7cn05XNdPo8n426nsYJQvetdKwcJX1i
	jj+iMT4WgClOkFpF8zzX90T4oCFqP+xauLyQrsdvN5bXKxGTWFwTBPBtyjsnP0LDmnyYll68WoE
	lLQJhLcaMSmv3l9JYf2tO+rcd5Q8zmTP/V17hFkLaJRrT014HL+vhsHfl+qQQPobmy6KKWI5334
	a5F+S4Oj6/fBzQ/VJqUhogpKg1pjYn3j4rD/fS2GaynBpJKlBaZKsopsbrjhbFfdHS6Iz+osmcZ
	1pVoMXPq1rO5Y00wL3mI6f5oiSVKDQKWKZbNQJ03WJnsANj+e91WNeTKKeQJF8qKmCVZiTEAZ8a
	C
X-Received: by 2002:a37:a6c2:: with SMTP id p185mr26757754qke.28.1546021723604;
        Fri, 28 Dec 2018 10:28:43 -0800 (PST)
X-Received: by 2002:a37:a6c2:: with SMTP id p185mr26757721qke.28.1546021722795;
        Fri, 28 Dec 2018 10:28:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546021722; cv=none;
        d=google.com; s=arc-20160816;
        b=yIGCuL5jyD4b1tOAcMTxb5x8TSGcxgL+o8/Hlf+954LyHyzBnmOt/qP30e7dKzxxOJ
         Qe9j4lhIsibDKEnB1O8J3KKQ6ybi13RdghVRd7FTsPKzzVdAdM8vjxi6+rb9KJCe65S+
         FbxG4ExE6FkmALXPo0syqzuLJ4h4Y+g1IAyWDP73O7YOGm40b0yfYtqHpjhjhCJWKZxU
         BtnUj2Z5mWpBOaj4cwgAiNqLBGBJ+nyel8Zwh1QdqmejJhC/G29GpSIW+5Hv+O4yB+3j
         jznAeUyemfR8eqrEHBk/3HNRrTqofrYSEWJexyaOiKnYzpAZhm/ORazu90DVY7Taiqp7
         MBaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OTNffT1eaQTcLAFvhNIeVKJ7Ks4jO89gQtFc2V6+jxc=;
        b=SPsi1ZK/7tELIEoJOGuPI8T5gTitREy5EP+Lx9Fmr6/fp7zqB2+/FqS01nn6yorJUi
         V5qJHkH2Jxv8OdQYnItR8ChzICaoF77V+PG0p3jQs6PmUT8R87MxR6t3oSEhsbDBArfY
         +4rQSrhYTGl1v/Abq+soyF9ubk2WQNF11N0hmy/IIVRoFNtn8wDFOqLxComYL7BOHAdw
         8uPxnxQ0nvgowlwrvvzrKqt1lWYFS0zlAIcljbrANW/ROBQu7V4O641/xG6SJ96ti1pL
         dQzwXqlvxXpg99eAm7Q9SW8YkKS4uE77SZWo5rXJHifcksUqZV1HmpkGn1SjmuTBoLzN
         a0Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jUG6U8gy;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor30221909qvh.26.2018.12.28.10.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 10:28:42 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jUG6U8gy;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OTNffT1eaQTcLAFvhNIeVKJ7Ks4jO89gQtFc2V6+jxc=;
        b=jUG6U8gyE0Alt4dCEEdEDk07uJSsv2AxyaUFQYbBJkEFYAu5vHDV/GiLr6INd9lez6
         0UhHUrZgwErbcyXor/OQNXMHw2EShgs/2woci1E53qGKB1Ww6jWW8TxwaexcrRy3DdDs
         aADE9YRxF2BNelhszBtKIFNWemeRmXM/yRSYY2FyxAv0J764P4bFijA+wI7xjjyY4n2x
         grcohJbASFlIP1mGO223kt6hpP4aLxKr+ddyDWBqXLz/TP2GPEqq1aG3v96dLn2QjIFe
         4W/4tQtMkMUnj8aAtkNOJCZXGmfrrlO318fs6Wh6bDPzSh31mJOdY8fNGAtTPTSgIXSo
         L2DQ==
X-Google-Smtp-Source: ALg8bN6RJdjZWgaVAH30ZoxdUdjJEqpmXXm26j1aZhLKG+0DgYFGZcwn6g8o/jfNjBK84H50M7BIgQMeXCPIJZOkxnM=
X-Received: by 2002:a0c:d29b:: with SMTP id q27mr27178531qvh.62.1546021722446;
 Fri, 28 Dec 2018 10:28:42 -0800 (PST)
MIME-Version: 1.0
References: <20181226131446.330864849@intel.com> <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com> <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com> <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
In-Reply-To: <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 28 Dec 2018 10:28:31 -0800
Message-ID:
 <CAHbLzkq91SY2s-N8sKReaQeC4z16DHsygFad4sqSzuXsZFzwQg@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness accounting/migration
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, KVM list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, 
	Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, 
	Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, 
	Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, 
	Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228182831.fOIeSiPx_jww7zji5Ox_4jioAEox9RGGXOyHw4sBwmo@z>

On Fri, Dec 28, 2018 at 5:31 AM Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> >> > I haven't looked at the implementation yet but if you are proposing a
> >> > special cased zone lists then this is something CDM (Coherent Device
> >> > Memory) was trying to do two years ago and there was quite some
> >> > skepticism in the approach.
> >>
> >> It looks we are pretty different than CDM. :)
> >> We creating new NUMA nodes rather than CDM's new ZONE.
> >> The zonelists modification is just to make PMEM nodes more separated.
> >
> >Yes, this is exactly what CDM was after. Have a zone which is not
> >reachable without explicit request AFAIR. So no, I do not think you are
> >too different, you just use a different terminology ;)
>
> Got it. OK.. The fall back zonelists patch does need more thoughts.
>
> In long term POV, Linux should be prepared for multi-level memory.
> Then there will arise the need to "allocate from this level memory".
> So it looks good to have separated zonelists for each level of memory.

I tend to agree with Fengguang. We do have needs for finer grained
control to the usage of DRAM and PMEM, for example, controlling the
percentage of DRAM and PMEM for a specific VMA.

NUMA policy sounds not good enough for some usecases since it just can
control what mempolicy is used by what memory range. Our usecase's
memory access pattern is random in a VMA. So, we can't control the
percentage by mempolicy. We have to put PMEM into a separate zonelist
to make sure memory allocation happens on PMEM when certain criteria
is met as what Fengguang does in this patch series.

Thanks,
Yang

>
> On the other hand, there will also be page allocations that don't care
> about the exact memory level. So it looks reasonable to expect
> different kind of fallback zonelists that can be selected by NUMA policy.
>
> Thanks,
> Fengguang
>

