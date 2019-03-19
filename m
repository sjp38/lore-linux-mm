Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A062DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 515F320835
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="DCeW2Qzv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 515F320835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1EFE6B0006; Tue, 19 Mar 2019 15:27:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCD226B0007; Tue, 19 Mar 2019 15:27:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBCAE6B0008; Tue, 19 Mar 2019 15:27:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5EF6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:27:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p4so27505edd.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:27:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BWsg5CP8PoG7D2KKTG0T99dvTZYhLmJCg091bzD65LQ=;
        b=tCSJAXcFxGHBhtXw9mfKrYWZK64ziYu0udmtZTfjULrFKDrE8jx03XboiTgmMv5NZI
         YaWVbBx6WaytzQnSadB2NUWaoUNAIhv6R5QdN0pFoe8amxfzUtYKo5BEIk9oAOwRNTh9
         u9jwU5XZ3rcE+wi8gmsY00fBqD/Iz8Qn85imF3YP5NRDeXrUR+V2aJBEx9OwgzWxndUC
         MOGOBlMEz26lvXvmyD8tNpSlBZltaUVoDUAViOHYPD9vUATa748/gos8qAXAHmHMdbSX
         8jpchmeAMmrvW6eWS+hXBLdPxUYTN/Bp7TTknJo6Uu3nbvTHcbUDpKC9ehGfZPP33UKh
         kHDA==
X-Gm-Message-State: APjAAAU6whEbVJjTUcc2WD33JfE8207g2Qc3BnE5qsGqatdCWSxep+Vi
	mudWWIZQDYsomZ3TstiuYWLngk/SIXlOewQiu+cOaeFgRR22/KWCptjL4czDaRAmom5m0QD31H0
	/pvnZfkg3Rh6dLZw2ScRao5BDFKuAdhvO5Igoukyd6Oqsnm1ol83CKzrhqa8EdFF5qw==
X-Received: by 2002:a17:906:905:: with SMTP id i5mr15200518ejd.23.1553023634037;
        Tue, 19 Mar 2019 12:27:14 -0700 (PDT)
X-Received: by 2002:a17:906:905:: with SMTP id i5mr15200497ejd.23.1553023633311;
        Tue, 19 Mar 2019 12:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023633; cv=none;
        d=google.com; s=arc-20160816;
        b=QynX63r6skhveUimmT3linb5x6c9dA0OxkEUj+fd99GqRSygdl1Z1qvKgrbJhb/9ad
         pkucaoDit0/KdEDbQ4C5aLa4DjkLKmotVwR7cvF+X6iAC3t+9OqhnuzuJ9yo9S4oUvGa
         o8gbaNnSXA/eZhM+uyzxfs73YU/9jgfcGm6wjjr2lWiC1noaBN+gPAd5EoYb3RAJr55Y
         8CMA+AKposQcNxyOKtL1Y3rzXcKU0hJclz5h4ONugilbIPGBTN7MVeyknKpIsSATPyG8
         gmlEnyNT3TYad18CFDQ5bRFTJHt3RvF8KNK1aA/FqjQV1ntI0l6JxCNNaMBqLGmP7B9t
         O6Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BWsg5CP8PoG7D2KKTG0T99dvTZYhLmJCg091bzD65LQ=;
        b=EEIq3fSOfu2AkioDvIkoezJFGP0ImLyo06+MhhMJf0q3AD4pBFqe/6Xy/R+dcaabZK
         CTMjGX35Uw9YtJWPMzeIPbmKz08PNV3EdqMr3GHFG5JaYL41Nt7T3dZX+7JL6kL5sMNx
         qPTTepk++wTQPlcdX1ZIb5lhQfJxkyjJGpv6GusSgcrAm0STcmM+cQQWOTERnCpmTyBA
         2oynYmoOxYH0LXSul8kbyGxx8W3vT0tnWriqKCpAVqiB2nAW2W3NKNU44N1lo1wCcS2x
         gamC4x3zkcL/0Hwe/WD79GMIdVFEEYPUYxKRKvXDlUcuWI4tWL8s2K49lrJ+VXqihU7l
         XM5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=DCeW2Qzv;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor4118185ejj.29.2019.03.19.12.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 12:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=DCeW2Qzv;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BWsg5CP8PoG7D2KKTG0T99dvTZYhLmJCg091bzD65LQ=;
        b=DCeW2QzvSSdT63W+Saa/nnpLIZXHYkjKMysdKQ7SfUrcvZB/tlKKHxZ1PB1f4Dob+c
         1lroZyf4IcUaMbN7p9mjUyQ2rh9U4AK9Y78Xoq5FTE+BoWmd/TZjUgTJVaQgjTzj6Fhv
         nQX258zMZUdHz0DDs1wBY96aPsQWzAGZOANgBRXMBUwmxuN7Fb9Yg5swJ9sjIxscCziG
         Meo40jLx3pRMDO1DWjNpKs0v2py246+wagnlO6+YLzrGyuWClAYg3i3cBLjHpcWpO5Fp
         OedyuSFv1BJota26TTYfm3vGlGM5lv965ewOBpUEEAhdfGaag5Dc9n2MtZgnzj9ra2xo
         1A5Q==
X-Google-Smtp-Source: APXvYqxxrglObjlo8w46Tz091xj+Tul5shgzToNuvzocMU3N9cGR0ap9GkUhctszRf73sjLGdBhhf7SM+kKX9LW7i8I=
X-Received: by 2002:a17:906:288d:: with SMTP id o13mr15229728ejd.66.1553023633005;
 Tue, 19 Mar 2019 12:27:13 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <20190317152204.GD3189@techsingularity.net> <1553022891.26196.7.camel@lca.pw>
In-Reply-To: <1553022891.26196.7.camel@lca.pw>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 19 Mar 2019 15:27:01 -0400
Message-ID: <CA+CK2bDhB8ts0rEc46vVT-mR8Avx=DZAdyMTzxqOD99MP7dOEQ@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Qian Cai <cai@lca.pw>
Cc: Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm <linux-mm@kvack.org>, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> So reverting this patch on the top of the mainline fixed the memory corruption
> for me or at least make it way much harder to reproduce.
>
> dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free
> lists for a target")
>
> This is easy to reproduce on both KVM and bare-metal using the reproducer.
>
> # swapoff -a
> # i=0; while :; do i=$((i+1)); echo $i | tee /tmp/log ;
> /opt/ltp/testcases/bin/oom01; sleep 5; done
>
> The memory corruption always happen within 300 tries. With the above patch
> reverted, both the mainline and linux-next survives with 1k+ attempts so far.

Could you please share copy of your config.

Thank you,
Pasha

