Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 749F0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:20:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3591F206B6
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:20:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GN1D41yy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3591F206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C60C28E0129; Fri, 22 Feb 2019 13:20:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C35FF8E0123; Fri, 22 Feb 2019 13:20:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C418E0129; Fri, 22 Feb 2019 13:20:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B68C8E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:20:21 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id s12so1390987oth.14
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:20:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=UiFqq9fKUY52GYBPs9UIqyS4mptDo3CU893hKHjGS74=;
        b=kOY1jABPw8jau95SukzCM8qaTZF9OoA4lEPGeGMmt3+w/8owlm5JnY9TJeKt22tSp0
         fay9TXqOuVbnNXx7c78smBBa9AaIay4JtFsrQVw9hxACgH1wT5W96v+jkwZ6ADg9Jx04
         qR9mzYbf0GZaznH8ylcezbHywe23L1cjpqCoiF3t5yHSUjQ8yUGmbqaoFiO7pLMUSe7K
         RI3NzXT/qSToU0Fd6ChG4so+240+9kX8xoLFGSGgLSNcMS6SPvqYq3bMAUmRs1yR3x3B
         OwnrEPankaPyYMcl5eej6UZUVFKya2lRbH09f37x6cu7ksXT2f403Igwa26tzld5U+z6
         o1mA==
X-Gm-Message-State: AHQUAuZM2TmtZUk4qRBVsp+jrFc6kCoplCpicwjOarGdtCAX8uoPvLx1
	FzNW+FGCGTbzZTWJXC4q/PbLWkXjQJ5kr0VVS+/pbx8fTUjXsmMDzjGJa6KnWsPa7/w3w6ULNx9
	3hzIjeeZwyPEBmbZxB7aJEV9OFnac7mjmJREdYF7E28X4Hjy1vjg0SY0Y6ffTgTfjkk4blZtGbg
	bP0RqxOLIaEAVyF3+Ku83mXvZfiMPyJ6okqP3DJlCz4UbfgQYD7jU4yeEVn4LGcLR3nbDt5grpj
	IwfbuYNPBeQmLI7rBrRxFX09njQIODqRRBUMOlYUmCkofzQI78A4impCnkAH0MTq6m8XZuHzbM7
	Jd8bR5v5h3hEyw+UA0OZg+OOScP/w0OW2/CsRno7ZfCUbwmXkQQ0jxUx6BziVFgC8TSxRXUZkbP
	O
X-Received: by 2002:aca:b104:: with SMTP id a4mr3336067oif.133.1550859621242;
        Fri, 22 Feb 2019 10:20:21 -0800 (PST)
X-Received: by 2002:aca:b104:: with SMTP id a4mr3336030oif.133.1550859620363;
        Fri, 22 Feb 2019 10:20:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550859620; cv=none;
        d=google.com; s=arc-20160816;
        b=N8TubUJRjx/VwescRn1QQr5vzEa6OBollqWzp5YIo5prbdmlA1CR7Ihqt8AXrRwHUv
         4tLrWChBNTNmesNlBTMd56FXG+BoyJaam9exm5x789w+Ywkt+KLCwihVD7FH4NDeeII5
         l05wLl+o9V07+/3Dr01rqLoXDlJCQmT39xvHjBYaW7OhwJRGUDujWJ48teeBw9mw2RFf
         wUW/5fe2iAdjtibOt+qMZ6Kh+C9BbtnxqrPNkhFOOCstykyWt6pa7yy/7bNdDYUbNlpV
         HG2V1w3SsJBCLLcxyDMsVgp5FJjt6cm1y25Wvf2oGumtskBnIUGTMKP9ySayQ12vdNfH
         7XDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=UiFqq9fKUY52GYBPs9UIqyS4mptDo3CU893hKHjGS74=;
        b=yXQLCMwpsE+y0LaQiG+s6o2hZkoVWY2lu3HiX43UxDXA74dBoD9XY/IM6FyKSEYMDQ
         yxjpopQYSRAE+wHfGVck3bsXnUO/DE50hoW5IYK4hqrn0hjPQKHGQHRaqfhD4JZgKa/5
         QQYMJJVfVPu4A20Ycl5Rmh4k2rbCFequWIIqQuRMRGebnJ+f18HsKGNU+5sNYxQEn2kX
         gkyjxlRCTW0hEYm4Y1viWOkWacQoADS8osmh7UReol5fW5gMqZbrb2U1YqfNkQBswD1c
         Jy0FmnX69PUwlhVP3xWaMtcdRWkmZCePUh57FD6Q1UbRkHihmJLhjbXROyVPfN3riM1n
         TMqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GN1D41yy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e127sor1164374oib.70.2019.02.22.10.20.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 10:20:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GN1D41yy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=UiFqq9fKUY52GYBPs9UIqyS4mptDo3CU893hKHjGS74=;
        b=GN1D41yy989ENSk/QaWlIPSo80f0ecxNC50ye26M8YOCiIc0C43TXgsMFGuWz7RT+H
         bK3/xGZRWd47wfLf5VW9mIyR4zdpAyw9YG/d+HfKhwkEX7fXuf0krOAuXKTivczfMkQ9
         fEMRPqKfupripK8WyiBo1CmsL4GFk6waMmOKGxI7xkkaGoTK1vpaup1DPcJUPkqS1don
         f3zBOuFxwizTC/RJH8GLJwomUdcCeRGZdv4Iy0Ys9vzRe16gSgojWFC+3KEv05eUpDei
         8gNzcU4aCFXVYdFo7/ml34OOOgzIPqNts2RVdBtBY36x548tTuxpPdW/MxZkK6O3ZjS1
         GNeQ==
X-Google-Smtp-Source: AHgI3IZ3GjohG8ZeA76M7eOjYWudq1T/tMGFoHWrlRHyeUncjvHws5E6JvWGfIvPEESyBMwC3C4GI6y40ZeIw13ln24=
X-Received: by 2002:aca:32c3:: with SMTP id y186mr3201069oiy.118.1550859619873;
 Fri, 22 Feb 2019 10:20:19 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-7-keith.busch@intel.com>
 <29336223-b86e-3aca-ee5a-276d1c404b96@inria.fr> <20190222180944.GD10237@localhost.localdomain>
In-Reply-To: <20190222180944.GD10237@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Feb 2019 10:20:08 -0800
Message-ID: <CAPcyv4itkDiPYAqkT4e0i8nQXKAEZCUQsFk8jACEJ__tZwUh3Q@mail.gmail.com>
Subject: Re: [PATCHv6 06/10] node: Add memory-side caching attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Brice Goglin <Brice.Goglin@inria.fr>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:09 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Fri, Feb 22, 2019 at 11:12:38AM +0100, Brice Goglin wrote:
> > Le 14/02/2019 =C3=A0 18:10, Keith Busch a =C3=A9crit :
> > > +What:              /sys/devices/system/node/nodeX/memory_side_cache/=
indexY/size
> > > +Date:              December 2018
> > > +Contact:   Keith Busch <keith.busch@intel.com>
> > > +Description:
> > > +           The size of this memory side cache in bytes.
> >
> >
> > Hello Keith,
> >
> > CPU-side cache size is reported in kilobytes:
> >
> > $ cat
> > /sys/devices/system/cpu/cpu0/cache/index*/size
> >
> > 32K
> > 32K
> > 256K
> > 4096K
> >
> > Can you do the same of memory-side caches instead of reporting bytes?
>
> Ok, will do.

Ugh, please no. Don't optimize sysfs for human consumption. That 'K'
now needs to be parsed.

