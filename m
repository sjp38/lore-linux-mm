Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 033C5C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E472B2077C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:39:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Jsdx1Trn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E472B2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622A16B0005; Thu, 25 Apr 2019 16:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A88D6B0006; Thu, 25 Apr 2019 16:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4710F6B0008; Thu, 25 Apr 2019 16:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23E776B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:39:14 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so974697ioh.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vt2MHREG2YW1b5Y4ynxE1gZ24ZdGV1+JspuK5nI83KY=;
        b=U+A+1UlM/NU7mn0eZusHZFG5J6bo+6ZzMnGmskkhpki0wRZi4wopJmDH0lYF+30Ccv
         vRSH9xlaNzsJ/h4qWzn1BsfiNEauXqvhzbD4qeEGl/FcRDCnOUp/Twj/OV+3h2sRKVap
         ojBmgCZ4iSu4uIfqE24RJ56hixSgRJdZ3YOeDDsBIO5PQb6eArTbIUIVJpE5lgM/m/M9
         oukTFiKXZIloSdRGZXajfPp02sLqt6WzUGpsVF9Sg0FBIOlCDYy1EGRvK7xBAa0TfDYI
         ZqMaFLqtk0le2YiD0bQECeS6xrO7NNRMTY406uAss1ztVK/8qmyvCCgy6GS7gx0qfwsB
         hekQ==
X-Gm-Message-State: APjAAAVIl24p72OjdaC0KEM4oOwIrqBi/viMudLXX6vBZxbTCrSaZqm6
	07ra8StmxpVHNIM0HG3teGN/uYIKYieU7tCoOjdQslx7pZWS1DamfVI2Ec8zLw25RCmoxAYhz26
	FpusuCPuZM8nG177KBsSpUxxImv3XURTJcPh+lUCYIEPbjXykU+IIz4SrZZ2HfEWUpQ==
X-Received: by 2002:a5d:9296:: with SMTP id s22mr2412428iom.164.1556224753950;
        Thu, 25 Apr 2019 13:39:13 -0700 (PDT)
X-Received: by 2002:a5d:9296:: with SMTP id s22mr2412399iom.164.1556224753397;
        Thu, 25 Apr 2019 13:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556224753; cv=none;
        d=google.com; s=arc-20160816;
        b=NgBMstTLsL5T+xHfRyaxB1MM4mTlIWeoFE9HGAnBY9Yim/7MxDlh9Gv8tRG4xPZ9mQ
         gsevH0HU+A+xHjFUb2s3Iub0h6y6Pntyt4jORBUognEdkOvE0zAXKUd0vB52gd/LhGkc
         eioU2axGtC5SVZP5Nj+yy/Keh8DHaal9ELs/v7o/w3U0i+f8h/aTb9IDQjvPcC75T0o+
         JT+z8zElptxxA9ZomxrMGmwJcraxYlNHW7WriOklS6QMsj4Kd9pb9UfnbchLz8I6W3fY
         tfc7/NM3eFSqPcGN2wTIzDj904H/IfztN8klyZ2rKY8JlHO8b93TjGntW7nASaG/Hsw0
         g/rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vt2MHREG2YW1b5Y4ynxE1gZ24ZdGV1+JspuK5nI83KY=;
        b=lqaSBcxCrj+sCRelpa2vlOmhHd1L1Zo3PPriXUQgmVr6yv4x0eP6Oyn+EUG9rQleGO
         45ZmpIynld97GWCnOy1uG1tMb7DQCbNiNTLwoL4219HmgWoQTgYYI70zPn4q1M++74f7
         oMQ3hhr/2qjxRkMoXCRP3lyH2c3ps+FYHqUSxvvXDKr/itD0mdUpUvIe0v/RgtTJdVw1
         L0PT+ax9hzV737vN1RHdq9imKJASJGgJ6tXLq3HGObW/xPD7F31zwi8sCSL3PNON9YjI
         9+GGAsKwx2+FUT/VRdRrGs377zdkFPqeEYtp6BJHjrBsenKysIyP2ghvijZ/x0v3V5XC
         MJ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Jsdx1Trn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i33sor3933100jaf.10.2019.04.25.13.39.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:39:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Jsdx1Trn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vt2MHREG2YW1b5Y4ynxE1gZ24ZdGV1+JspuK5nI83KY=;
        b=Jsdx1TrnktYnmyKJsMoo7doVO3TxeEBSjygL1I8pQFFrqJHvtTA0+4/DoMGGiJy+GT
         A7sWMEm4PwyOBlSMEEUdsHPzBga0UipypP3GbzjLxYtga9A+g8JkIS3a70LfV/C6L9aG
         TMwa/YU3l0WdUGELor4qWqYgRECWqjTyMNGDdGpHBfJghrWxL7XHM19HYRBU18oOMMS3
         aB8vF4Q6pX7IGeAU65ylVKhmQt/0SVoCqjGpJWBjYUHBfRyD0Nj8Kjgp7x6JE56s+x2R
         XIbINGd4KfGBgzrwtqf0LxgoBKsZ89A/rI4n4oWDjimxd4VjNJBV9uke/xdhZlXWOjeZ
         sMHw==
X-Google-Smtp-Source: APXvYqyb9X1rNLIny8GhZh4mbLQoW30LUgL2p7h5j1bdxa54QREd5fTxckJy1RdiyszL2i5qiQCRVH0oo67LjR2oCp4=
X-Received: by 2002:a02:ad07:: with SMTP id s7mr18510295jan.103.1556224752679;
 Thu, 25 Apr 2019 13:39:12 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
 <20190425123755.GX12751@dhcp22.suse.cz>
In-Reply-To: <20190425123755.GX12751@dhcp22.suse.cz>
From: Matthew Garrett <mjg59@google.com>
Date: Thu, 25 Apr 2019 13:39:01 -0700
Message-ID: <CACdnJuutwmBn_ASY1N1+ZK8g4MbpjTnUYbarR+CPhC5BAy0oZA@mail.gmail.com>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 5:37 AM Michal Hocko <mhocko@kernel.org> wrote:
> Besides that you inherently assume that the user would do mlock because
> you do not try to wipe the swap content. Is this intentional?

Yes, given MADV_DONTDUMP doesn't imply mlock I thought it'd be more
consistent to keep those independent.

> Another question would be regarding the targeted user API. There are
> some attempts to make all the freed memory to be zeroed/poisoned. Are
> users who would like to use this feature also be interested in using
> system wide setting as well?

I think that depends on the performance overhead of a global setting,
but it's also influenced by the semantics around when the freeing
occurs, which is something I haven't nailed down yet. If the
expectation is that the page is freed whenever the process exits, even
if the page is in use somewhere else, then we'd still want this to be
separate to poisoning on final page free.

