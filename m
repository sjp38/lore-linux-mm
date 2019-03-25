Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E76FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 09:49:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFA9720879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 09:49:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFA9720879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E936B0003; Mon, 25 Mar 2019 05:49:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BF7A6B0005; Mon, 25 Mar 2019 05:49:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705A46B0007; Mon, 25 Mar 2019 05:49:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43B1A6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 05:49:13 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id r23so2064050ota.17
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 02:49:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Oal7flNQwT9u03yT3aAACwafEYYaGm4K4yZxV7zkB6g=;
        b=OKcXrFNnZhC7TzCKq668ySUUwJ7kF8hj86p0UrVYwgd1yfphLN4C01FgYEeXfS6Uyt
         p0jbdXVJ263mp3CSneP+Y+8wMuATIOeptzV7ole2Yx0dItnzHTa3aQdDmHulwKvgaD/J
         9Q9sOJP0BRxjQMrhQRNgdL0fqaUT97TY5AdQ26+S78pGZnTOAV7vzSeiiKhJg+zBDc2I
         vCJAp6gKCYvM+NvfRGTeQAE7rg/GQ+JN/wlukGJu38cLUZ9u8twTS1gJDMayYeLittEX
         MYaNnZzy3g6NQM4SYUOb5A9+ckaAS6pc+arZ9gZvFWJQzwgymfqM8tTuiahHNPlJL2ZZ
         AMzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXUGw3YqjHJebgqih5GMfvhLtoAS1CwUYpihYNlcTfWO2b4l8lD
	iVN/LZubhtJeXJIWUHxm2pIhyqKCF5wVhEG9Rj8jWNiHqyzUglzTDbzciiHDWH3bDzP5frpEbaX
	vu84QCivN8exVrUgqKWMwF4Wr0mMwPwTxII18QxXYWG442ZtOiX1E/Ysb80sX4Wo=
X-Received: by 2002:a9d:6393:: with SMTP id w19mr12643969otk.257.1553507353000;
        Mon, 25 Mar 2019 02:49:13 -0700 (PDT)
X-Received: by 2002:a9d:6393:: with SMTP id w19mr12643951otk.257.1553507352504;
        Mon, 25 Mar 2019 02:49:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553507352; cv=none;
        d=google.com; s=arc-20160816;
        b=s8TJEPtbxZy/y4dtqSBkUdRa9gjIjEimqeIMZmtKNuaR86exxk4yxeH+BMCvuv70Rt
         UQXDG9Nz4Gl5Hzs0Sm3TU1haoyiRx2lhfOMAwtnTVK14X589iScKpYLH3AXLbzYSSLK8
         /VAvidndiATihwU1NHSQbdDy7Ofj89EnA/OiebsREwZmb4W5FunRaG61Wiph7LTQj7DH
         q1rS6FbJ/40GLmgsJSv5hfjjIteNyfwm2psdtqF6YL5b723bpRYNa8G39fMVJ66kccvF
         2qSXdYmtrOi3MP1CFEPSHl2Kdf9ZJbutyeW3ptVh5tGuvDaFnWYr0yQdtDLBjQKbtb2v
         KMrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Oal7flNQwT9u03yT3aAACwafEYYaGm4K4yZxV7zkB6g=;
        b=h9Po8zQ7dXfVb5E7VPzs1M8WNRekrDjPaYl5plDgjjyTmlDAnWXCH6F15+9nrxOdXd
         tT+CT4xi3Hh/u55fullNnpnfQ6IPEUabw94kfQLertc1vtpt1wsCxpB3CmK4avebTZl0
         CM5AqW2qkiqV+jxN15IFxzQh3Ar10ooivYTEKAJo/vxh1gT0XPHUL9B6bbS2qid3yKum
         MEpcYIzOZelroVYSm9glMxB0LafahhySCAaJIH1W+hjRK0KS4gH/hZ2utpRNvfCSYFcI
         dvNm1S09WN8piDrhy2TA12wBo+I27t4i2/V1TDPKk279VpIS5tuG8T6tb3LKuPOlIv0W
         U9Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p12sor3251534oic.141.2019.03.25.02.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 02:49:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzJNFY+7ARxSB+4c0sPo+9Jc49EQ+AENFDT1Rq9ALKT80u54QwmuukEqifSZ5X/P4w7O9C0yhDGnkFMiwI6NzM=
X-Received: by 2002:aca:eb93:: with SMTP id j141mr11026445oih.178.1553507352232;
 Mon, 25 Mar 2019 02:49:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <20190322132108.25501-3-sakari.ailus@linux.intel.com> <CAJZ5v0i8JiQGk25yZKQqTzCCY+nrfoKXOH8nM6eNPhkN-i+y9w@mail.gmail.com>
In-Reply-To: <CAJZ5v0i8JiQGk25yZKQqTzCCY+nrfoKXOH8nM6eNPhkN-i+y9w@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 25 Mar 2019 10:49:01 +0100
Message-ID: <CAJZ5v0ixukjWzSUqNCOpYuQci=7+ctdEhdZwOh=afz1b2zFVaw@mail.gmail.com>
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

On Mon, Mar 25, 2019 at 10:30 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Fri, Mar 22, 2019 at 2:21 PM Sakari Ailus
> <sakari.ailus@linux.intel.com> wrote:
> >
> > %pS and %ps are now the preferred conversion specifiers to print function
> > %names. The functionality is equivalent; remove the old, deprecated %pF
> > %and %pf support.
>
> Are %pF and %pf really not used any more in the kernel?
>
> If that is not the case, you need to convert the remaining users of
> them to using %ps or %pS before making support for them go away
> completely.

Well, this is a [2/2] in a series, sorry for the noise (/me blames
gmail for the confusion).

