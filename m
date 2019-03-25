Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E925FC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 09:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9691C2085A
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 09:30:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9691C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDDB46B0007; Mon, 25 Mar 2019 05:30:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB36D6B0008; Mon, 25 Mar 2019 05:30:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA20C6B000A; Mon, 25 Mar 2019 05:30:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEB4B6B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 05:30:13 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id w10so1006538oie.1
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 02:30:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=53EtM1rC6yqUbRN59j4sz9Ewknof3CMKmFGx3aTOh9Q=;
        b=lxpHLhxy5bKGIrTKWBilUD4DGB62nBVqAX/2u3qtEPvMv2K3ZjzDpXKwKCykOYHX7k
         WVchWjtgcNVoEWkQodnm7HCSnkcdJmCwsQhrMFEV9f51/FucBYZ35S42S6tcMPUr35Q+
         LYqQg9Yw3XhqWxpOaHlyPmPAy+YuJvryJcuIpK9AHYyWr3FIWxrRfRZWj6evmYLsHZlS
         y3A+Yc9hUZ83fDi05nu/PoJMrOXZgxAKzkXcjEa/mcWcFrtBhQ/PiT3xIbkKiCQOXGls
         Y9i0qrF6T/VW1vuCWEZTVQTWrv4C+R+WQBzoe1RAbmDhmKFas7YzIC1CQ6kvBy7PTCxi
         yfnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUa58lYhRdiuxi0RkN/SFCZ1RJqCTGhKV7WpxVoezIfJPlqrO41
	/J63U3aQMwboapvkp1qjRjmP7EceCc28CqL3TbL71wgd/ajESiwI4kLmRRfj/KtFELm6jAq0YWZ
	OVQ4XknGrHjcYa63t4x2AueYS979pORszJ+7BC8xCC+onxgoX3RHlbWFZuBMnJYM=
X-Received: by 2002:aca:aa14:: with SMTP id t20mr11063777oie.166.1553506213322;
        Mon, 25 Mar 2019 02:30:13 -0700 (PDT)
X-Received: by 2002:aca:aa14:: with SMTP id t20mr11063746oie.166.1553506212521;
        Mon, 25 Mar 2019 02:30:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553506212; cv=none;
        d=google.com; s=arc-20160816;
        b=ic8BdiobwVi0pbB4IDHcZZ8dAfVTDcUT7ioomsYFV3/MCYQ1bs1MfRefLoesK6vHIv
         LLinCZnbNerQXZQ+zH6F7tzDupo9xOLASHlEYU8Zxl3BrPosZJeCBruteN3j9Q1iqtwQ
         s2M1Rcos1Z1Q3GU0S/0Si9dLiWnbfHLdilzHKIIksHw1JdtCXTThpE8yYjr7g+NUL4Jj
         j8FCGaj8kphBKSNBLL0otUWgPoD/oUDwSlhsAwKoNWn1nO8n7jslzDdjxXiwTdpFkKAd
         Xrsc7rL3U1P2BKiCBUcQU0u0yZKEkGD9fQbtPJbAgX47EZ2d5hSs3OqTOtNowERNYhXd
         b1og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=53EtM1rC6yqUbRN59j4sz9Ewknof3CMKmFGx3aTOh9Q=;
        b=mJdvoPaD270X59ZPRf3wyX0GUL0KMxkIjBeB3SDuPAuEeCNUEau99zJISb1T1rS6oq
         0n1jsqPWnY0zWKUakCEvo76Cr5F26ZM21+ixAQhmU0gCcpXKVmWF0rEjc9Zzf8rSZoyg
         UdP+TUypnCVIDX4PBxHHOHonLf7iFgF9Gb6E59dGiFIAzEy6FMv43BjwZXownQYdJYgL
         xhPnvAYC/Pt3m+LSDdpy8cSi9uVf5vg2dHgh+XLtVFrZV7iL8aJbaEvEF6Bsr9dijLMd
         /GreKlocwMXpGViVrPtp3QZM9TeTnfJ4vqwdifFY6gp6dPWApp7/cMbEr4nbw0nehUQo
         KUwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor9990078otl.111.2019.03.25.02.30.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 02:30:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxZ3ZE1GoLHOWfT/WY3ID8zgJIIQLpFqHtK6doVrNRBVhafM/uiQ7I6yZZvN3eSo4than0MvB+pOZF6MHvafWk=
X-Received: by 2002:a05:6830:13cd:: with SMTP id e13mr17805593otq.139.1553506212123;
 Mon, 25 Mar 2019 02:30:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com> <20190322132108.25501-3-sakari.ailus@linux.intel.com>
In-Reply-To: <20190322132108.25501-3-sakari.ailus@linux.intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 25 Mar 2019 10:30:01 +0100
Message-ID: <CAJZ5v0i8JiQGk25yZKQqTzCCY+nrfoKXOH8nM6eNPhkN-i+y9w@mail.gmail.com>
Subject: Re: [PATCH 2/2] vsprintf: Remove support for %pF and %pf in favour of
 %pS and %ps
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Petr Mladek <pmladek@suse.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, sparclinux@vger.kernel.org, 
	linux-um@lists.infradead.org, xen-devel@lists.xenproject.org, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, 
	drbd-dev@lists.linbit.com, linux-block@vger.kernel.org, 
	linux-mmc <linux-mmc@vger.kernel.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux PCI <linux-pci@vger.kernel.org>, 
	"open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, linux-btrfs@vger.kernel.org, 
	linux-f2fs-devel@lists.sourceforge.net, 
	Linux Memory Management List <linux-mm@kvack.org>, ceph-devel@vger.kernel.org, 
	netdev <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 2:21 PM Sakari Ailus
<sakari.ailus@linux.intel.com> wrote:
>
> %pS and %ps are now the preferred conversion specifiers to print function
> %names. The functionality is equivalent; remove the old, deprecated %pF
> %and %pf support.

Are %pF and %pf really not used any more in the kernel?

If that is not the case, you need to convert the remaining users of
them to using %ps or %pS before making support for them go away
completely.

That said, checkpatch can be made treat %pf/F as invalid format right away IMO.

