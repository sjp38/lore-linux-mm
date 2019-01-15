Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B742AC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 18:36:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7713720657
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 18:36:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7713720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CD48E0003; Tue, 15 Jan 2019 13:36:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B718E0002; Tue, 15 Jan 2019 13:36:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B2F8E0003; Tue, 15 Jan 2019 13:36:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16488E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:36:16 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id d93so1397796otb.12
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:36:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=6whWxQj1PvY5/IZ0ONf2GRXd2Bc5qbpQtwcWDSqd98E=;
        b=VH3lruY8BeQg2O9xpW26fnb+Lx7dLUog4CT9v20Q0o7yrHt23jX1OLq65lzdN9J9vZ
         ABFwrJK8RAQkeuwHgGSVndFlyK7n37hvKTrzWm2HstMQrEP3QxaruedP/gitKwIbgfpS
         s1nfNKcGUb1M2+3ybR6DCQAIudeSCpBgKhU+FxeZmf5adjHgfysfl8/4wJdvHoJ3wz6v
         BFCzRXHReLNz32t3udBeCzVzr6Y6kiXjhX3q6vSBhzrgKe4VbFQhMPnSiimnQcPXjSke
         UP5y0eE79kFndHKsKZRwMZYz8L5hSv9m/Xe2cZUmVZueaQgpXiXzZcaJcd7DAQOwgjnk
         LjBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdP79PlXxWqjsq24Zklit7OGKmjiKZAa3FRSJcu7tBk3SloYa6s
	0pa0Tk65KO8KatZZwqjoTU37akTYY2tvL4I9KY2MO6VdylaO1UpeLrR7qF3CYKSN/O8SP5CVPMl
	sjfW3Qe3PmUUWTIOpY0NC4+G3rvdZrc6ODvXVz+Up33kAw1QpxtJDNbAkaAZh4iPgA3sO6/aPEf
	2Ux8bnEYcWugpJ069LbgE5LqWuJJ9g/3c6hG31J8f+7o/BwxOws9RyJ6TY1Fktd8EqRhoOfh1wK
	3VeBZ4EWAURIL4EHBCaUaQzWdMJ8rvLfzJFLFDmWB8OeCtMh1fFIIFsehjLe/lz0h0NjOLyXiZZ
	/zZZLoZ7aybqy1t5FuttdQxcsspZWEOMU3JvI8mk2KK9ZqvvCaIVvTtvKQTQrS5k58bnqKNzEQ=
	=
X-Received: by 2002:aca:5a88:: with SMTP id o130mr2784961oib.275.1547577376425;
        Tue, 15 Jan 2019 10:36:16 -0800 (PST)
X-Received: by 2002:aca:5a88:: with SMTP id o130mr2784919oib.275.1547577375280;
        Tue, 15 Jan 2019 10:36:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547577375; cv=none;
        d=google.com; s=arc-20160816;
        b=MKEFlNussQtLneRvlQ72MWA7779gXq07a3GMlTGtocv8p20yOO+SbBnqypqtBt9Y6l
         Kvv2V0EsVDTNnxoXu7q5LzBx4mESoImDLM5sw9Rlg/f/C/Yw1dmv9hJQPnoDIOAEr3qc
         yR427BJn+MJFIwrIhFaVGM04EYiu1IcunCuNpUpiYCjI7l5qiMVSwyB19l75YEXgq4SR
         Mu9pLA9nrn0D/R1gAuSTleEQkvgXMQVwi69w+P5YVGiSJb984wXTpn8aQ9YAu8yM3TM+
         9mJyK7py02+QYrFRS/tT+20QGo12tcaDYk5nW4k3RdDfrRacK7l789TJQUWavgtx85y9
         b3IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=6whWxQj1PvY5/IZ0ONf2GRXd2Bc5qbpQtwcWDSqd98E=;
        b=x2ZWjSNCZB1jgOmmWB9E2ODUW4tKn8m2JTSn9aWaOuJELJ/96H2ncF1xs0h4O0ElS0
         3By2cxwjSatsN17UZODnZmBU9DMFbkWA4cR4W/FtTBvuaU7Fl81lVFkgPzGRcHVBZgoC
         vQ9omx6B2rMaoi0M1+H1jX4LU7Chq3eOlIl1ZDQcidoo2n0qcefAQj7EGT1B0hRcYwEs
         CCPYFaNxkTwKuQAJ111CbQylCnrCjmROvc2u3M8++rKtLQgJs++0Yl5XAJs00nmavzL/
         hbFVaVfFoFOUGYbEYoBuv9987watdp6mypZKDl1Jw7yShJlJPahFaiM3F3qJSczP2u6c
         AFvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w23sor2526800otm.189.2019.01.15.10.36.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 10:36:15 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7DseTTxUHUENdb528u6E1TBRIwSxqG5pbAKxMPUMw2+g6sVORGUH2S/S3Y5FxtVxtpmEw/tPK3vzccvQVv4Bg=
X-Received: by 2002:a9d:7f0d:: with SMTP id j13mr2996913otq.119.1547577374860;
 Tue, 15 Jan 2019 10:36:14 -0800 (PST)
MIME-Version: 1.0
References: <20190109174341.19818-1-keith.busch@intel.com> <20190109174341.19818-4-keith.busch@intel.com>
 <CAJZ5v0jk7ML21zxGwf9GaGNK8tP1LAs6Rd9NTK5O9HbzYeyPLA@mail.gmail.com> <20190115170741.GB27730@localhost.localdomain>
In-Reply-To: <20190115170741.GB27730@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 15 Jan 2019 19:36:03 +0100
Message-ID:
 <CAJZ5v0iZ_i9vOPJgn69T=f8KE=fFm1vQt2AuEaNDGpn3E_cL3g@mail.gmail.com>
Subject: Re: [PATCHv3 03/13] acpi/hmat: Parse and report heterogeneous memory
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"Hansen, Dave" <dave.hansen@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115183603.umjLYML84PqxwnS-ytSsPuzeY8F1xZW-oLR1yfi5LVI@z>

On Tue, Jan 15, 2019 at 6:09 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Thu, Jan 10, 2019 at 07:42:46AM -0800, Rafael J. Wysocki wrote:
> > On Wed, Jan 9, 2019 at 6:47 PM Keith Busch <keith.busch@intel.com> wrote:
> > >
> > > Systems may provide different memory types and export this information
> > > in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
> > > tables provided by the platform and report the memory access and caching
> > > attributes.
> > >
> > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> >
> > While this is generally fine by me, it's another piece of code going
> > under drivers/acpi/ just because it happens to use ACPI to extract
> > some information from the platform firmware.
> >
> > Isn't there any better place for it?
>
> I've tried to abstract the user visible parts outside any particular
> firmware implementation, but HMAT parsing is an ACPI specific feature,
> so I thought ACPI was a good home for this part. I'm open to suggestions
> if there's a better place. Either under in another existing subsystem,
> or create a new one under drivers/hmat/?

Well, there is drivers/acpi/nfit for the NVDIMM-related things, so
maybe there could be drivers/acpi/mm/ containing nfit/ and hmat.c (and
maybe some other mm-related things)?

