Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BD45C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2700E20861
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:58:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OE+Xgpgt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2700E20861
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFE906B0005; Mon, 17 Jun 2019 21:58:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAFE08E0003; Mon, 17 Jun 2019 21:58:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A772E8E0001; Mon, 17 Jun 2019 21:58:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8326B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:58:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g9so8877919pgd.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:58:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VTUp3lJXWg+ihQkx1C1dvmpL8lCmz0McBGzG7Q2Bhhc=;
        b=nkPjSNYviub3gVE54Fd90QgZjVZN4L5xtmof+NszqWJ/Zu/eB9IU/3ChCi9xdSozQY
         jc8SS5iYksUeZL5pntmyJQAL8yHyzRaXiWfJmuWhbT+lj0bNnsdfTMcj2BvalZv82d4T
         64CbH5EhTvhduH2nTP+K4DVkNWUresB68O9VlwFdNEDe05/Gc3J2W0lPJYya+Zx2HQ0b
         lAI2eFnffsEn9QsYnPrC8EKGN8VVNb6vN7hw9E+4vg/+a4Y3WG0uTUjjwnKfw4PSsj1i
         Z4ibwoQJFDUttXrQ3jbG/m+ntcwme8DVFjc6UV9Y9iNwNOZupQ2aLXcsbB5z4U2P0Zz8
         FSkw==
X-Gm-Message-State: APjAAAWToiTixLFJOfjZYOac5MKwKiIE4hFOiUB+31NAonxWBzStvDIQ
	hr6NEtLYPMADglZ7L+m465qba+4ZsB6xYrNIY0djuu8zvXN26FAJKAefHX0uOgCuAftxrOrpSIY
	r0EjtQe5G3dsESBOOL+qCB52DvyMDkMqUZ7zwpyZeLqU4VClPcW/NYNF4SOhekQyDcw==
X-Received: by 2002:a62:1c5:: with SMTP id 188mr1510493pfb.26.1560823080125;
        Mon, 17 Jun 2019 18:58:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTSdcQkgiwj7YX7SdHRwOa3BdhsFcMCesI/ZEdiVfznhM1rEJ8+vNkTG9GnOasT4itXNFD
X-Received: by 2002:a62:1c5:: with SMTP id 188mr1510457pfb.26.1560823079462;
        Mon, 17 Jun 2019 18:57:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560823079; cv=none;
        d=google.com; s=arc-20160816;
        b=f+bNwqOo34gaeRUpvMT1SIPkDoJZ8smZJwN3wDAV10Bt/Jta2E8sRcKmnQKWiPIsjN
         lIgYVBLFKZv28L0o4FitHl19J86ulyJ+EgfqWRRxC+1Cp7gZhiMrC0mpRX4xC/CZlawo
         ClZ63poe1GCuuhIaC2OrfIqAlJC5GCARqJC/TJkvIFcwwNhP2on1t/juhg4qrTRBlhV/
         arRRsRY7/qx12oA2glM2HE3jpMkm0DZ9X+/9lfWyWlsMq82Gx3qK56lVO6YEZiDgik/v
         8LbaqgMr9NMtWtXdMb93C86osH7rXrNwsL8DDFMzeSO4h13fBK/oU5diUR5AD9Gd1J9M
         lgIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VTUp3lJXWg+ihQkx1C1dvmpL8lCmz0McBGzG7Q2Bhhc=;
        b=EIC6LRaat6ywDWDtnbpmV0QciJnb2QwQzes2VDbjfqs2u6BcXhrsbjygwun7wqzNk1
         xlmRtPAdU/fr7xQ6B+jClsCgk0XXg51XwnyUawDwOglxAHPwcJC4ob3zIGeStTMhCVe1
         sH7516pRyIdfCF1rK64wT8Ro0SmbKmCPq67ceuFFJFMpgcNJ0kegCa2rRfOGW2RPrZf2
         BOWVPHOaEvZdmIrr4i+hDCVmALQkkb9wdMTYm2opIt67+HSPvRriJ9tn0aVu/IJFlfdH
         Jp5ywdlL7qydLr2OOr9Crcy19JKTgHJPDLs/L2jRPCb4/gXVU+1f2gkAcRx2PDqTOo5t
         YsNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OE+Xgpgt;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a22si11950468pgw.60.2019.06.17.18.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:57:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OE+Xgpgt;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 52D602080C;
	Tue, 18 Jun 2019 01:57:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560823079;
	bh=8eJzG0QkG+7iwVlI/t7yW6Fig5RNCmwWmykPQq2nGgA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=OE+XgpgtZhH0f75UQlTQL3rSRdRRP05S+vKJvMay+8BmyMAjkXZLwJC6z89WkLyWv
	 6xTZtwGGzs/c3VHzQzw94somd65KvS6zN7TbnwRgUQ+WTFBiYdGcHlHPlJeDB/vFEn
	 R7E5dmgyl20XVW7R8vwXalARxFtvIQNepfCrhC/4=
Date: Mon, 17 Jun 2019 18:57:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: David Hildenbrand <david@redhat.com>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, Mel Gorman
 <mgorman@techsingularity.net>, Baoquan He <bhe@redhat.com>,
 linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, Wei
 Yang <richard.weiyang@gmail.com>, linux-acpi@vger.kernel.org, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Arun KS <arunks@codeaurora.org>, Johannes Weiner
 <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Dan
 Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org,
 Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
Message-Id: <20190617185757.b57402b465caff0cf6f85320@linux-foundation.org>
In-Reply-To: <701e8feb-cbf8-04c1-758c-046da9394ac1@c-s.fr>
References: <20190614100114.311-1-david@redhat.com>
	<20190614100114.311-2-david@redhat.com>
	<20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
	<701e8feb-cbf8-04c1-758c-046da9394ac1@c-s.fr>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 15 Jun 2019 10:06:54 +0200 Christophe Leroy <christophe.leroy@c-s.f=
r> wrote:

>=20
>=20
> Le 14/06/2019 =E0 21:00, Andrew Morton a =E9crit=A0:
> > On Fri, 14 Jun 2019 12:01:09 +0200 David Hildenbrand <david@redhat.com>=
 wrote:
> >=20
> >> We are using a mixture of "int" and "unsigned long". Let's make this
> >> consistent by using "unsigned long" everywhere. We'll do the same with
> >> memory block ids next.
> >>
> >> ...
> >>
> >> -	int i, ret, section_count =3D 0;
> >> +	unsigned long i;
> >>
> >> ...
> >>
> >> -	unsigned int i;
> >> +	unsigned long i;
> >=20
> > Maybe I did too much fortran back in the day, but I think the
> > expectation is that a variable called "i" has type "int".
> >=20
> > This?
> >=20
> >=20
> >=20
> > s/unsigned long i/unsigned long section_nr/
>=20
>  From my point of view you degrade readability by doing that.
>=20
> section_nr_to_pfn(mem->start_section_nr + section_nr);
>=20
> Three times the word 'section_nr' in one line, is that worth it ? Gives=20
> me headache.
>=20
> Codying style says the following, which makes full sense in my opinion:
>=20
> LOCAL variable names should be short, and to the point.  If you have
> some random integer loop counter, it should probably be called ``i``.
> Calling it ``loop_counter`` is non-productive, if there is no chance of it
> being mis-understood.

Well.  It did say "integer".  Calling an unsigned long `i' is flat out
misleading.

> What about just naming it 'nr' if we want to use something else than 'i' ?

Sure, that works.


