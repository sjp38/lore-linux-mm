Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD2CAC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 23:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 685692089C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 23:13:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="wZXK/rGx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 685692089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1C96B0005; Thu, 20 Jun 2019 19:13:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA1F08E0002; Thu, 20 Jun 2019 19:13:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB8BE8E0001; Thu, 20 Jun 2019 19:13:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 931596B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 19:13:17 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so2003901oti.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:13:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s1U8b9i28hLJayWU6+c6YVAvl2Rop3SMymokvtyzh0o=;
        b=nUrhPz9LwsNyt9Tif5fMuzXjOmHTPN3ZJQ1OEdiZsaMnIOq7ZxStYjLrqLBltu94Kq
         DpBVAAqb2fUvkIK65u7oub42nlLtWrAR3a+ox2mA7PSgK61F6+q5QjO3cmP3j8j1SDHg
         IEvOKZ/PBy6sWjsK85g4PCb7B5R4iUJM4DotQHSLI2RjYifz+orVqQkDBlyAePaIZpCq
         GbjgRjQvExzqMmZ+uKNouRpmcR6M00mZQ6byxRajoWbKGPz75A+iY9J4iEvVxNTblVFd
         nlnxjoDGyY7uzg5J8ciGleuPwFymX2FLrpke7Rk8HWC6HX2iAcQbyV29H8fluIWa8/Jw
         B4dw==
X-Gm-Message-State: APjAAAWmr9bt4QMhXIjSEj0esY4t2k9bTB4oHTiG3ligbordxHB+B7f/
	KyBL9GJj+tixSlr9VHta8Zi+r23ptSm58KjZ0TqH18ALUvtfNtlFsrv0DjoEqcuR49y6nHRLu88
	Mv10st0XjmC14IjJZ30EBedZ/iKrJzJmePiS82CBH5D/EXm2JU1U9LDG43kb+eD5bJQ==
X-Received: by 2002:aca:5883:: with SMTP id m125mr937038oib.58.1561072397221;
        Thu, 20 Jun 2019 16:13:17 -0700 (PDT)
X-Received: by 2002:aca:5883:: with SMTP id m125mr937001oib.58.1561072396256;
        Thu, 20 Jun 2019 16:13:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561072396; cv=none;
        d=google.com; s=arc-20160816;
        b=fI0YpTLiKy8VA3AbptpxnQzxCIx1r9EoMC9sw8UhBklQrKY+H1jqDw6G3zCkRymuPE
         3uL658SVCcUjxbRWv48bjU1cNBak7wLHG372sDinnwoTpTYz9JZ8dtmvkCtDve/Exnk+
         bOXMeXY+JKxIwT5rGtWthiN85p7ysg/GdAFrCqiMuShCtPwpvu9bTrG5uAwB/54ZoWZv
         N3CKlrjZUnj3wdKO1K5P7LXz5EITK+uFlv4b5RRNYkrhqcBVYOEF6dQqjhwOeF2GMxSs
         F90h6Ttw00pQqo1vmyBrqx2XeN4uMe0CH6ORkRuFQwwXgDhUXs3UhrGi9iYAogMUHQ+l
         CU9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s1U8b9i28hLJayWU6+c6YVAvl2Rop3SMymokvtyzh0o=;
        b=xQdv1WvmKXML+c/6haTiof9mr1OeQdCLFPo781OCo5aMBjOUJH3gIpyDdM3q4y73ap
         HsWCd7W3b8jBaarfwyuGHzwz5AEo86E9B15t0xnzQ8medYAIndtfxX/DHZKHGqkxsrP8
         41KkylmI3fvjzjU6wYwRG2LpnqfHcSx6xrlP+RNZquuyw8Dbbti8F1PZ1IOWC5tfHc2q
         CN/Edx+n/XkM1PCOGduu8g61hX5uaRZ9AVIoGdrWoLf3rV1zrWnDTcfo5EU7oXiB2a9j
         IQ+RPYu/O8NK6/GYPoYR/75Qgh+BmrJh1M9LSNa9PfxVqCXZCdzVjVaxoTw0bxiDdVY0
         OXjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="wZXK/rGx";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d133sor458313oif.35.2019.06.20.16.13.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 16:13:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="wZXK/rGx";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s1U8b9i28hLJayWU6+c6YVAvl2Rop3SMymokvtyzh0o=;
        b=wZXK/rGx3xr+u7oi//RllS+oGNo9Tzry/ML+vUVpgS/Zv+UVNj64dDUV96UYUd1Jn3
         HTEz2HrWATyMseQ9ESDNMngt9dsb1UfHOlUe8zE/5wDSyS1AVE4ZRpittyrzTTchLos5
         4eYsM6eY6GbydQyeJ5021LQYq2W4FXOMsUpMRrhldyeNx0gkDVyn8cVP0JPDGRXYNHA0
         Khcxwe9CepLmmm4wC6aJwDUSLxUAkLS7QB/OjbTbUQGW9ZgOSJMHsxAIyonm6fZ1Gisx
         DP1+rtOY4WuxwcsaUVn8PkaGb7RTOOyiGjDW9YizTilPtgcvoQvLQUcgY/Zjj7YawYJt
         OuAg==
X-Google-Smtp-Source: APXvYqxf0VmRIyLU90bg8tJ1rHATTJ0aCa2jorETk2j+MQarpeuMzOl/bF99+OKywGM9BxnPQWWwQHFQhni6/xxki/w=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr917887oii.0.1561072395816;
 Thu, 20 Jun 2019 16:13:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
 <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com> <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
 <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
 <CAPcyv4iAbWnWUT2d2VhnvuHvJE0-Vxgbf1TYtOPjkR6j3qROtw@mail.gmail.com> <8736k49c57.fsf@firstfloor.org>
In-Reply-To: <8736k49c57.fsf@firstfloor.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Jun 2019 16:13:04 -0700
Message-ID: <CAPcyv4i1YYExVtXXdkCMgRvjqoeTkZdjwDVjf=sJN-qPF1LEtg@mail.gmail.com>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
To: Andi Kleen <andi@firstfloor.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Nadav Amit <namit@vmware.com>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, 
	Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Ingo Molnar <mingo@kernel.org>, "Kleen, Andi" <andi.kleen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 2:31 PM Andi Kleen <andi@firstfloor.org> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
> >
> > The underlying issue is that the x86-PAT implementation wants to
> > ensure that conflicting mappings are not set up for the same physical
> > address. This is mentioned in the developer manuals as problematic on
> > some cpus. Andi, is lookup_memtype() and track_pfn_insert() still
> > relevant?
>
> There have been discussions about it in the past, and the right answer
> will likely differ for different CPUs: But so far the official answer
> for Intel CPUs is that these caching conflicts should be avoided.
>

Ok.

> So I guess the cache in the original email makes sense for now.

I wouldn't go that far, but it does mean that if we go ahead with
caching the value as a dax_device property there should at least be a
debug option to assert that the device value conforms to all the other
mappings.

Another  failing of the track_pfn_insert() and lookup_memtype()
implementation is that it makes it awkward to handle marking mappings
UC to prevent speculative consumption of poison. That is something
that is better handled, in my opinion, by asking the device for the
pgprot and coordinating shooting down any WB mappings of the same
physical page.

