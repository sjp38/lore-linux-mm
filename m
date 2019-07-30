Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E83C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:39:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D35DB2087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:39:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D35DB2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50D5B8E0003; Tue, 30 Jul 2019 16:39:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BDF78E0001; Tue, 30 Jul 2019 16:39:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35FC88E0003; Tue, 30 Jul 2019 16:39:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0CEE8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:39:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so41613027pfv.18
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:39:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MeQxIGageVPoc2uxy8X8chD/s0jD/q8AVs2f5ZUzYZM=;
        b=RrsSjj714Ew7RP4gPBqVuAAnWNzFscehjdpKvppRiJKb3PcGDspUMDgWI5LaNo48R8
         +CNpHd3xaeQR2+gPwRv1zqU7i1tU7LBdC0ceHmIlFmzpbZ3MxwbRHQQSKwoB789/tNh+
         XFJsrLczzyTPWocvX8cB7WyRCxKn+1BpicHJSm9IydJuD+tmulQoDvg546aj0gTDaMgl
         JZR0G032ANBjet8Lhvk870PU03/oDxJnINWI9P/2NHGsZVkRirTJ+y0t9OvZmCed+dHD
         UXWDgLypiBoLYiqNcuGzaXCuYRNbVZ/ZsViSH/yOJw7CDliP8zuKcPuoIFzEqTosupCc
         +JLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWn2AjTkTbpdb8kXRA1Ov8B2qiKVuiMnpe/R8g5V2bYt5sl6/GM
	xEkXCss4jSh/k5TIhZQ5bqQ8OBAuJPMbRNZSSG4UmmWt8O/8B5UehEt7Xzt33FYKdOgVia6uTSI
	YHfRWK9YcQ6zv9HlpBazA7vrERrWLtjzMi3O73k6z4ooYwTtFqVgH8rKc93YbGbFnPw==
X-Received: by 2002:aa7:9aaf:: with SMTP id x15mr44647055pfi.214.1564519183649;
        Tue, 30 Jul 2019 13:39:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6uokQRYtyTjRTgD+xJzwPqHxLQbFPa9VN5atz/inO6gMsxMnuKCP2SacQW2hhsyDfQTex
X-Received: by 2002:aa7:9aaf:: with SMTP id x15mr44647027pfi.214.1564519183106;
        Tue, 30 Jul 2019 13:39:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564519183; cv=none;
        d=google.com; s=arc-20160816;
        b=SKc8DAJuFFk87VwLDmp3GEq+9ktv158rdsh22MJWLfQfihnv3k0Tkm5xT0ILOgIAll
         7hru048J0gOdpP30QLDNZXTd9GYqcuDI1g5c5W6r3WoDzWxKe9ioByZTj69/b9mzECBi
         6aB9ObhqjDwtE6nT/q+v3VhzmD5J+0UAdZz9K1b0XADU8OVNvnA0W98YEP3ZBmLKmXC6
         6mdLO/uvLv7ypJbT2T4xdTkaxYh0wjidcdHQPx1AZRrUGvN1t3AT2M5OvsnHCzCkYKdp
         rosNqK9z6lhwEw6qCqqTRxRbKBZS6AvtZeyEbZB38BuXoev0uYhzwE6yuZaTWAFKLG/+
         X20g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=MeQxIGageVPoc2uxy8X8chD/s0jD/q8AVs2f5ZUzYZM=;
        b=nlhcloCjMG+sh1HeE81uHU3677qA0MxgOxzRcdvg0A37xLrsXCfjf9jwTSzIxyqW6E
         VUXfEyzFrrfozGfiFg7J8ypdfBsrHP+vnsOHmX2/ivGYASMmAOcP0kvw4/M3K5qos0GU
         nnn6aickzi7TasG+K4ZIvBy6qd1rkdF0Pu3dIdByANzvGazek6bTcYQ3chZ52SJ3A6Oz
         EcMiQFcQ01lkI0XxDVurXNv4APK5g79N2ZgcsR81ye6KQxvFXRq+qGo+ve2ulu/iX3F5
         FtaShYxjU4IGYY2jM4aEYPNUwgsdkN09kXUpBNbdJ7IwrboEWrolQSa3RGP9lPasO9Ln
         vGiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o6si36444112pfb.230.2019.07.30.13.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 13:39:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id AB48A311D;
	Tue, 30 Jul 2019 20:39:40 +0000 (UTC)
Date: Tue, 30 Jul 2019 13:39:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Matthew
 Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-Id: <20190730133939.2840b742408336e2a0a9f573@linux-foundation.org>
In-Reply-To: <1564518157.11067.34.camel@lca.pw>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
	<20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
	<1564518157.11067.34.camel@lca.pw>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2019 16:22:37 -0400 Qian Cai <cai@lca.pw> wrote:

> On Tue, 2019-07-30 at 12:57 -0700, Andrew Morton wrote:
> > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm=
.com>
> > wrote:
> >=20
> > > Add mempool allocations for struct kmemleak_object and
> > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > under memory pressure. Additionally, mask out all the gfp flags passed
> > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > >=20
> > > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > > different minimum pool size (defaulting to NR_CPUS * 4).
> >=20
> > Why would anyone ever want to alter this?=A0=A0Is there some particular
> > misbehaviour which this will improve?=A0=A0If so, what is it?
>=20
> So it can tolerant different systems and workloads. For example, there ar=
e some
> machines with slow disk and fast CPUs. When they are under memory pressur=
e, it
> could take a long time to swap before the OOM kicks in to free up some me=
mory.
> As the results, it needs a large mempool for kmemleak or suffering from h=
igher
> chance of a kmemleak metadata allocation failure.

This sort of thing should be in the changelog and in the user-facing
documentation please.  Also, we should document the user-visible
effects of this failure so that users can determine whether this tunable
will help them.

