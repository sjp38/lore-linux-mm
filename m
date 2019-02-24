Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1896DC00319
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 20:00:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD4412054F
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 20:00:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD4412054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C1218E0157; Sun, 24 Feb 2019 15:00:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 049168E0156; Sun, 24 Feb 2019 15:00:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2C668E0157; Sun, 24 Feb 2019 15:00:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC0078E0156
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 15:00:02 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id t15so4069952otk.4
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 12:00:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=yfmUSwBalOdjcvnqS+eLnkmWA+LNz1+spq3jB7NTkvA=;
        b=gorqn7TDk0EdNQvYEWcNRtGB/ZjzKznXDLNtW2+u4hOF8C6EQQaHwiTUp1a+WLiXQJ
         I5jf8jIkrETE4B6JQiBmVL3eVPGDIT5+oz+veqLyIEc6XnSBBn/x0O9htkUTwrK+JNC9
         ogcUSZncyGd0l6xJ/Xyh76w89+3YylxuSvf0kREQeM5Rp8ifdpQTlzO2aEd0qHso7xqL
         R9tJE/zqaD6MnKVhqIVgHpI3HH/XeegX0NUroycM/lB5i87zMW1o4subD5CS06PZN9lC
         rI2aSHztey2dC+JpPj0JRXjg23iUa0b3sH8svuDGJ7l+mwZyvzfge4QIljpOyk2a5LFB
         d0rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaOAUouNb9H1FUZKQLTeBhNy64N4jD3IdZeTYzMEyrcpsAUYAjE
	jeqtgSDZOHVTAlu40amSnLM3b7SvMS/S8U/1Ym+feWubzwzWjhVvItPkqqXSOKyn33wORqA5lox
	g1NG7w4S93THfdwug5waNjQhIDMdZceG6vzb+bwTXdkTqkehj4/TNm49u9tK9B8Hp6VG1rqQzaa
	m/bT6MeYXDXP8UlnDBijdvMMd11ElZA0j7+fmyHdgT45Ga2qVoEUgzT8yryVTdqkuINsbalTeMr
	23oiYNOCQvEUCbN+sMqIk0uGsnHDvIR5IXUiGau59fJgBzuVnyQ0fTEW4gawp9gxpgjJmdhlabI
	M4iuc7ZDinNM+M6hmJL3PTPIfMkDOSmUzDHHra1DlmEOBcIO7CVKm6vkWJGvbgozUMpQCaRFOg=
	=
X-Received: by 2002:aca:4fc6:: with SMTP id d189mr9055275oib.78.1551038402245;
        Sun, 24 Feb 2019 12:00:02 -0800 (PST)
X-Received: by 2002:aca:4fc6:: with SMTP id d189mr9055248oib.78.1551038401271;
        Sun, 24 Feb 2019 12:00:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551038401; cv=none;
        d=google.com; s=arc-20160816;
        b=zJfYd8l0m+J14PYltV/uuISnAdGKdngTtn8NXMxCpC/6jhmPycj2defXJmVzJMIez5
         PXtEf06wi1p2JNVTLydq8gBZK/nESiVqx1B2L9mmKuRX0PqsmNXnuMo7kQlfzk+BJdEL
         IbnIGmpW8+SfX8nD8oG4daTXWmf+nwWKntR/jGbkdxDA22xeMmaaX/8+Hj/E49Mc2a4K
         HVUP/P4+Jhz2mYmXuBIdurD86+V38WhV9h60m95LJfpPWyNjU2H8FJPJ4Abepd15lZBW
         Y3YYR9/svFG4iob+ieJNzC0Q+hlurrLH0eBnsYgtfN5yOKRI6V2ewb+qjhojNPsnHkLr
         E35g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=yfmUSwBalOdjcvnqS+eLnkmWA+LNz1+spq3jB7NTkvA=;
        b=PVPyDrG98Gu5YzifZknDeo5JoZoscFu0/ZPjZBhvj/WoqyX5FmVExvwcN+cRB3xRyL
         BErk7tyAS0VtQ9RPi0eqFsvpBUWtCqdCdRj0mlwRSCHSiy9LDnpGaXxpObm0I61QO1cl
         04YhOKb+1zV9GeT2durTfp1zi8BrWpY+fKosDySduY+4UNs5RUyhy4Z/qbHPXFmClNOR
         hk1Bf2oGoiOwS9x1V9KYMwAxTvxoA62tRU2HOroLKpQcl105kKJ3MkATM5OlFYHEANr6
         ygukwRqxWIhZCMNzt17MJVnYfSnBDAMi2LjhaFgIxZBNYDUiVYs1Chgs55P5q1PTSFBh
         Xu4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor3424558oic.64.2019.02.24.12.00.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 12:00:01 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IajckkE8zgs0EwI+0F1B+CSm/jwmndJErK8z8W0UaJ1/0fcfqbWZT7nvhPg+1vQsEYlYetS/ppMMl631GzTYqU=
X-Received: by 2002:aca:c141:: with SMTP id r62mr8543843oif.160.1551038400097;
 Sun, 24 Feb 2019 12:00:00 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com> <20190222184831.GF10237@localhost.localdomain>
In-Reply-To: <20190222184831.GF10237@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sun, 24 Feb 2019 20:59:45 +0100
Message-ID: <CAJZ5v0hfQ5HWT0kfaOxSbpJvdqotsMWVBCZ6wiL4Tnuy+O5O7Q@mail.gmail.com>
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

On Fri, Feb 22, 2019 at 7:48 PM Keith Busch <keith.busch@intel.com> wrote:
>
> On Wed, Feb 20, 2019 at 11:02:01PM +0100, Rafael J. Wysocki wrote:
> > On Thu, Feb 14, 2019 at 6:10 PM Keith Busch <keith.busch@intel.com> wrote:
> > >  config ACPI_HMAT
> > >         bool "ACPI Heterogeneous Memory Attribute Table Support"
> > >         depends on ACPI_NUMA
> > > +       select HMEM_REPORTING
> >
> > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > as a user-selectable option is a good idea.  In particular, I don't
> > really think that setting ACPI_HMAT without it makes a lot of sense.
> > Apart from this, the patch looks reasonable to me.
>
> I'm trying to implement based on the feedback, but I'm a little confused.
>
> As I have it at the moment, HMEM_REPORTING is not user-prompted, so
> another option needs to turn it on. I have ACPI_HMAT do that here.
>
> So when you say it's a bad idea to make HMEM_REPORTING user selectable,
> isn't it already not user selectable?

I thought that HMEM_REPORTING was user-prompted initially, by bad if it wasn't.

> If I do it the other way around, that's going to make HMEM_REPORTING
> complicated if a non-ACPI implementation wants to report HMEM
> properties.

But the mitigations that Dave was talking about get in the way, don't they?

Say there is another Kconfig option,CACHE_MITIGATIONS, to enable them.
Then you want ACPI_HMAT to be set when that it set and you also want
ACPI_HMAT to be set when HMEM_REPORTING and ACPI_NUMA are both set.

OTOH, you may not want HMEM_REPORTING to be set when CACHE_MITIGATIONS
is set, but that causes ACPI_HMAT to be set and which means that
ACPI_HMAT alone will not be sufficient to determine the
HMEM_REPORTING value.

Now, if you prompt for HMEM_REPORTING and make it depend on ACPI_NUMA,
then ACPI_HMAT can be selected by that (regardless of the
CACHE_MITIGATIONS value).

And if someone wants to use HMEM_REPORTING without ACPI_NUMA, it can
be made depend on whatever new option is there for that non-ACPI
mechanism.

There might be a problem if someone wanted to enable the alternative
way of HMEM_REPORTING if ACPI_NUMA was set (in which case HMAT would
have to be ignored even if it was present), but in that case there
would need to be an explicit way to choose between HMAT and non-HMAT
anyway.

In any case, I prefer providers to be selected by consumers and not
the other way around, in case there are multiple consumers for one
provider.

