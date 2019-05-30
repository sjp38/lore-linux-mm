Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6206BC28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:01:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AA1625934
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:01:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WphGl1Sf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AA1625934
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473306B026C; Thu, 30 May 2019 09:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 423E06B026D; Thu, 30 May 2019 09:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 312306B026E; Thu, 30 May 2019 09:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 128DF6B026C
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:01:30 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v11so4679915iop.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 06:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7k26iPE69aDeRJ/TfJMi2xpp92kbi0U4xCxUWiVs7as=;
        b=MSlv+uO3R0VjE+hpxubk7IpqYBv7t7hzQB7pAg+0+VoG/qNxTdG+0PSZgdceXK+Lt8
         Vtn5K7KjbSOZxm8lAVy7EmKryDWxtMBUrm4CxFjDARmRLH2Wkf5y+jUsYebKEkXumA36
         lbZdJYURRbMxzwGT4EMAbqySpHy1ZmoJxjju21J+wOIb3v03t+LmGahN/xACjrd8YfCO
         vxv3ZnFsFWOXs87WEz7tOj+fA3eBldMbhQKzrvHqnhFqKYgZhKbmKy8p5QNKpWIj9d78
         sasdkS22jxtyGnmWPNkzCNd3wt95SOS5VrYd1PObb7P98zCWfhlVo28wT7ag9v1lD17h
         VbKA==
X-Gm-Message-State: APjAAAX9v7Q1mP7gZl1JHNBDClG2tlHKw1kVV2qwwM0UYOONG87JNzHv
	psZWOT+0h+I/I1HdgXMO6bDhofkYxO/tTOJNOXnwn50nTXnd1/twFrDyqLOpmsjfzC7c7Zv7tml
	PUjWxIXaJXKanhTH+2r7x8MpPhLymMO4ILPyLfK6LhYO8ADnnHEabNTiR1DVAaHSZfg==
X-Received: by 2002:a5e:8b41:: with SMTP id z1mr1711143iom.42.1559221289752;
        Thu, 30 May 2019 06:01:29 -0700 (PDT)
X-Received: by 2002:a5e:8b41:: with SMTP id z1mr1711063iom.42.1559221288808;
        Thu, 30 May 2019 06:01:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559221288; cv=none;
        d=google.com; s=arc-20160816;
        b=QY79b0DR4gDU3HY3DaZ1+aJw9oaSPEJJYRoiHYkL/mxvdpEUpbZ8yJCp/CtZB7B190
         y1sZVhE3noNVw0wq/Z7tYCvuLA5EdmRlzjKwFod2aLdfZ11MCUsGg5S0ByXkftbjkkBz
         gOFc/J4ALgiwRzYqTe2oLVfaqNx2bCU42U4vcwKdlHZPrFH7REQg8v51lZ6vs+kqHvoQ
         9bcfBZ6GMZYI5ZtGKS5Ijai5tgatZiT6n3Tbcc7D/1UFvq0B0gRAip2Nus3VHr++4Xo6
         DaQhxoYvIrShDj+qbzu3Z88Vf2re13nMly6OGKUo73sQS7ITuMnonM6VU4BZ7auyp4Q/
         Mj1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7k26iPE69aDeRJ/TfJMi2xpp92kbi0U4xCxUWiVs7as=;
        b=cf064e6qzN9csVpSszaGNlbIfbmXOC6ibfKBySDGXPIy5CCi+3M7cxrzFLQZQ/qv+E
         oynKyrHOiiX+y8mdK4cSq6pFCq+fOI5yWLX3VeeD6TOdBWFd9LJqkyc1u2z4TPJrUnRj
         aTUgyfm2ll3M/V6zZZ27KsAUNsk0RMKBO/HUZT/vnH/sxDEKXDMmA++VSkauQxkqXPc2
         At+XMwTEJHZmnfP6Ya1SWQA2ILOIV4BNWPexso9v4wZgXH4g90O2aCYWZoj7UgQ+ROIM
         ByUOnY6ifncYoDv9Da2spo/Fk96e9UcU3BQ0ZBItFRcvGoDP9h/z8dZ71uFH9j7cXk2A
         aCcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WphGl1Sf;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n133sor3720903itb.33.2019.05.30.06.01.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 06:01:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WphGl1Sf;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7k26iPE69aDeRJ/TfJMi2xpp92kbi0U4xCxUWiVs7as=;
        b=WphGl1Sf6fzQ5jmCKxG+7grtN+HSI+I2CbYW3nTKyyRsxXivZY3CbJstwRN2lW1Hpg
         Q1euynYgPCjNhWdkiFlZMHJCbIvQK+nuZMSl6u14Ua/WM1W32n89KbzpA3Ji/bKS0WVx
         pS8bh9XPnx90axfb1lbtb+/Rh4qC1QLre71ZMO/JpT1OscgelytRHiKDNwLTnclG7iB8
         CPsDxnl/ZQuNrRm8bCEzRTC3mi0h/gfUMzKyOWBBK19ArcgQaoC3wb/YrZan7+arWkhB
         9vtBDJsnoo3Bz8xs5JDGvrnvbd9KXs7sprcxdh6aiQJAJP4rJ5O5uFtiwn8Q6oVK72fL
         UNbQ==
X-Google-Smtp-Source: APXvYqyrXRL7AXGoD/ei/cr9ondS6PAG0j2w5hheO9H6XuZGbphAwizf1ReoGOh5ZnhOWsEZ1sVstzZSDvcfJ7z40js=
X-Received: by 2002:a24:5095:: with SMTP id m143mr2653331itb.68.1559221287791;
 Thu, 30 May 2019 06:01:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw> <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw> <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz> <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
 <CAFgQCTvKZU1B0e4Bg3hQedMJ4Oq2uiOshnsBQCjKinmrGdKcYg@mail.gmail.com> <20190528182132.GH1658@dhcp22.suse.cz>
In-Reply-To: <20190528182132.GH1658@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 30 May 2019 21:01:16 +0800
Message-ID: <CAFgQCTsJgVjB-Bf22tZOM2fzKEdd0W0vmMdnZE5FxEYfV0p4Mg@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Barret Rhoden <brho@google.com>, Dave Hansen <dave.hansen@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>, Oscar Salvador <osalvador@suse.de>, 
	Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 2:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 23-05-19 12:00:46, Pingfan Liu wrote:
> [...]
> > > Yes, but maybe it will pay great effort on it.
> > >
> > And as a first step, we can find a way to fix the bug reported by me
> > and the one reported by Barret
>
> Can we try http://lkml.kernel.org/r/20190513140448.GJ24036@dhcp22.suse.cz
> for starter?
If it turns out that the changing of for_each_online_node() will not
break functions in scheduler like task_numa_migrate(), I think it will
be a good starter. On the other hand, if it does, then I think it only
requires a slight adjustment of your patch to meet the aim.

Thanks,
  Pingfan
> --
> Michal Hocko
> SUSE Labs

