Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB61BC43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:01:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AAF720652
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:01:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1vkjqwWq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AAF720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 307E98E000A; Thu, 17 Jan 2019 12:01:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B7B38E0002; Thu, 17 Jan 2019 12:01:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A7028E000A; Thu, 17 Jan 2019 12:01:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E49978E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:01:39 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r131so3577420oia.7
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:01:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=74xntSFv45P5uxE02fT3KOtvmrgwIhR0LyAitbgHaOQ=;
        b=G+Pphg3CFvsX8B0q4w3bZw5xM4MXJFSMXWYj5SIMTxDHFyVFzp1QYF0JTcTjLkR26o
         mI5OjVz9Rd/kqKXpofQizZvKa+KWOBWAT98kcXtU55JNCNIzlDZEFwgvyWLO0ZY0JzSt
         qGQttdkgQVIFVlV8fFpEw7kW8mssz1X9hi0W1L/AFskwW4sk9OcIjJAoVPwouHP0AbwF
         +tmJE3P8K9EG5AjSCLgBnKi4G9HObjtFDb5ZKuadzk5fpHefMGPPaFL1bDFqPL4G+SUF
         wfeR9+d8+xnOf7H6C0X52MoIBtvIqMb9BrDyejmZ04f9TWMQyuoAkya41zjl2FhoCWBk
         dkiA==
X-Gm-Message-State: AJcUukdYzNmH+R+l2pgI/HjuUrsWQR4hgTAE87ri2hK2btgGJWvT+XA7
	DYJak/CZitWGcfxQe87VR+MhasX0iAEV1+OZQeoQvVekR5r0654YWUJJVDgUi72FNurhuj2tXZ5
	QLv6ti/KjhEyEBDOKhoNM00exkGt2cUFC0Fbzi4VbV5Chf5YxKMPWm5RpIL6O2Z5ZmusilHr4Ze
	+BJCpGZFMhJ6QBfUX0jlgUknZxc2xSZKfL3wiU9oSG6D32600E0XSXUDQzlfQ4MMOJeMEcLfyzF
	GWIcg9worhl09z2HaUB3PI9NIfMnypr7watoQdZOXRkDBEJDzfQiCotu/wrkwLc8p+I+7doKE73
	wpa/ODMW3OTSOIN3uRLBIY6sPniQBXfZjy2CbSfIPscQj1OsgXwbXyRTNw3m1MwpBT6ha29hS8d
	U
X-Received: by 2002:a9d:728a:: with SMTP id t10mr8652357otj.216.1547744499512;
        Thu, 17 Jan 2019 09:01:39 -0800 (PST)
X-Received: by 2002:a9d:728a:: with SMTP id t10mr8652314otj.216.1547744498704;
        Thu, 17 Jan 2019 09:01:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547744498; cv=none;
        d=google.com; s=arc-20160816;
        b=JJvyDdqMah2L3FqoSaURh1t6XqYnWeIKdNAWu4/YHnh+axvnFuTqfava2vMxeBr6Ut
         xbRDo6PkB33vtpjbYi72mvw8nMn2aicxsCbDR3jEHNqaoDiY3VAflUozJOghpRy1kA70
         ZyEvEPjVobgrB/2rUH6awsr/v5KyfLWWIDlawEOQU7/jkg53cF4fH45+pK4Fxia1UyM5
         PSSh79Encxe60EOdtt8O/qjCSVYGjKjgT8fuom3pVb3nVPGUH3hBRpH330L1nSkGE5Bv
         yyNwKwK3zvedk/oRA4JZGvHYoi4PQJlrOb42BynM1oOzB7y0c7/0DHbFHuVo7MYVwBv4
         /NhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=74xntSFv45P5uxE02fT3KOtvmrgwIhR0LyAitbgHaOQ=;
        b=0pVWXS0y3GBkSGGbWFPIRrGQ89XgueUK6o3xs5vO1Cr1SYlA4L85K324dcaDeogmd/
         WsRVLCApV6/OSHCx1mbeeZtdyg5w47TaGR1ar7247DIPbdTc07gRlejDmOSduXo6+AoF
         RiYOyHP6weL416n3KfIpxfl2NZsMLH6LnEF3qruStRYeua4RkRsE2pY+6iBFXRuupemH
         4xKBa8hx2Qx5hhwQ5nKcBmfBdT/ktOYuAPXqchHLH4rUjV6WZAmIqAgjL7K5DaZ+Mbhb
         3ZW0eNFVCZ1dTb1Cjia8uDkbKc6p2Z261jzCzM8bAQJoSULAtFfKxbFMnCYj72owGUMr
         e2gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1vkjqwWq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c93sor1036165otb.123.2019.01.17.09.01.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 09:01:38 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1vkjqwWq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=74xntSFv45P5uxE02fT3KOtvmrgwIhR0LyAitbgHaOQ=;
        b=1vkjqwWqoRVTksMinxWeVGVBSsjSLUgN1Q/hGR3KFSqsaaMBIO9Z9oHjuIHGdo1FNx
         V60G+ZQhQoPkLRfXTFn3+J/3a0P7VLmfyebr8mgORCZ/eEkw1/DF0ed0nTbmctifvEr3
         1LceNfAOvOHO+/v/O/EgwPEjsRzT2+aNjoU1oc3/iUhROT/dyeOQOFtYNsTEaM1M0qpX
         EaHpp3e/Xntx1Rokn2yVQflFS9B4yLCKZNcGefD4ciGd13UCiJG82d2x2FVpNhuL811n
         Ylzl87Uiw9tybaxfqKttKiCdIaFgIrQPY8qIWjoETCA3g7FroNmoCybWFriYfds/qjWL
         SxmA==
X-Google-Smtp-Source: ALg8bN6xqWDc5Sq/06QYqdFQqN+1zYDMZD1kHAWmw2YWq2byOr9l4p48xyBuSkHzQ6yOO3aXhbzVNeGWi58roAGpDGw=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr8756724otn.95.1547744498320;
 Thu, 17 Jan 2019 09:01:38 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-7-keith.busch@intel.com>
 <CAJZ5v0jg24sNVQiA1AvVwP-uCCq1Uo9rxkAERyb_zDL_W8AATA@mail.gmail.com>
In-Reply-To: <CAJZ5v0jg24sNVQiA1AvVwP-uCCq1Uo9rxkAERyb_zDL_W8AATA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 09:01:27 -0800
Message-ID:
 <CAPcyv4i9Doi_cE8KkB-PjzPyU2GoscvJbKTJzaX1esVQQ=dxMA@mail.gmail.com>
Subject: Re: [PATCHv4 06/13] acpi/hmat: Register processor domain to its memory
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
Message-ID: <20190117170127.laTZNeZaE0nans0JNzjE1Uk53JVepJa6VtBcm_H7u94@z>

On Thu, Jan 17, 2019 at 4:11 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
>     On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > If the HMAT Subsystem Address Range provides a valid processor proximity
> > domain for a memory domain, or a processor domain with the highest
> > performing access exists, register the memory target with that initiator
> > so this relationship will be visible under the node's sysfs directory.
> >
> > Since HMAT requires valid address ranges have an equivalent SRAT entry,
> > verify each memory target satisfies this requirement.
>
> What exactly will happen after this patch?
>
> There will be some new directories under
> /sys/devices/system/node/nodeX/ if all goes well.  Anything else?

When / if the memory randomization series [1] makes its way upstream
there will be a follow-on patch to enable that randomization based on
the presence of a memory-side cache published in the HMAT.

[1]: https://lwn.net/Articles/767614/

