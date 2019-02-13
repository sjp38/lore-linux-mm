Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EEACC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:24:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12BE222BE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:24:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SXZKFc0C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12BE222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B24D8E0002; Wed, 13 Feb 2019 03:24:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 761578E0001; Wed, 13 Feb 2019 03:24:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 602C38E0002; Wed, 13 Feb 2019 03:24:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3272B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:24:18 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q11so1327237otl.23
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:24:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7qNWB9rVEU8q8GRaLsXEEl1lIxUobDqlhu6T5ihfDLQ=;
        b=CsIrVh9sLHS3foGD4UcML6taEpLKDWOmCQE1mY3G6BElWXPRNxUzp6td6zjF6MOumL
         bhAVGRtOF7W2GbDAExNf7CIJjywnYF9AHxAr2jL5qrkxjsf6Sp+bcXriTur9niQipR5u
         m2NP2xSSX56r+6uCANSXV3aZlGe4Cm9AMZ8/9daywrgXaibVm6gFw1lPPV/yDSgDmTy2
         d2MsHHavRoCYTIzSaYZVeZtI/78A1iXxJZo/qhstuCvS0GeYk5kWGDS5ooMiimPrhB6X
         pnxkPf96WRkiSfS6/xC6BJIdH/4bShfTzgXoqgvtyimB3zSzAJtQnzab9W1fj3SQn3XI
         a0ng==
X-Gm-Message-State: AHQUAubEniPN9mbATRWg24pPedNrCVR2QaNDJ48CtBEYRcXjnbDoBlKO
	/eVVdTyClihBPCvDmgZ0zJM7F91KEwsAx06/MyMnkOhTV9BhaO4nZBdTdBDKAS7guFCRr1bgzXS
	LxSF1d7oimedOKTb0VUy49SNrE7q/nULfdQXNHw+7IicyzvvVnOWdHcd/BSkFrbmxYlwZ0hBsx3
	ht4nKXE+NlPTGcaEbq0RXRipCGp4VZWQCpj5lyPOMf17m56NvPoBlfDLIw0jLiQo3nXC3y7RpQE
	Egihy4G/nS64AbU5MRj4GnaNrpMkrN+1TYssmnOXe8PqhCA0YAGP+HZKzMpuIJ35L2R/94++Aum
	js7sYO/eiMhu45/eyqzwAAdPyEnfmHU1liiJHUN17kwpAk4VzYQt5Ymlif3QPgwEYi5O5zy/Dca
	B
X-Received: by 2002:aca:55c1:: with SMTP id j184mr464801oib.169.1550046257828;
        Wed, 13 Feb 2019 00:24:17 -0800 (PST)
X-Received: by 2002:aca:55c1:: with SMTP id j184mr464779oib.169.1550046256943;
        Wed, 13 Feb 2019 00:24:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550046256; cv=none;
        d=google.com; s=arc-20160816;
        b=WN4zJr6W1RBC5i9S5Sv7px1HtrEBWxYQsA9Bupccoum6B44SRslyYFgfj0AMK0JOrh
         H9uemHOdDfsawNJknbJpQ3mvbzLdR6c2C6iCVu5joDZi3/cKLEV1ik4rrT65QNDMa3SF
         CdOzCPr+3GhmnznrU974YCsy/XggHO5N2aXSOWrw8BlNh7ss3q670rneibf9UZR2kMoU
         MI5qQbK135VOOXh2hCivCCfLRbfKNM6RPTjrIjthDM9ETKbHwpMHUyKHlWw1xjuiX7Bl
         HPokH9bJqTsfuLai1dLvP+jKSwkEHfGs+QDheL4q4MJnbgETe/ie+RkzIO0rk2cMSWQ6
         Up8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7qNWB9rVEU8q8GRaLsXEEl1lIxUobDqlhu6T5ihfDLQ=;
        b=rDln8GGHWDOGvCX0/fOTK5jY9AhCVIDtZhCdABz77W4yE0OyO2mqRoItJgqp8/exjY
         aC3JgQO2xFXfur12QAYP9ZIFOC9d2tTvEYhFWCmH6XgZBXfHNrJK9uUbFj6G6mZxwRlg
         Vp4vwfZ3WH1MXk/Zzb/g5Q4kH/Q80+5difzU0HGoTHAqEf4MAZ93XcbPiSvzHQGXAp/k
         QkDseUo4S/qHERG1Fglm2xdPIexSg8IHN6yaODI9mMh+585fbk+C+RIEltA62LuWvRNb
         A2sFfsOuJeew3TLUsdDDgsj1WfXLZtigx/26aWsRkp7nt0uuEtSqBNinvjesgmjdat1p
         EFOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SXZKFc0C;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185sor6264029oig.105.2019.02.13.00.24.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 00:24:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SXZKFc0C;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7qNWB9rVEU8q8GRaLsXEEl1lIxUobDqlhu6T5ihfDLQ=;
        b=SXZKFc0CaiieBEMRJFU3IHgezclIzC4eOxNuvzXVBkX+ZMjTjEKcP/ZknRhxbwNDDU
         aVzwScUhnnYCm+ilVgGiA4CLnLMCTtjmRFyAAkf6uxcTkVX7iP5HUp8mAT3iHYVs1RwV
         iUY8LSK5UwCDWYnUB6/1vj+zqcJooCHzWSoZiXZyfYbD5r6vNxrsgNcjWa4XjdenIWTp
         9oRR2XB1/gzF1AVjiGdEHCbfcfbsHUdbihPmi7mk8aTM8aoZaJPlnuZFFEkrjxCNFynm
         vDMoJqpwj/cRLGKvcVP9m4z/3HAv6zZV4f5r16QPGrXQxvI1QgS/MSAb9LHHsrpL8LRL
         HnhQ==
X-Google-Smtp-Source: AHgI3IZRYsrcXjKGkoY18D+zNskgLx6ztmeOTYBqDscZ9Oco5xyF9ZcJycOeg27Bjd2oh2j5/bgEudDekSXCPbvG1LY=
X-Received: by 2002:aca:c3cb:: with SMTP id t194mr458706oif.70.1550046255452;
 Wed, 13 Feb 2019 00:24:15 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr> <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
 <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr> <CAPcyv4jF7ZyKaFDw7nb04UvWkVWGJdLGkZDQ1g=X7i+kdu7JRg@mail.gmail.com>
 <a3bfe739-228e-26fe-90f7-4a4f8ceb3a9a@inria.fr>
In-Reply-To: <a3bfe739-228e-26fe-90f7-4a4f8ceb3a9a@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Feb 2019 00:24:04 -0800
Message-ID: <CAPcyv4jJ=C7ZEsJqBxzBMsQWz4+C8BZmWuk7OkztOebprd2rMg@mail.gmail.com>
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

On Wed, Feb 13, 2019 at 12:12 AM Brice Goglin <Brice.Goglin@inria.fr> wrote=
:
>
> Le 13/02/2019 =C3=A0 01:30, Dan Williams a =C3=A9crit :
> > On Tue, Feb 12, 2019 at 11:59 AM Brice Goglin <Brice.Goglin@inria.fr> w=
rote:
> >> # ndctl disable-region all
> >> # ndctl zero-labels all
> >> # ndctl enable-region region0
> >> # ndctl create-namespace -r region0 -t pmem -m devdax
> >> {
> >>   "dev":"namespace0.0",
> >>   "mode":"devdax",
> >>   "map":"dev",
> >>   "size":"1488.37 GiB (1598.13 GB)",
> >>   "uuid":"ad0096d7-3fe7-4402-b529-ad64ed0bf789",
> >>   "daxregion":{
> >>     "id":0,
> >>     "size":"1488.37 GiB (1598.13 GB)",
> >>     "align":2097152,
> >>     "devices":[
> >>       {
> >>         "chardev":"dax0.0",
> >>         "size":"1488.37 GiB (1598.13 GB)"
> >>       }
> >>     ]
> >>   },
> >>   "align":2097152
> >> }
> >> # ndctl enable-namespace namespace0.0
> >> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> >> <hang>
> >>
> >> I tried with and without dax_pmem_compat loaded, but it doesn't help.
> > I think this is due to:
> >
> >   a9f1ffdb6a20 device-dax: Auto-bind device after successful new_id
> >
> > I missed that this path is also called in the remove_id path. Thanks
> > for the bug report! I'll get this fixed up.
>
>
> Now that remove_id is fixed, things fails later in Dave's procedure:
>
> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> # echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id

In the current version of the code the bind is not necessary, so the
lack of error messages here means the bind succeeded.

> # echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
> -bash: echo: write error: No such device

This also happens when the device is already bound.

>
> (And nothing seems to have changed in /sys/devices/system/memory/*/state)

What does "cat /proc/iomem" say?

