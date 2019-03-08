Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B7BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:28:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C95020661
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:28:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C95020661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD93C8E0004; Thu,  7 Mar 2019 21:28:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C89668E0002; Thu,  7 Mar 2019 21:28:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB0F08E0004; Thu,  7 Mar 2019 21:28:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6908E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:28:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m34so17319233qtb.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:28:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=zKK43uCcWqjLoLEJvg2c7OBgge7uFgnGW1Yv+ah7HRo=;
        b=hz3fCZQyESjI8YjzqAr4ywmlYGJWuDygkYXPXiSxBFD+8eQ2at78e7unNgQ4Jd70ox
         UN4+Bh9lu6uGvE5zFkl5QD0Zb9JM4Hm96PRoCp3PMUSbqQAFhEVoPDDH8NbbHTbBIyYo
         /WMdXvZHMOxxLQBudYvDHMpoe3MzcN/XUsI4exzprb2RifS6V2P/7ThTHkbw14zh8GCq
         gntWjzACyUBobryRF/MqNN4rhxgamC+ZXgOj462kz5U8mlaMfVS/n07ijnZZEOl9Ud2p
         KE6SOoYi63DxvUKrfz1/DbMQ8I6Axe2645DNj447h1YnWn66A+NmeMuurgrL/PAk0DJ0
         sSxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUucNBVp8GzB52OfSnDDRjrLh7WSksH0uwcGgocReGnH2qCD1Em
	fBF9eoVrH+SPhyqbV9wlPMwhEYm+5O6ursqZwgTGKYnH76DoX7d7+IqLF0jK0Qbo6+9/iIfxsv1
	zflz7ZDbtbNH0adkUJI9hH0QuUhnHT9n0jBK7LBt+C7e5In/sTfpIwwzjDJMO/hBYEtAly1ZYRx
	QKd3CjuiGDXoVcxU9+peC19pbknjO1wQXOzAMczHRfNJNE1IBxLZOmtDzcj6Ehbzcl46XXEElu6
	Fs7sr8ReM63lAI9gf+ez1qyYFI/yNtiZNA4bAeoQN4y5VXLupbi+5oRjIXFwlfGXf8d/XCQeprZ
	q1NOPZ9YNh6uC3pCEGyjtCEMPBCXa+rFp/T7VfjQCPlGmhkF523mKztdv9h3iNTsb53s4DOs3Sy
	J
X-Received: by 2002:aed:3904:: with SMTP id l4mr12614726qte.194.1552012097369;
        Thu, 07 Mar 2019 18:28:17 -0800 (PST)
X-Received: by 2002:aed:3904:: with SMTP id l4mr12614705qte.194.1552012096836;
        Thu, 07 Mar 2019 18:28:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552012096; cv=none;
        d=google.com; s=arc-20160816;
        b=RRseBNTekYPDwAVRocgtgOWhiNwPq1Gul1Oi/R6V6h6pXed3jegzBBlqLA8ZpwGMyT
         XeBmIp2BUHXrrlhcG3Zl7rB4TWXqS+/zdbevVJqE50cxS1dUJ4gx7Evh7jhFVyQcqhAw
         d0SGR2UPlR/HDTatWoKb4WviN64DOZ6c2OeoX+8NWSPDw9VBowEovaYZxs+a2+UvzBLL
         BNDWAGmdy+e5GxPRaepNTpAqOLUxdE5hr8BkBihQ0eSG+vufrIPNTs31vlkRtmo12kdj
         MZ0R07VwPEDXk87H2OTRp6KQOBnPk1Xf2STD2lCrv3S4uqWF+8Qwxc4Vyi40sfdxEyO/
         Py5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=zKK43uCcWqjLoLEJvg2c7OBgge7uFgnGW1Yv+ah7HRo=;
        b=r65nu2tgBAeBsqQPhtmKExUKmYXpH5BZQxGXhfQb66PFpd55k+FC5wGg/0svAjKuIy
         URGH+vzI/LyviliRy2H3FexlhAW1qusOCO+p5otjFCNgeIqyOrEzhAhm40FMq2VubgYu
         V/3SfzoZ4di6kAqeSytJbfrWDMOxx4QpgL0GO0RyzPL1PHtdMVmpyBtVdxCZHhBti5K/
         pIjHQc+HnYnNsOT1UMG/muDENFpMxHtmFqJazYp2TXijt17skwIUbixDwUsZiMnss6t9
         1UnjHOhQdCBy7g3Lls1XFGRv8KYoJ3FFLdBLjpin+Xrx1/kdQwHD1BrOfoiFTssHOGoY
         E7kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i91sor7984491qtb.30.2019.03.07.18.28.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 18:28:16 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyRVLMras7lNSpHauaLLOEtnihh5o2zR9sVHmfKIk3hSYOwwHqHO8+Xizp0FcO/cSqhDNSk4Q==
X-Received: by 2002:ac8:2297:: with SMTP id f23mr1534205qta.348.1552012096590;
        Thu, 07 Mar 2019 18:28:16 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id x43sm4586211qtc.10.2019.03.07.18.28.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 18:28:15 -0800 (PST)
Date: Thu, 7 Mar 2019 21:28:13 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest
 free pages
Message-ID: <20190307212654-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> With us hinting currently on MAX_ORDER - 1 pages only that actually
> takes care of the risk of a merge really wiping out any data about
> what has been hinted on and what hasn't.

Oh nice. I had this feeling MAX_ORDER - 1 specifically will
turn out being a better choice than something related to THP.
Now there's an actual reason why this makes things easier!

-- 
MST

