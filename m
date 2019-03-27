Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 315FCC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDECD2075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDECD2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 808F86B000A; Wed, 27 Mar 2019 04:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B8E56B0266; Wed, 27 Mar 2019 04:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A7F56B0269; Wed, 27 Mar 2019 04:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADF96B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:54:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so6350355edd.6
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:54:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nhvgq0cykWWNMRSLbFA5EjwKCm4saiqOaMtgQoM0gWU=;
        b=sHahfVepGVWQwrVUR1rdBOYArIdLwKw6zSDoFjF2vkImB2kBixo+y5Ul92NLgp41q5
         wRlgVFbyJI7oqAjt/i3a6kjpx0VQAucCw1pV0nBg8uMylmW4YXNzeezNXb8VpvoOo6V3
         anoUa18dTfIc97HWYgiCQsDVLTrJLUISwhJLnTtTIComHSjfUf+Auyx2xW53QzD4u20L
         OXgH34SjBErvEHC1AhoVLAZo1IsIAGwbF7OMKdBAZ5MHVwOczE6EmcgHHu0nv3Rd26K6
         URTymCMXln29iq6OPHzfRks3Ddi8Gwz1zUaR/z7FyIos9Ll/iVJrVhpgCO6w3+mG/jTJ
         vmwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWmTM4JBTGkvcAPMII71F6QDkBKmAtcf4ksRyKu0O4YiLOPZTUY
	xmgqsjIpEaUnWApxGc5BPva3YXMqLbZ7PqtqZSEMxLrsjewPSbnqqz0V+MMrr3DIy9T6wafgPuy
	EPY9MpzqwdlZxfAc5HkCuO9LCMMM5dnw+xqBRyA9dRx2bgIw8VVrya5Pc5En0AK0bGg==
X-Received: by 2002:aa7:d3cc:: with SMTP id o12mr22383169edr.115.1553676895690;
        Wed, 27 Mar 2019 01:54:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws8/aOMWI+hAXDyo4rkZMqPHwMr7wkk4RyaWEDEMLpim7gPLcMVzDmtIKE3Osqq+wL/kGl
X-Received: by 2002:aa7:d3cc:: with SMTP id o12mr22383117edr.115.1553676894512;
        Wed, 27 Mar 2019 01:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676894; cv=none;
        d=google.com; s=arc-20160816;
        b=VbWNzD5r70zxw6hsZm/fz6gnrchUiAeZDaOXDxFUlO9zXeTaWVlzdShMdn1aU5q7m7
         7yWNHPxq/DzcZSmj2NDiYCU+TK28UtTjFuqkLHze4BHR3wUOKmnYpQEK3UPpCV2yZgDn
         bYS3dHoMSM27/KVRP+tLNtAgnaz/Wo3yHX7rBdXCQ613b0JPOP+iO5RxZim8wKmdf1b1
         8YSDkKrE7/2/KMLfhWrJXDYKEU17FO99c0fPYGja/YtOPbKdqiLFcHCBmM2x2kIeqOIa
         iBt1nwKzY3OuIRsyyp4c1xIvHgMqC6QL+rHBxzMwHtTJoKSw4StAXGUfdhBpqdQJ5gPX
         fnGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nhvgq0cykWWNMRSLbFA5EjwKCm4saiqOaMtgQoM0gWU=;
        b=aK7rqIrkp2HpGK/tCHfYAC+xmwd1jAevEhFVY2ux+QtfjBxURLnWmcEEpbwLMWCCZt
         YUwphzNohfKYFPQukLGfQ3/AkNl6fdy1wtKxSfqAaFg6LxZY4/R1LpvoAJGRi2N4w1Vr
         97a5hBp5QJlxvu2DpvSDSh16Cem8Xo8CpGguhAhRaVa7nWtXt3+mByQklwPoXVEUXN85
         BswdCPCO1FMPPuLSfO2wLhI/eC5bn8jIpWlQ9x+3utmfJUnUGatdWCFFW7Nrfd/HRUeN
         gFq3yKXYXYCVU4GESNodSykG8DCkytVyJMQCYDZJiOLoLAT9o4PHjTsNy4IL7q0pMUtd
         3pfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id k7si2162960eda.6.2019.03.27.01.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 01:54:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) client-ip=81.17.249.193;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.193 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 230FFB87AF
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:54:54 +0000 (GMT)
Received: (qmail 12706 invoked from network); 27 Mar 2019 08:54:54 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 27 Mar 2019 08:54:53 -0000
Date: Wed, 27 Mar 2019 08:54:52 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190327085452.GM3189@techsingularity.net>
References: <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net>
 <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
 <20190325105856.GI3189@techsingularity.net>
 <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
 <20190325203142.GJ3189@techsingularity.net>
 <CABXGCsNFNHee3Up78m7qH0NjEp_KCiNwQorJU=DGWUC4meGx1w@mail.gmail.com>
 <20190326120327.GK3189@techsingularity.net>
 <CABXGCsMPmxMRDn2mebirBv9B2uhskLMfzRWr3t8_=HNcU=SZ9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABXGCsMPmxMRDn2mebirBv9B2uhskLMfzRWr3t8_=HNcU=SZ9Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 08:57:35AM +0500, Mikhail Gavrilov wrote:
> On Tue, 26 Mar 2019 at 17:03, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > Good news (for now at least). I've written an appropriate changelog and
> > it's ready to send. I'll wait to hear confirmation on whether your
> > machine survives for a day or not. Thanks.
> >
> > --
> > Mel Gorman
> > SUSE Labs
> 
> 30 hours uptime I think it's enough for believe that bug was fixed.
> I will wait this patch in mainline.
> 

Excellent. The patch is sent to Andrew now, I hope/expect it to be
merged for 5.1-rc3

-- 
Mel Gorman
SUSE Labs

