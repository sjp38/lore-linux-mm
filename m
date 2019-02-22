Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3F58C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90A5720700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:21:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zXesRFfy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90A5720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BBB08E0122; Fri, 22 Feb 2019 14:21:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26AA18E00B1; Fri, 22 Feb 2019 14:21:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182C28E0122; Fri, 22 Feb 2019 14:21:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E12178E00B1
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:21:51 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id g24so1440933otq.22
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:21:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HEh1PpN8MZdEODahk7HJYfWRejKVe1bP2E3naiVJUf8=;
        b=ikttCN9cLXb7/lZHM/cEPI1RFj+bwEooM2iISdNvwKvk8IFgoOdISxpxhthhwqsIzE
         j9YNjFopHKrJPzymPgzop9JwnExfRFqb7aXbqcDF1D0Ii/Geg2Nu2T5NosX8GiD1V2+e
         eFok8tZGrme/tf8lokoK/MuiO9OiL5yymabtGrMJs5PG9bSqVybLTw4u7jXI9ObzPcA4
         yu2w3d9D9TajqYE+51QxCufwzw4ZSBPciZj+XAUYDgohQKq74ll1bLcG+tRUi1wowVP2
         oMSths+TB5859jhSUcErExle/HhIuHD2NGRMup2fcc5/arDxQE6BoJAemsP3qLyOfRQ0
         mnNA==
X-Gm-Message-State: AHQUAuaz87xRLeW6sJtqF4kmnIC6jtEJmeGeeq8ehzJ+GngvYeDg9XLW
	pum6TzwLYA7/eWPjeBEY4UKDFPaTwr2ftX18XqvCY67vR96SYC2ZaObubZzrxRtPfzGdDs/b/15
	lzIppW9mi52ABO4ZBcruIh3EBPymlfCZ0ag9uH0vaLANNgCqkOA74GWefE/NCXu8Ljo5sndaba/
	g/UfbZxi5bBdSWZhSFjcVKqyhtditEE4x1QcbcCxjc3BKfaRtw8QcXqdInMAjoZM0IiWNB8SfCO
	GufoLA403a9X40H/TRZKJHVkO4p2ft51nuVoSaMXql8WP6RkeQxam0J+m6Rl6rL7YtVS7IyuqYA
	UN25pcXH/IkmeSPr+bktidDVdxiNUQ+wrLXOyuCjc8E+2D2zix0Vl6kfiVow6JuJNBcKLUBJpeS
	M
X-Received: by 2002:a9d:7390:: with SMTP id j16mr3537559otk.231.1550863311561;
        Fri, 22 Feb 2019 11:21:51 -0800 (PST)
X-Received: by 2002:a9d:7390:: with SMTP id j16mr3537504otk.231.1550863310646;
        Fri, 22 Feb 2019 11:21:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550863310; cv=none;
        d=google.com; s=arc-20160816;
        b=uzLfBlUSPEdVBTgemq+8I0eRR/k4fzJ1MnRysXuDD7QOeJrpFRyjq+unTMJma9r2Cg
         HiLyVLxaQwdW7VtvVMmgVdbhmMGSbKeOQPQKmV35Qi3w/Zi0v4QBoM9TuzQqGg/SbmJX
         UdVRZGlRVU/eEck4NNxIH2wqwBcdHfAlWLVa9KqY3zrAgFh7SsiL6oPYJVOBpUJ3ilq4
         BxzHXXfqIgTlk0j43fwYb8lmAuU6YFSjBJIP8b8K60Dc23YjITPcXk9FTGIc6EX6ZXEU
         fA8v+4XPtyhjovFQfPF3bMVntaVEtDTJWgrhYOTMOZ/c61Im1qzcn/0eqS5qmXNNN8VW
         vI5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HEh1PpN8MZdEODahk7HJYfWRejKVe1bP2E3naiVJUf8=;
        b=S/Pj0npOXl2ramn23c8sgVvwgdrtIu+W8iRcY0hqW8tdBuwnZx4IWhDy9pFWemAD7B
         58MV4xMk9BsDTGP/vRQVcAgXY1wMsdKUn6lDs5WG2jhzdjGLKecJ8GlTcGIx5nJOZFpU
         sEvP1Txp/ZcmC5TMSKQXtfnSyuMbVDO9GRN/O8CRl5dn/0cudxdMgnqe4udifNkkm+1V
         ZBxtHSPgMOSU+/EkFWmWylJ29BSXjsyivv6IsgBQ8eS9OTa8o1rRFAKahVu/FQzTUCnf
         vflxr2Erhb5JOvSIscNDaRZ3x8ljZ220YktRMfoky2feu99RBh3oRpudmeKgE+LyZN8b
         YnFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zXesRFfy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r130sor1097653oie.102.2019.02.22.11.21.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 11:21:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zXesRFfy;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HEh1PpN8MZdEODahk7HJYfWRejKVe1bP2E3naiVJUf8=;
        b=zXesRFfyjpqvIH8VP1xf1g80dCuBgVRRUkhCYDPpHLePIzmXKJ7sgzrOgJPsRIfRG6
         nJ/mxqOXn2qC/yBY+wf5StldKufB5l4Pt7OLHD3LdnAfMtrBYffP1jllN16rYAndqMpL
         /0bN/tGDiow85dPXI++3sBxvyiZ/sEZRUqBJb+cNowmwtTA6MWt8DB1zbChG8/2lLdr5
         MumJXC6d98+tU0xLk+xrqDwYrhIQuFYD7SChKWRCWIH82Qi/eE4ws3TL05qVCZzWa2cO
         4oETD5m1fGNc/AE1KaTFOMgDqajwXGsar3u56lNojHz21SzqbDI16F1VcopdbbwVGpEb
         Lw+A==
X-Google-Smtp-Source: AHgI3Iaw+mm3X+7iHZPF7QY6qOMX3Smk7WLYRYr2Q3MhrxIWq1RoC3N33E90+AHMtwL3PkXea/PKpphVypI1nVnlj7M=
X-Received: by 2002:aca:32c3:: with SMTP id y186mr3360644oiy.118.1550863309451;
 Fri, 22 Feb 2019 11:21:49 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com> <20190222184831.GF10237@localhost.localdomain>
In-Reply-To: <20190222184831.GF10237@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Feb 2019 11:21:37 -0800
Message-ID: <CAPcyv4jpP0CP-QxWDc_E1QwL736PLwh8ZPrnKJzVnYrAk++93g@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:48 AM Keith Busch <keith.busch@intel.com> wrote:
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
>
> If I do it the other way around, that's going to make HMEM_REPORTING
> complicated if a non-ACPI implementation wants to report HMEM
> properties.

Agree. If a platform supports these HMEM properties then they should
be reported. ACPI_HMAT is that opt-in for ACPI based platforms, and
other archs can do something similar. It's not clear that one would
ever want to opt-in to HMAT support and opt-out of reporting any of it
to userspace.

