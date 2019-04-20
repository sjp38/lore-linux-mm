Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41247C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:36:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5FE320869
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:36:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="tPghUGKQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5FE320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1C46B000A; Sat, 20 Apr 2019 12:36:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 777BC6B000C; Sat, 20 Apr 2019 12:36:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 619636B000D; Sat, 20 Apr 2019 12:36:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F08A6B000A
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:36:54 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id q82so3364429oif.7
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 09:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yj9wzn35auL/sy+jXnnA3kG5x9sxPBjJxZokaO093PI=;
        b=mODLrU/OTDzJ1IwzofrL8JhLjXUk3t0cpyybSUxdDbI0BPNERvW1TlJOPwwHKePuOd
         bX0w7+c+MmkdA3YWOUil7F3LGLSiui5kt1zhNNzCDf53oPGJXTjW+qWiSrjV9aIP36C6
         z/PGTLzw2LOTc6gKHyFa8LotdyKHjpsLJMqmkvr679YC4d41X0/jFOVJtRWQTbX0hz3Y
         QziuwUPqEoWVxrPsCz303Z0KhExPTi/4VE8jYc4SHj308+rFvy8JOGz+qcV8VeCiPf6T
         VHA2yF+zce6coPwuODtZrsnicVJgVkAQPn7lEG64ujRA9UHGxxcl8mCWosrNRybOJWbA
         5icA==
X-Gm-Message-State: APjAAAVJ2s2d+0FYvyiFKaTGkyVfj3QvIAPOvb45KZ704rY/Ec9UuzKB
	BXXGIrakI3IiAn4frDe3YA+AWs3arxJQOjg5ZeUxy77cyLpHKaRar6U5cameF2PCxWTUSRpKecG
	CDi5l1bR+GsBbnml1UfYodMkjHR7YLKlf/Y9CoqTEFcxOYDmujfmzs6doZ4Zz1z+4cg==
X-Received: by 2002:a9d:3289:: with SMTP id u9mr5813073otb.52.1555778213919;
        Sat, 20 Apr 2019 09:36:53 -0700 (PDT)
X-Received: by 2002:a9d:3289:: with SMTP id u9mr5813056otb.52.1555778213416;
        Sat, 20 Apr 2019 09:36:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555778213; cv=none;
        d=google.com; s=arc-20160816;
        b=gPhT3S45ork0xo+HHh0XZK9dw38OiGrxiaty6kOwENRg/uHD7lG3Fcj1X/xz3cVb/e
         KerMKdvnEf8yQLCuLYitTHtZcsi/L+Ky1GZQGaE2z871aD+34AzajF4f8OzxKBkhNsEH
         J/E23kNhT9UEIzei52g67EGXheO8pM/L5nyFdohjGgqfvw2B3+HZX5ArBUvq++kYz2Xs
         Prss0uuGO2tvYYjhOhQpI2ib3kk7LTmtuLoh7lrtWt1aMJ6pFQdwK50w4MRyuC8Y6lpp
         UsCGlEUZvTg6yoMm6LKjJKCCezjcfxa5IDaT7Do4xMab9wtN6woQ+4YZkT8Pfuji2TBK
         ztqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yj9wzn35auL/sy+jXnnA3kG5x9sxPBjJxZokaO093PI=;
        b=U8Tl0cr9unC3wDfxvhTkMn6cPML6tzUt3F+oYm1+ubjtCng7aafBgfGCgTSBn03rOQ
         G6lajbcS7TkIcQOrvOdcBa4NGHURmpnwW0QTJGzung00OJKQjp8qXiK2Uj8xe7gEHNkG
         QcZUVJZBhyCIgW9WXw9ETRg1VxedeunpTqDK2Hi2PC5Af1+kH78phiWR9wjQZq23du1s
         0W5wWH9BE2LcOvEYyALZfvnI7PNhztMmKq1m8AFCHQK0AfFuVxq8qRJwkgu0tl25/Zjy
         l4MISpyRjGm+spfqTPijLm8GXYB+j1Rab4oVjfTJqnS1ui7fFnDFl8nb//YfujKX8ZkM
         PZsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tPghUGKQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n25sor3622281otl.157.2019.04.20.09.36.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 09:36:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=tPghUGKQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yj9wzn35auL/sy+jXnnA3kG5x9sxPBjJxZokaO093PI=;
        b=tPghUGKQh0cLGJU6m3fdkw/7IPhUn6LLqAMqIPccD7pU/MGSMAoDbnY83bNFuM0Shl
         vz3Krc1KFnuWrOfWorXcTz4RAiCLlQmfU4+jwb96HL3e2bdEGprYA2cyVwX4VIniU4za
         A6aV5MbgH+kDYiOy2ADx5HX0wMukiPJurTuVXE/Ftdt0KJioibI/jgHYge6T5MnNubDo
         9oKlWsfw8AKWH8H+M7ntLv7/5vQ/RexiW6lPjSCsV7s/fLD8798d9bQwVwm+eoyM3Fi1
         kSKnfDCrG/8u3Qd+/5kpRzvzQb0aE2r/yzjwJIbNm9C2tgW/6aINii+/1N3Hsxbm+mar
         HH2g==
X-Google-Smtp-Source: APXvYqzL5JYERjbiDNCEXZALt3QhyTy3JQjWs/OIvsY4rj+Ml6k6gcqZT/mGbyQrfTzoWXSzMMeI5ThK03Y/AvVXJp0=
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr5606295otf.98.1555778213001;
 Sat, 20 Apr 2019 09:36:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
 <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
In-Reply-To: <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 20 Apr 2019 09:36:42 -0700
Message-ID: <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 20, 2019 at 9:30 AM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> > > +
> > > +       /* Walk and offline every singe memory_block of the dax region. */
> > > +       lock_device_hotplug();
> > > +       rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> > > +       unlock_device_hotplug();
> > > +       if (rc)
> > > +               return rc;
> >
> > This potential early return is the reason why memory hotremove is not
> > reliable vs the driver-core. If this walk fails to offline the memory
> > it will still be online, but the driver-core has no consideration for
> > device-unbind failing. The ubind will proceed while the memory stays
> > pinned.
>
> Hi Dan,
>
> Thank you for looking at this.  Are you saying, that if drv.remove()
> returns a failure it is simply ignored, and unbind proceeds?

Yeah, that's the problem. I've looked at making unbind able to fail,
but that can lead to general bad behavior in device-drivers. I.e. why
spend time unwinding allocated resources when the driver can simply
fail unbind? About the best a driver can do is make unbind wait on
some event, but any return results in device-unbind.

