Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED97FC282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2C86222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:30:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qlBQx88F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2C86222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 395288E0002; Tue, 12 Feb 2019 19:30:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 343BF8E0001; Tue, 12 Feb 2019 19:30:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233D88E0002; Tue, 12 Feb 2019 19:30:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE78E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:30:28 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id c26so560530otl.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:30:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=xYmrRYaE5CixJaAgNDYErhzzOhW5/liHoijaul9aviw=;
        b=pjA4QQ63wW8dDQlXyD66C3h6cOxOZla6hraO4BC42SPkaiTMI514JyrzJ4QTW/8hP6
         CKjRy00uAtJwyyMhcB9XBGG5GLuOiP3D89D9OzjJ/SQ8P7bhAL71KyjLrHSuTnCDJ4k8
         c/EhMOwo+dh5NBoghWLC/0umObnW/4zPg0rlFBj+YXobocOHyT+WOKMjNozUmtPCUdjy
         LzT2hFaJAiCtKH+9UvAJgl9GGXnmPNUHzyrk0BT6+Q3ye8BnLSkX7XBRdP8k56MYeCOs
         CaxHj0pwMNS0arPiQpOu+M/OX3QlSWpZFdeaw+1vBEVGr8P7Jaq2HGIQuv3CPLx07mO8
         fQvQ==
X-Gm-Message-State: AHQUAuY1N2LF2QPpbxznEyrhkiSQlg4MoFIcd/yZA6ArN64RlhzZ4oji
	jhXWnup2vBuD94s3mKbX/y1bCU35izemAMp0U61TEOXTpOA1LCfQAx4rs3l4hBRp+dyDjfRsVYG
	uuvCXKwmUnw/KZFxJgvchk+OF1b7TkJwukTgJbbMApDgHurNxlWTU51+HWwiQO7TAfAai+jUb95
	u8109v9BLCIuFw+6XbQ1fqk87AXOcNQ5eDgQmyoHIYu0jTpL43djBs9I8+Oaj2EnIOSfvyKfU97
	QCKQ5HaebK07rEJC5K6wxLoKWhG6yfvV2E3MRL6TyUk9NKU3REmAdZOc15oOV6Mk1MZ3eG9fy96
	ECDxQmO35xDhV+3WvNqnq6maVnbIUV5IFiA4xELWu7dJXwTLON/kSEMpDj2afYCYsbgJQ9SYHnm
	6
X-Received: by 2002:a9d:4:: with SMTP id 4mr6966498ota.174.1550017828671;
        Tue, 12 Feb 2019 16:30:28 -0800 (PST)
X-Received: by 2002:a9d:4:: with SMTP id 4mr6966432ota.174.1550017827941;
        Tue, 12 Feb 2019 16:30:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550017827; cv=none;
        d=google.com; s=arc-20160816;
        b=EJ/Z//MHGb8eIyTACI4gQWzRhTVsJ2PSoMUldyyBt+MJCVWutUCeTA5ELy0FQZQiEh
         c6NMAnm1AWPDusu+Ue6WUHBoqGuIg3Ld4cyfeeC5u8OlCC8764q6Jk49AKhIX/6cRBC5
         lg63b3oOmhNcUiK1tzORzikcXhrPwl4npWWMiWoC9C2N3WJBlH6piB5ITbGPrFKX7HBN
         Lx3zac7N27TWTJYsuqPDY3N80Nk/yygFrMR7SU7nfG5Ct5vAqMS+oVIk23sINZxmpEh8
         C8u2cJ1EJzrzLmhlX+shqf+Pkfo0xtL9kXf/5TD6n5Q5hy7p6bClej0ouvbl0W34/0QV
         wv1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xYmrRYaE5CixJaAgNDYErhzzOhW5/liHoijaul9aviw=;
        b=nxRUQWkcTHx8a+qb48AwopgXPZblAqQF9ZddppR9L5GJ+5TL6taciFJSIWQ+e16wDc
         evc8b3edA9vC9KiAyZWtqP29qp0R+kqHS4pVwLGDOJf0eCzMFt9PFmMmxBrRrVawOc6T
         hE+aL/+ygJHgSWPK5Z6RWfdrRIftGHk3PyVSkV/Yeq801sQjY0dYY0UvYY1RdWpdYpDf
         uUD6xtIR4XibzSa19ggZ5i6qEeTX+SHrW6YLDWWe23Sns4A4RxYlB0hpNCPadBp7aJFF
         7CsHUUZRYg5ZerP+wg078GbJlynZMdTBRjlRJMTgnaizVa9Cgi08SfvnWPjNJAZ4WvfA
         UA6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qlBQx88F;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor521919otk.55.2019.02.12.16.30.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 16:30:27 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qlBQx88F;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=xYmrRYaE5CixJaAgNDYErhzzOhW5/liHoijaul9aviw=;
        b=qlBQx88F8mFF9E24rJbJYEin8dY3+oc9LNXKt4SgBaHFE/+5LXGpr2NGXaLT0rfAcP
         LWI1vJOmJx6Bt8XPXS/MvlU6JN/OOxnlcWoSnPzNQvQsbT5RgSQeRypgwEFeZ5M2GiH+
         qm8+q7tB9DuEv7KRXpnMECYSFd/3I6jXUXvJAnKXs3/Oxn9NUBmrp9g8nt1iGjUT0rCm
         Q3gRoJ57/+4MV/FqMvF4yZ/+RQ+qMqO7TIrfj3HCRBri0f0Js3YixlJ79uw485owxWkJ
         j40CorJRjQhuXwa4FLcfSmziGfyuDLMtb/ojuS7I9+GWXloUr/A2pnQyJXlYzMNaxdzZ
         ucpg==
X-Google-Smtp-Source: AHgI3IbMA5jS8OtFCWqyGp8ecfJjb71tiHb3rLH4HaRtzb9QD/QNIHae4Qa6Lp+aSsFufw7cfmFAkoT4RxAbmEdpvmE=
X-Received: by 2002:a05:6830:16d4:: with SMTP id l20mr232222otr.32.1550017827710;
 Tue, 12 Feb 2019 16:30:27 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr> <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
 <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr>
In-Reply-To: <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Feb 2019 16:30:17 -0800
Message-ID: <CAPcyv4jF7ZyKaFDw7nb04UvWkVWGJdLGkZDQ1g=X7i+kdu7JRg@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Takashi Iwai <tiwai@suse.de>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:59 AM Brice Goglin <Brice.Goglin@inria.fr> wrote=
:
>
> Le 11/02/2019 =C3=A0 17:22, Dave Hansen a =C3=A9crit :
>
> > On 2/9/19 3:00 AM, Brice Goglin wrote:
> >> I've used your patches on fake hardware (memmap=3Dxx!yy) with an older
> >> nvdimm-pending branch (without Keith's patches). It worked fine. This
> >> time I am running on real Intel hardware. Any idea where to look ?
> > I've run them on real Intel hardware too.
> >
> > Could you share the exact sequence of commands you're issuing to
> > reproduce the hang?  My guess would be that there's some odd interactio=
n
> > between Dan's latest branch and my now (slightly) stale patches.
> >
> > I'll refresh them this week and see if I can reproduce what you're seei=
ng.
>
> # ndctl disable-region all
> # ndctl zero-labels all
> # ndctl enable-region region0
> # ndctl create-namespace -r region0 -t pmem -m devdax
> {
>   "dev":"namespace0.0",
>   "mode":"devdax",
>   "map":"dev",
>   "size":"1488.37 GiB (1598.13 GB)",
>   "uuid":"ad0096d7-3fe7-4402-b529-ad64ed0bf789",
>   "daxregion":{
>     "id":0,
>     "size":"1488.37 GiB (1598.13 GB)",
>     "align":2097152,
>     "devices":[
>       {
>         "chardev":"dax0.0",
>         "size":"1488.37 GiB (1598.13 GB)"
>       }
>     ]
>   },
>   "align":2097152
> }
> # ndctl enable-namespace namespace0.0
> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> <hang>
>
> I tried with and without dax_pmem_compat loaded, but it doesn't help.

I think this is due to:

  a9f1ffdb6a20 device-dax: Auto-bind device after successful new_id

I missed that this path is also called in the remove_id path. Thanks
for the bug report! I'll get this fixed up.

