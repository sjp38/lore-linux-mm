Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F877C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:38:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11A8D2147A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:38:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11A8D2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF9198E0003; Wed,  6 Mar 2019 13:38:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A809D8E0002; Wed,  6 Mar 2019 13:38:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 924D38E0003; Wed,  6 Mar 2019 13:38:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6553C8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:38:20 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q11so12333161qtj.16
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:38:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=T24eVcgpzAYAMO6VRnHBSEvjogV8HmqLjlBXwIfM6kE=;
        b=dNHT6Wq5GoRM8Ju2rQm/kII7szcsplWedceNBUbtWXjzPPlAHpPba24+bThtU7ydSO
         0xK0unsy6eId/iCf2m9GmBX0dQc2vpdRR7YLqXuIOzbmIFAdnPPLbsfSgmCDP9wfFPfX
         2rzm36/cNioJbqOMCCcZ9apfmOtnTObhFVOKOsab0ettHLM53OMuJQCeA/1LsLo7NhG9
         8jRa8OhGP3zWbxoWLQvHrG/OeCuzqTRZ1CZGf22RJAfYHi9zAPU9mKGyYMHFyJzmFBOg
         jZP+ZF8qarE8Gg368A/owIXqaNFwaJz3xmtqHxosVnvim03oj9xItV6pZZkkCK4Y1bZz
         30Xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWPFY0KZsjKYjNFwM9lBhYkutmOC5QhVaqnTdNOmmI1kcGBXhFO
	Vz8vDLMEn2ZDlxgyDwhfYFMCEQ++awR5LKrBhL4wDCbUdZ6tbh4K/8pCO2kH1b0HW8uO+HYC+MI
	/DfCZuPwCN6+LTQE8RDjxBr99alwtPGWAMQnZk8gQAzj4odBkmDro8/KPqG0ioNb2ntoMLaGK/l
	7ZKw+QJzFhpYj4yFqOc0++EZSGgo264BfEG92X6tImn9kSCHoR/NYONwkDsbwyizK7PkHCVbjFl
	EzQXN/3yADZzK9i+0Xwi76ziVi595wn2vbKJBWkNLAhmcIXCBisAD3TuOXtptFkHwOAVj/I11De
	SibOqupGbr7YjGqop4mMlSarSmC1Gvu3AAcazY08chqw81dLjvOtfub4Yp3EuYCmwLmH0x7EcV1
	3
X-Received: by 2002:a0c:ae27:: with SMTP id y36mr7553892qvc.185.1551897500226;
        Wed, 06 Mar 2019 10:38:20 -0800 (PST)
X-Received: by 2002:a0c:ae27:: with SMTP id y36mr7553837qvc.185.1551897499407;
        Wed, 06 Mar 2019 10:38:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897499; cv=none;
        d=google.com; s=arc-20160816;
        b=R8WwIpaFnHJlyjjvHgS+9p7jH4KfOYGRt52iEizw6OORV2+rMmOLt0vaaPU64oXxAD
         MeYnS6aPCrf3y63pZi2iP6RRcYGJtH+wTpfeP7SSW3TuIdNoZ41oKgYQGFt6o+TaAyAN
         4mjJ9PvBfs1Muh0QXeXqdsSfA/x513PG048yvMtiqz3c2FrGGY41CYyrPB/7ur5aJX01
         ff9ep8YfdSE9SM0WndgdUtFIVVfvJC+ss54VOLavHRSj00YUBOSKT14DvENgTpkF51tk
         i1lM68tG5KZy5VB1TB2unWpyCAywkIpmPJCxm1DDSB33XO1wpF1btOhSVygdmdn3mVIO
         uvrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=T24eVcgpzAYAMO6VRnHBSEvjogV8HmqLjlBXwIfM6kE=;
        b=uWI2yP0e4akGvCSzVlXOHysyZ3mcJuqvKFpNfOySYgi+5Z51ZWVUJAPW4jLu8nC70K
         shSOpKzpBayAYPi7O57ycKfme85W2fYIe+FHlq/xosEtIdFJXLFxNw66UbEm3TqpOnJg
         58pxnd5xlubJK+fM75TNCgP2XDckWsLa8u8eH1t6hlDV2zrcN2VAL+gdRgl+c4BWTLJr
         S6s+3T2c5Xegye9moTNIyyAGavZvcErUrRRL2hS+n1C2OJSZ6OHC1TIVGHFyqtDVP3Lc
         eXTVcijDeJehnBGzHEXUOU3frmT36kk6rVDnoA5nqtSoYF1Etc0yIdJZ/wiTTCwi5IrK
         NSbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x25sor1335134qkf.77.2019.03.06.10.38.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 10:38:19 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyp4/fWLcvJkLYY14pEzyen//W/96hdXYhLSGykOJker4NgGzIDFKXI03sbZ9R8gDmGBpDBRw==
X-Received: by 2002:a37:6314:: with SMTP id x20mr6786541qkb.276.1551897499201;
        Wed, 06 Mar 2019 10:38:19 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id r198sm43238qke.52.2019.03.06.10.38.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 10:38:18 -0800 (PST)
Date: Wed, 6 Mar 2019 13:38:15 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
	dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190306133613-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> > Want to try testing Alex's patches for comparison?
> Somehow I am not in a favor of doing a hypercall on every page (with
> huge TLB order/MAX_ORDER -1) as I think it will be costly.
> I can try using Alex's host side logic instead of virtio.
> Let me know what you think?

I am just saying maybe your setup is misconfigured
that's why you see no speedup. If you try Alex's
patches and *don't* see speedup like he does, then
he might be able to help you figure out why.
OTOH if you do then *you* can try figuring out why
don't your patches help.

-- 
MST

