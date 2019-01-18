Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD54CC1B0F7
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 21:08:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7217C20652
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 21:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YQDjo9KW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7217C20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08A988E002B; Fri, 18 Jan 2019 16:08:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 038378E0002; Fri, 18 Jan 2019 16:08:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E43268E002B; Fri, 18 Jan 2019 16:08:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B49828E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 16:08:15 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o13so6787945otl.20
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 13:08:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=slVKCgtfR6RXPvhhk4waF03IbIKuP2Ae0m2u6xRYQ7w=;
        b=mHYa9ICA5P8rNQXml6tOy1DfkIkdGna+MFDKdY6Qwp4RAdsIY+6a98YjDrF06aDJLB
         V0o1BtT5mFWiVoyzTfQVD8oqCeQ9CkxvcPsOolJkfTGiYmtlre/VzZeJBsbiMu0fJZgT
         VAGcoDtT8lCowb0y9U4/eyuqNwvLYpDzEvciGeh4qbjj5/FFq3yvrq7P7RUpD+fTdAgL
         wlheOzfsdDnRI5y3Wf1XsSi8zxVOTemqLb6uksO/GSBimnEw+czmOftOLDJ75NQ3cjVK
         cOaHMtbLH6890d1yd/alwMoYOIlzDJRXsqM3p+QjECw+jRrrx57LCPL/HM+9+iGUjDDq
         jeyQ==
X-Gm-Message-State: AJcUukfzQ5IpO6evGJDlQy6AxdMjL63IHYBQxBhr6zazHqeEfAEdGTP4
	WLtqQIxhpoN7HaPXTomlXTDbipsIyM1Xx2352q/aIs97j7eTk6oKLiy8h0V7gM9nyyr8yFBOO2f
	Zil+IvIz56B1OMZ9Xy7gm6Tw9yMjFBvAoI2fjdfwP7jzMn5HpFDSjGrfUdw7Td0y66zfw6uvtbG
	p5Io4wye26vVfeywXBriyEFZ4Aw7b0zgKLX2Jn9/VCBJYKwePD8xuw/okUnaXu8cGHPbAxqPUbS
	nc8QezZbafShUQnF431l0kz4kIhnFTiEuEQKhLbanZaNGIwRI3+i0+Uqw0aE/v8AJqHbHHj83DN
	kNbPyyjGb7aOBTzZlsXTT14VLc9F7CDnkVwxebTuT4eS/lgcEZo93BKcUahlw9eLUOJZGsHpW0e
	X
X-Received: by 2002:a9d:1d65:: with SMTP id m92mr2984616otm.65.1547845695382;
        Fri, 18 Jan 2019 13:08:15 -0800 (PST)
X-Received: by 2002:a9d:1d65:: with SMTP id m92mr2984588otm.65.1547845694575;
        Fri, 18 Jan 2019 13:08:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547845694; cv=none;
        d=google.com; s=arc-20160816;
        b=U1ql5SYcMEusntxjnfPrByhs7xFOkegxcU7hIypixwZC94GxHM7qJp7zYquekZgbAn
         RoYfqsb7nhoLkU0JcZsHG4+rJ5DCDVmTVYRN7CH/nodKLIaIVPfeMJ/HFv26tErj+6oZ
         g92Wrqk+SI4jqJeQUImECzS0fh2bE8eLR6gRO4d5JOc7bNowwPN/aNnlum6VLlh8+bwN
         oFcmwxjvR4P5rsO78ECSTAD7Xee+rVGQ8GZpDToelD92aIIm+XApgSaVbTdKdPEs0tGW
         x6WT87tHoF3Tkm3hbuszi3ql+UsGhiAWNt92vtOHH68FdHRGEwJb0f8FhOeVPbUE4iod
         KLpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=slVKCgtfR6RXPvhhk4waF03IbIKuP2Ae0m2u6xRYQ7w=;
        b=HpaVwmEIqExlLHMbyu5Kl/5hCPGB7volNBzsd+x9NdwhTMQ9kCzHeDS7bYLUrGy32V
         P+iAxqB2/ll0POKHtRm/JzHLLmGm3M/++Cbx1oqDyrrAgrPgAX0SyttN7N+/QCFgMnZj
         eVXDmEa5t82EGOo9O3cVgq59jPUn/M3vNACqGycHyQeOodn5ocShGbaJHEzh0xW3r3Ku
         sjMciJb0nkBOvtV/jAX4hAIxnUk04GvN905VTJEwz1WqpWBl+uwzvkSiMPmvteh5G03m
         4EPRlyFmhkxc0SBYBZAKkSG5dtj3yO6Yi/PmQPNgzEmaj8/CuPngJBvFBhb0X+4P2h2p
         Ohag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YQDjo9KW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m81sor3289783oib.32.2019.01.18.13.08.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 13:08:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YQDjo9KW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=slVKCgtfR6RXPvhhk4waF03IbIKuP2Ae0m2u6xRYQ7w=;
        b=YQDjo9KWkk9z4g6Oxs/kvLIxE4b9hU/QhD3hO98AoaCw/9L2NPQ/LeE//ADqq3ABZB
         38JM5pUoZvEhTQzlPeX5GC4FRrH35MgogRZorwGSIEB6aMMpPQZBLpoubP6WhoZzkiV0
         LitaPt0J/xIZorQei9qN8QduTqB9Y9rquQhNbXvkhpoS+aXnqH0oNq+YNhLa+LerZYu6
         yNbnlDIJNfOSrmDr2kgG8SkNszyVzMeEyYlxVcfTZ7hjBCeUOtTN5xcOthQ089/uDGM+
         +v+H+wWlAFKZ2KvRByXCsvHyhjEDsT/AQkmm59DPE64cNr8Bk7EPeQ8ecQnQhRyw5zlq
         Np2A==
X-Google-Smtp-Source: ALg8bN7LPDKrLO5BrJepfCAq4JqcT975jSj4Uzn3q4n6m6JRvbAyxYGELFEPkHq2FWclOrJqWLbZtAet7ZT1Aj49/vU=
X-Received: by 2002:aca:d78b:: with SMTP id o133mr988461oig.232.1547845693575;
 Fri, 18 Jan 2019 13:08:13 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
In-Reply-To: <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 Jan 2019 13:08:02 -0800
Message-ID:
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118210802.8HAMl4x7zjJjhfq2TyxSo0BI2000JBM7aw2t4xOYZk8@z>

On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Add entries for memory initiator and target node class attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
>
> I would recommend combining this with the previous patch, as the way
> it is now I need to look at two patches at the time. :-)
>
> > ---
> >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > --- a/Documentation/ABI/stable/sysfs-devices-node
> > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > @@ -90,4 +90,27 @@ Date:                December 2009
> >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> >  Description:
> >                 The node's huge page size control/query attributes.
> > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > \ No newline at end of file
> > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node's relationship to other nodes for access class "Y".
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node list of memory initiators that have class "Y" access
> > +               to this node's memory. CPUs and other memory initiators in
> > +               nodes not in the list accessing this node's memory may have
> > +               different performance.
>
> This does not follow the general "one value per file" rule of sysfs (I
> know that there are other sysfs files with more than one value in
> them, but it is better to follow this rule as long as that makes
> sense).
>
> > +
> > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > +Date:          December 2018
> > +Contact:       Keith Busch <keith.busch@intel.com>
> > +Description:
> > +               The node list of memory targets that this initiator node has
> > +               class "Y" access. Memory accesses from this node to nodes not
> > +               in this list may have differet performance.
> > --
>
> Same here.
>
> And if you follow the recommendation given in the previous message
> (add "initiators" and "targets" subdirs under "classX"), you won't
> even need the two files above.

This recommendation is in conflict with Greg's feedback about kobject
usage. If these are just "vanity" subdirs I think it's better to have
a multi-value sysfs file. This "list" style is already commonplace for
the /sys/devices/system hierarchy.

