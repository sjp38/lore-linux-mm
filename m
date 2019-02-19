Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C95C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 980F62146F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 980F62146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C26E8E0004; Tue, 19 Feb 2019 15:30:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 198FC8E0002; Tue, 19 Feb 2019 15:30:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AED58E0004; Tue, 19 Feb 2019 15:30:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1B258E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:30:44 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k5so21180716qte.0
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:30:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vvy0zt2tgUmBk50Z3+oL3WyALEifUVE4h/vXXBM6Ys0=;
        b=tTfA2/ekrsQT6b45xhUrzoA7S3fvSf96bv0WGOl1rn2Rsc5gHFgOqR4andcA9MAsT8
         NmkXK8qSpiABBA1vYWpJmLEOXTfsFYRhIfjisHQ+tsnw+4jJmMfZ8YeCFzwUo0PZB8SB
         jPdwsL8ZXXC2wIOcQEvJ34w8Y10z8EFxsayLGblY9T2BEvtGk8RJ3A4oMXQyRIQZIhf6
         vqDcPBLHoKsM9NUMX5vfk3x+IxE6aLu44xVbfqvVErkaKaabBWxidXv8aK/0CX2Sj7ag
         Orh5BXyL/y1W6k/nljZL2R0VFhizR2vVKEmimMebQZQ0bMVPwu86DzyOa7WSN+2navrR
         PZ4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZP73y6AyIZNl/e2QXghlrHuHHKcAw7BgCjeDmYFHwHlQUnkSfv
	4srX17G4B52POa46SwyHKIfTktxsW4xXm54WKT6PkS/1JwAAmqbUfWFR3bCGdetvS2bAVqVvij3
	2s3rQY32IZlP67RLtS7Oiw31Dx3RLQdjfVxJgZJfCFb2I/Bo+rFrvrgnrIwWH5AOfLg==
X-Received: by 2002:ac8:1662:: with SMTP id x31mr23906569qtk.55.1550608244633;
        Tue, 19 Feb 2019 12:30:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpmlEcC2Fkb718GGQECwXXEUWFHIoH56H5zpNUs+/GJZK4WnFGGmAnx2NCmaKEQ/Lb7HI6
X-Received: by 2002:ac8:1662:: with SMTP id x31mr23906456qtk.55.1550608242793;
        Tue, 19 Feb 2019 12:30:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550608242; cv=none;
        d=google.com; s=arc-20160816;
        b=eUxKaDUTA8uOTCO8fxsGEUJPQuzNQzx4J+QycOwNjTGMPGX381r2pzWoUnFhrDCRNP
         Jd/qWZ5yXCECs94CDArLa/erKOdwjnn/0xzRYOicknEfLBYuJTBfVT1xJTrvdh6h1u9P
         Yl8BY712ClXZZIzBjj/GKS4C9iZEheNULY7mff7RmHoD+wFlT1pHeDpscPc7LWVhgzLk
         hvFOr2hFT+iPN+/ykJB7b7858IC32+0pZq45/U8Vxc4PGwHdLII3r355vfjouY3YrdHZ
         ifbN+283xLOuKJbE7zgMAWaYSoYYKL+YJlEZ8AviLoOxsgF3saYKsrY3aSgF5C2WybvU
         K4WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vvy0zt2tgUmBk50Z3+oL3WyALEifUVE4h/vXXBM6Ys0=;
        b=Cx4pXfJsApCE+efK0iHcj9AbjCOSLoLp+iTaSq2Z9bP3VMuAPdtWZxKScUVgtm11LI
         1kl+kxtXjEJgrbkwjo7iNHpcsT8J6IugNmMv8AOQ+vMcqcI+82i6mcSebRQl2o2g4nXY
         tB1KXae26er0xWsLYKPoscPTrMZbJjXbGSi2kJp9HKwy3eCBE/JhcidkI6gq+S3Dlyw9
         KTM0J6wS2L2GbUxnNMv8E5gKmqkoSKqJNKAp2Uo80qtdHDwp9CnKQSMCp7wGXedWNmSz
         KJ4pyIY4EYeYktIX3EZMxsEEhoGDdiXtUFY4RoZ+fAB5d2oKwBnYvKME1Nw2xthfkBsN
         OWhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u1si3478521qtq.249.2019.02.19.12.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:30:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ABDE383F45;
	Tue, 19 Feb 2019 20:30:41 +0000 (UTC)
Received: from redhat.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B6F6A60C1D;
	Tue, 19 Feb 2019 20:30:35 +0000 (UTC)
Date: Tue, 19 Feb 2019 15:30:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
Message-ID: <20190219203032.GC3959@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 19 Feb 2019 20:30:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> >
> > From: Jérôme Glisse <jglisse@redhat.com>
> >
> > Since last version [4] i added the extra bits needed for the change_pte
> > optimization (which is a KSM thing). Here i am not posting users of
> > this, they will be posted to the appropriate sub-systems (KVM, GPU,
> > RDMA, ...) once this serie get upstream. If you want to look at users
> > of this see [5] [6]. If this gets in 5.1 then i will be submitting
> > those users for 5.2 (including KVM if KVM folks feel comfortable with
> > it).
> 
> The users look small and straightforward. Why not await acks and
> reviewed-by's for the users like a typical upstream submission and
> merge them together? Is all of the functionality of this
> infrastructure consumed by the proposed users? Last time I checked it
> was only a subset.

Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
vs UNMAP. Both of which i intend to use. The RDMA folks already ack
the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
were ok with it too. I do not want to merge things through Andrew
for all of this we discussed that in the past, merge mm bits through
Andrew in one release and bits that use things in the next release.

Cheers,
Jérôme

