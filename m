Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8D68C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:30:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63EE520643
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:30:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63EE520643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2FC08E000A; Mon, 25 Feb 2019 17:30:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADF5F8E0005; Mon, 25 Feb 2019 17:30:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF058E000A; Mon, 25 Feb 2019 17:30:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 793758E0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 17:30:34 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r21so4599231oie.11
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:30:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=0H1UNo5cnBzQ6xk3pF443nacMcRPoc4sMQBqMlH67WM=;
        b=CLsicXShfXSNaMGlekca8zca9ILlnDG+f18YPUogXgBWJUD8NVD4LLNB9h9jYd29n2
         j1dLOzsHG6LXv81M71ML3hBJEHkfGH4NiN1/9LANXtFwb0hDmOV4+USRQUNR+OKlLJqc
         yXRnstQ9hDNfbYyv76AhwGiIDdl5ALfzpa6AT9DeMnfdeauERswjw7qpPB6QGtv5Kwle
         15SgkwxCJV+QoQmWwBG/KE0byvQ9TwG8KTFHR+YWk1kQEr92uCLRB/vNaD/fcWGh3SJ5
         fuaRhq6FRcyoovSfM0zBETb3znP7moNPeEzneX7LvnLbvamAqcOm+RkROwL7vF/s+g9r
         Xx0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubBJjAPfca0wN6DnG4aOqfklJuKbzowC5SmwvClL+wOkA6cx+dV
	p1F0uUjMH9rhuxGoGjWi4njFSBVYoLOjWvSkNXBU1spjBczl7RTI2PgXE377XKNOpb36XbCSS8c
	Jz8QHnOkaxESMyM9VBG0Eq6JU9seTzU2WCFTET09GKFjXcMxuMnYG1ZjriZMorGWm1e3L0cdo2q
	UV5PZd8L5FAlCbsgczTfKJ3dCfAR/ZUxN5o+Dm3l1R6Lw9iihneOmA2cPyRhDQkgeK49X3TmGoZ
	JNYkxkF+DNayjVO4nNLB2bD1GqpxTFdoWuC4EdP1lwZQSZaXbTED3LCdhlHYc9fbniF3vzUzCQi
	lEUAu/8Qf9A/jxYTn1XhneuVfzUbqLrT6yId0vx43fVx136TYmKSFevfYhb4/iadNf9BObVNzw=
	=
X-Received: by 2002:aca:75d7:: with SMTP id q206mr400174oic.66.1551133834132;
        Mon, 25 Feb 2019 14:30:34 -0800 (PST)
X-Received: by 2002:aca:75d7:: with SMTP id q206mr400131oic.66.1551133833233;
        Mon, 25 Feb 2019 14:30:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551133833; cv=none;
        d=google.com; s=arc-20160816;
        b=dtSEvFzADuVT/+eCTIs+8CH/h2OJZ7iPTQipyGZM5L3UFMWIWFZQu73WcR6AfvxASv
         8e6WLTtprJnHiG0e+ha+rsDSYT1lG1sxFSPn9nQQkofqBT2AySq5KjAkLpCSwbU+QjsJ
         /qVi8q1abqThwz6m94pflPTNT/Z8uA4bs7UhWkivoXQNAPTR7YPY+j2SWOdPHc/3gcee
         ync3x8mLGJPtPXtXaDtbr4NYmdDfkstcH4gN/Zzv/h6KZ3wFiYz4hfqLtDe0bh/B13F9
         BhCSYX5n7BcOHo3eJ+k5Iz1mKEip+bmsFcIuuzS4jPiUlnUF+N5UT8FhQqk3moke74n+
         m9og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=0H1UNo5cnBzQ6xk3pF443nacMcRPoc4sMQBqMlH67WM=;
        b=Pc5pxiVwKbHNLfgXlzDg/ztTIXxXMw8L+gZyxhHOxiuZRE+nNBKflm7cccdg2dCK2Z
         YywTRvEdbyX5WmQhUvH1mHwZHtHAdMpfxkgju8BSGjUkPqxKzHvJ69S5UdaUWtYrcKU0
         XKAYhED6Q1+P5SveKqf09fj8Ce9Eu+03jorqWnxzdwWtZzK4Mb2TYfiCB8gpsREqdtRb
         5FS2e5eyZKH8jdawfyb24jtjSco9VcEUt22vsVVEBelUmjGo5IBFoDxc1dJ/UlBwO1/+
         aCvg3brb7uD0oTa04DWYewkfTu2y1sviD4qxOgc/8oyeBuHkslAN/fzkXyRyg09UQ5NQ
         20tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor2167899oih.141.2019.02.25.14.30.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 14:30:33 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbbcCEZzvJNaOzogXR16NVmv5uNIGRgl8l0BB8IKzI8Q5XCD2ZvRD4WoTmvZkcOZvwPt7crMexu8ico2zzKXQc=
X-Received: by 2002:aca:f4d3:: with SMTP id s202mr401553oih.178.1551133832532;
 Mon, 25 Feb 2019 14:30:32 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <20190222184831.GF10237@localhost.localdomain> <CAJZ5v0hfQ5HWT0kfaOxSbpJvdqotsMWVBCZ6wiL4Tnuy+O5O7Q@mail.gmail.com>
 <20190225165118.GK10237@localhost.localdomain>
In-Reply-To: <20190225165118.GK10237@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 25 Feb 2019 23:30:21 +0100
Message-ID: <CAJZ5v0h+YN=QYReLoeYMqM82Z1eaEk2kEy6jZ94JVe=-By8gTg@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 5:51 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Sun, Feb 24, 2019 at 08:59:45PM +0100, Rafael J. Wysocki wrote:
> > On Fri, Feb 22, 2019 at 7:48 PM Keith Busch <keith.busch@intel.com> wrote:
> > > If I do it the other way around, that's going to make HMEM_REPORTING
> > > complicated if a non-ACPI implementation wants to report HMEM
> > > properties.
> >
> > But the mitigations that Dave was talking about get in the way, don't they?
> >
> > Say there is another Kconfig option,CACHE_MITIGATIONS, to enable them.
> > Then you want ACPI_HMAT to be set when that it set and you also want
> > ACPI_HMAT to be set when HMEM_REPORTING and ACPI_NUMA are both set.
> >
> > OTOH, you may not want HMEM_REPORTING to be set when CACHE_MITIGATIONS
> > is set, but that causes ACPI_HMAT to be set and which means that
> > ACPI_HMAT alone will not be sufficient to determine the
> > HMEM_REPORTING value.
>
> I can't think of when we'd want to suppress reporting these attributes
> to user space, but I can split HMAT enabling so it doesn't depend on
> HMEM_REPORTING just in case there really is an in-kernel user that
> definitely does not want the same attributes exported.

I'd rather simplify HMAT enabling than make it more complicated, so
splitting it would be worse than what you have already IMO.

> > Now, if you prompt for HMEM_REPORTING and make it depend on ACPI_NUMA,
> > then ACPI_HMAT can be selected by that (regardless of the
> > CACHE_MITIGATIONS value).
> >
> > And if someone wants to use HMEM_REPORTING without ACPI_NUMA, it can
> > be made depend on whatever new option is there for that non-ACPI
> > mechanism.
> >
> > There might be a problem if someone wanted to enable the alternative
> > way of HMEM_REPORTING if ACPI_NUMA was set (in which case HMAT would
> > have to be ignored even if it was present), but in that case there
> > would need to be an explicit way to choose between HMAT and non-HMAT
> > anyway.
> >
> > In any case, I prefer providers to be selected by consumers and not
> > the other way around, in case there are multiple consumers for one
> > provider.
>
> Well, the HMEM_REPORTING fundamentally has no dependency on any of these
> things and I've put some effort into making this part provider agnostic.

Which I agree with.

> I will change it if this concern is gating acceptance, but I don't
> think it's as intuitive for generic interfaces to be the selector for
> implementation specific providers.

That is sort of a chicken-and-egg issue about what is more fundamental
that could be discussed forever. :-)

My original point was that if you regard ACPI_HMAT as the more
fundamental thing, then you should prompt for it and select
HMEM_REPORTING automatically from there.  Or the other way around if
you regard HMEM_REPORTING as more fundamental.  Prompting for both of
them may lead to issues.

As long as that is taken into account, I'm basically fine with any of
the two choices.

