Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C2F4C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:56:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD18E20652
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:56:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cns3pxBj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD18E20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CDB68E0008; Thu, 17 Jan 2019 11:56:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57B078E0002; Thu, 17 Jan 2019 11:56:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46B4B8E0008; Thu, 17 Jan 2019 11:56:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A96B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:56:21 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id k76so3618051oih.13
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:56:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Rn9rsZuCSSjzYYPQ+62CJKuWjWxIhG5kt5EwxvzV0zY=;
        b=PY8+xVAPNj9is4NLKv4YQHnN6uj2gIVeQIzo9qKhKNkkFLO+ivJryFtmO1UVdxrad6
         3PMsDo7yNyGHDZSoXQwn09TcUm7+eEW7j9ktqjnEwPbx0s0zMd9WorrvezXdBHx3Bpqr
         V9FnVtrKCo75hJuvYGtiAipouhvuZNZsUCwKVFJQ3GYiYLFuaDhyHqpMhJq19TVqsIHi
         ecZxXw4LCBpNWlIH7WYPPx+nnLVrIQe9nRZskC3qafFNccQGY5St7lqRgi6845rXroX5
         6sqo+WsQzJM4EbOV0IOl799ABKNYmG8rUbG1zpNNrE7fNyoNBWwz/X+bpkv9tYeqz2w0
         eQ7Q==
X-Gm-Message-State: AJcUukc+jzdC85/I3cwopoZp20CkVueKA8l6g9Tq82UsHp6c/n0kWoTe
	LT5M2AIkhkdT//egPzmmveNLt080PTxdQ6Rmbd/OlLPwR+E0tBo+kDCqn4TQ1yr8H9tg+42+yQW
	HUrGQuPixXUw+5RCocpe/lA4bqR6n3HOMpvQv7UYy1PTeR5Gcw+ZOtsxtqxhEyph9a3E540qMJQ
	TbHI9xa1CJzbEsQiDRntto/uiahYBBl068EBc9+drTkrr0YUCMMRO+/P6dc/KmsJQB9Mn8WgXhV
	KvrwtVS3wVaCLi+VRQa3BScx3mkYldyPm5DwdMZhC9nKwqP05i6ollJ8vKiysWGaRSpuQratJ+5
	yf2B5d5KuZ+JVN0H43JE4WcjwNT3U82ufpJcxp8b9vdgGMHLDIJFvABSYe8a0C7t4GiQwtz0N81
	b
X-Received: by 2002:a9d:398a:: with SMTP id y10mr9369281otb.122.1547744180847;
        Thu, 17 Jan 2019 08:56:20 -0800 (PST)
X-Received: by 2002:a9d:398a:: with SMTP id y10mr9369251otb.122.1547744179960;
        Thu, 17 Jan 2019 08:56:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547744179; cv=none;
        d=google.com; s=arc-20160816;
        b=iNyfytpUgnMHCf4RFNNNK9meTLU31kOIBq6+3p7N1Wyr8YimXK7nV+QNEl+KKleiFE
         jv4l4V6+M0MIWEeScsczA/inGohizOBmsZ+kMUHBp4XRddcw3iXE99TsxESqwJbckYKq
         /zi+TTDewTp8RY6Xp8SDfyl+a1BUjg2kt96LqbJJs4fZ64ngq7Ivo6+k6ZB4fvkGa+G/
         NCzL/qkoFHVxpFBdYqdekSdQbz4JO1NWaguAfk+iU4k/Ir5WZ9u4OwA35fhL5TO2IJNb
         CUVzPSjZ3IuTIwMW/mnopCIjPbIelgPAie5jRgMHEQmiUKDklypb4rYnLuvg9Xf5b4jm
         Q2ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Rn9rsZuCSSjzYYPQ+62CJKuWjWxIhG5kt5EwxvzV0zY=;
        b=V+aIDHCN8U3f1BEXRUDAkTdHWhq9wMl2FgES8xItouaA67rS3Wt3dqR5lIPsJf+7W2
         9BZaMukRpZPWFruXsQMz8P4aoIL5PwYmMC72rKheo6ddr6s3zq2wmQXicPyhywQWGQlK
         BQFQa6YkRQGWQP7q6RviO8NOYF8Xc/cW463hefzVp4nLEKuJqXlwSFWUJ5p/FIsWnERR
         gqBqmTDCmSXusB+eVwrbYNZ2JVWGIYMM5AGofcE0o/vzdZKlXptCnPq+S3AWFwYftsJs
         lP5kLzjYZIwmDNqnI9q/y8sRP2okJSIgh5Wg5+l0ytioE4u69wvRXHLZB78ke1DIJ+dQ
         qptQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cns3pxBj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor1119286otr.58.2019.01.17.08.56.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:56:19 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cns3pxBj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rn9rsZuCSSjzYYPQ+62CJKuWjWxIhG5kt5EwxvzV0zY=;
        b=cns3pxBjqz2aeJW7ho3ts/fvTC5/fMjksg2ZBn3RDRN6Ce1LFr/eaNkkar5bCU2hD1
         AZTk8cC+zT9/gltc0y5w/xZH+fVckPgARXuwzx8/wGYnNNwcVBTYcGJcbrlCU9QoDODs
         OyLNR01z65fZ28+2QODVrb3NJ0PROp31Z30Oe4WEBUJaaCdonumn5bmrcBUF4/zDgV9c
         r2c7HwTUMf69pHmtSNr072Q6DiaLgp82NRO+Xnst8ocjX3vYAm1Gd72BlSqVptP538FK
         i9eMT6OKkSrShBWJ5zc9k4+rdybJnRVKJgDvlzSUqMPnwNFhYoQffmolStM0WYg57Spt
         7Jog==
X-Google-Smtp-Source: ALg8bN5kBBgKK8xzyu7fcYVTWd5irm9JOMtTRrCCpfXvQofB7v7nUulz8yc18vhIDbNF+9CMOfZAkNghbfqL+ruYv40=
X-Received: by 2002:a9d:5cc2:: with SMTP id r2mr9245443oti.367.1547744179510;
 Thu, 17 Jan 2019 08:56:19 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
 <5A90DA2E42F8AE43BC4A093BF06788482571FCB1@SHSMSX103.ccr.corp.intel.com>
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF06788482571FCB1@SHSMSX103.ccr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 08:56:08 -0800
Message-ID:
 <CAPcyv4heNGQf4NHYrMzUdBRw2n3tE08bMaVKzgYrPYVaVDWE9Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
To: "Du, Fan" <fan.du@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "dave@sr71.net" <dave@sr71.net>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "mhocko@suse.com" <mhocko@suse.com>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "tiwai@suse.de" <tiwai@suse.de>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, "Huang, Ying" <ying.huang@intel.com>, 
	"bhelgaas@google.com" <bhelgaas@google.com>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "bp@suse.de" <bp@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117165608.n1eFOkGkYFoWfJWbUb8bxS8w-4_iLNicYhItFlHzAUQ@z>

On Wed, Jan 16, 2019 at 9:21 PM Du, Fan <fan.du@intel.com> wrote:
[..]
> >From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> >Currently, a persistent memory region is "owned" by a device driver,
> >either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> >allow applications to explicitly use persistent memory, generally
> >by being modified to use special, new libraries.
> >
> >However, this limits persistent memory use to applications which
> >*have* been modified.  To make it more broadly usable, this driver
> >"hotplugs" memory into the kernel, to be managed ad used just like
> >normal RAM would be.
> >
> >To make this work, management software must remove the device from
> >being controlled by the "Device DAX" infrastructure:
> >
> >       echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> >       echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> >
> >and then bind it to this new driver:
> >
> >       echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> >       echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
>
> Is there any plan to introduce additional mode, e.g. "kmem" in the userspace
> ndctl tool to do the configuration?
>

Yes, but not to ndctl. The daxctl tool will grow a helper for this.
The policy of what device-dax instances should be hotplugged at system
init will be managed by a persistent configuration file and udev
rules.

