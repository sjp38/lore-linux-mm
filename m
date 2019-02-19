Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85DCBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D512177E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:21:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="DI5wJc2e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D512177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A0978E0003; Tue, 19 Feb 2019 09:21:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 852398E0002; Tue, 19 Feb 2019 09:21:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 741B58E0003; Tue, 19 Feb 2019 09:21:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F7E8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:21:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 203so17148485qke.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 06:21:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=SuinsLioWt1rjcu5p59zjSsV4YSlCeYn22JJHhD/fME=;
        b=btW1fcRHCxpflQR+LUKdMN4kRNPwCtnjEhXGxSuo4OQ91OdGX858h1qSXJ5sVSquoG
         55EeC6XEu/yjjQnDPaxPPiUL+Bcw3C4g2upjVZKUc5FLYu02N5Xe79/uf5y60/G7oaWA
         l04x/HbeHtx0iEYiB5ba+kQI9+dmJMSZwK80V3xRLXTuaXVvCiIrjrKGaWs8Wt+8I7/W
         LmpBnFQvx4tvt9yWF1XS7AZQQsHErUMnq89ysu6OvGUG2DbAbHMiRTtnEpEftNj4q2Fc
         Cpzjp/tX5CkyPhl+vgay9QRxMLwgfeBgQPULwmAiuSz31VGObeXrqz5r0JWsZX7GKrJt
         sULw==
X-Gm-Message-State: AHQUAuYL9QtX1NM64fHrvRvB37vmPzNGPQxHtopxXqZDgTFbBgL55WNw
	Of9dJvDZG0wxxSbkBezy/4ubxYjEP3wmujeVMMHunO+NJLNQLMVxIH8ZeehdH/0Lp6XN64pkJAZ
	IT2CGc405lMDHI+ko4DRdoWeKGgwRrIhElOxcHWRz0mvhdpP4uRy7GPOhAmz10DE=
X-Received: by 2002:ac8:22d1:: with SMTP id g17mr4533002qta.30.1550586111950;
        Tue, 19 Feb 2019 06:21:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbEn9wFNKAtXHnxdYoWHlR06Xjz5aL7txa0mtsENY/oMWoDzAh1mxEcOqzFZDZ9G6kJoyiv
X-Received: by 2002:ac8:22d1:: with SMTP id g17mr4532965qta.30.1550586111332;
        Tue, 19 Feb 2019 06:21:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550586111; cv=none;
        d=google.com; s=arc-20160816;
        b=TJPkcqslRCzPpQc8XM8pXn7/sHMESVYxt94q3Dv/QzsyVmFL1Ocm7UsXlNj35lQhQh
         Ywb5LRjGglb/OmSHCllcakwGVaMb6XXGS81h3NsbNeFXRj4lv4ltHmj7MugX27jbMB2d
         Z0okSO9G7BX1ctwTuv0xxWo2u7dRXWqE2q0hKi8q/CT1kYz8OF9ydaUvGvcHOWhWbVIe
         Sii8b7umAHqOC2rYzVqBaq+ba60agcvrLZNKCRoqagerfiA7ZXnYx4wGI0jyqr5Bvjhf
         31mDTxXWH1KLppt5npKUYMNTovJf+yYual2XIhhPhREMRGTRfdIbXNbq9c9DNPM3hJKh
         OXYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=SuinsLioWt1rjcu5p59zjSsV4YSlCeYn22JJHhD/fME=;
        b=DAJv99AJLBum+CO9sqonZmfBMGAAKckJ8+KhLe7bqYwzRH8pH/apC9pJ+gIt5chEEP
         qY/kswnKwHBX7NsxjYyqeYGQrzcTe9tc3bIkeR5y5NSJu/FNxLPw5ctkCKzXiEP8A22x
         Jf7WMEJU0sS1mFaS2PsTZcqSp/UxauDsPifANnJtuzBTiZmTYZuS2pIUMNYuXrUUj+I3
         V0g3UrBohoGY+t4tGJ2GmO/6dFByDlUHl4y2LBrP1mTLwxl6sUXwooCsVu2Px5YdLfHt
         X3kmXef9cuCVjd+E6I/o4MonTie9ZS4pUM2QU66/rnMxoijZktfwFGR9rNV9PWM29rnK
         d69g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DI5wJc2e;
       spf=pass (google.com: domain of 01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id c49si2795226qte.328.2019.02.19.06.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Feb 2019 06:21:51 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DI5wJc2e;
       spf=pass (google.com: domain of 01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550586110;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=SuinsLioWt1rjcu5p59zjSsV4YSlCeYn22JJHhD/fME=;
	b=DI5wJc2eChYpCIRQ7nkjOvHufGqv7BBhBmcKsP59o1MASZlgKRlndE0xG/8oYQ6c
	Gi/ndD5mICxp0b0Atx8ap/q+/+W1xhaOSMOc1HjcQ7NSXWLig0HtKQNibRa0JXnd7CB
	VG+NrEZUr5nZ56q+vdqJlkYdToXCN7PQd2kyh5pE=
Date: Tue, 19 Feb 2019 14:21:50 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
In-Reply-To: <20190219122609.GN4525@dhcp22.suse.cz>
Message-ID: <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com> <20190219122609.GN4525@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.19-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2019, Michal Hocko wrote:

> On Tue 12-02-19 18:25:50, Cristopher Lameter wrote:
> > 400G Infiniband will become available this year. This means that the data
> > ingest speeds can be higher than the bandwidth of the processor
> > interacting with its own memory.
> >
> > For example a single hardware thread is limited to 20Gbyte/sec whereas the
> > network interface provides 50Gbytes/sec. These rates can only be obtained
> > currently with pinned memory.
> >
> > How can we evolve the memory management subsystem to operate at higher
> > speeds with more the comforts of paging and system calls that we are used
> > to?
>
> Realistically, is there anything we _can_ do when the HW is the
> bottleneck?

Well the hardware is one problem. The problem that a single core cannot
handle the full memory bandwidth can be solved by spreading the
processing of the data to multiple processors. So I think the memory
subsystem could be aware of that? How do we load balance between cores so
that we can handle the full bandwidth?

The other is that the memory needs to be pinned and all sorts of special
measures and tuning needs to be done to make this actually work. Is there
any way to simplify this?

Also the need for page pinning becomes a problem since the majority of the
memory of a system would need to be pinned. Actually the application seems
to be doing the memory management then?

