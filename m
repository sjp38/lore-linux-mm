Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F97CC282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA8CE2081B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:52:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ovmq7q3y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA8CE2081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A7EF8E008C; Tue,  5 Feb 2019 09:52:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 557D38E001C; Tue,  5 Feb 2019 09:52:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46E148E008C; Tue,  5 Feb 2019 09:52:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0257E8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 09:52:32 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so2722327pfk.12
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 06:52:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4ALa6k0hESH6jdS/pdhP9yR2oZJ8c6TLMwwa6JY+fcY=;
        b=HlaiF8U4aFgU+TcIBkYTBTpIyTnsv5+X354UbgpU9Pf04OA/zrt/IKETjMeYlnpGsn
         UuhKGMmehzd8FWBHZNiQZEleE+xqFrBf21rPfpIw8EFc1s0VvBVUnW9Ihi0+QLz/lih/
         VU1J8/lf03kcXOxpHGbzf0lViJ8AU4A1F+XaLsHy8jRXs5JIy+yp32U6fZswyxT92pa8
         OUhcMpWOYCSQaDG1quiQSVu6J+axIitX/nzgf1snjW3mQrJSKjN/U+AXrOLtPcZAhnTI
         GrGBJnjDFkNV/LxbgGSf5X08ISlBQGUSbB/7g3XlOaXoZx0FwLdVSJE+8UnBQI+goHX1
         dx8g==
X-Gm-Message-State: AHQUAuY5XoOVomNLcG/q1nIJCtebiZ1r4B2CzNXIcuapIWhCcmo9Z79m
	m1VaDU0Xq3paUrNj9U3GQvKBC7vk+rIb/IkTRMqndstSEzb13REMxW31ulenvJ/CdE8HyglFIHJ
	5C7orju1x28ugYHzZyeBPh+54QWwCLEJbYTVO2j5tF5WESiK42IFLMkO+tmsAyNQ=
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr167973pgh.164.1549378352087;
        Tue, 05 Feb 2019 06:52:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYkYZpKh9EBOrsGAY8BY4mV+wtwARPpg8E6HtDqF8PxzWxu9lLANhKmKuqi//acWUWKudRu
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr167919pgh.164.1549378351091;
        Tue, 05 Feb 2019 06:52:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549378351; cv=none;
        d=google.com; s=arc-20160816;
        b=QuGXMjoseyzoqL8n4SPH3KI1C17iEPzMWqIwqOoaxmv/eW2a45y4yTCBNzp59UrPKG
         LMDaDHEvLZ3IPPOGiPwz0foP1V+RDfxQ6e5g4ZPeiJ6XtEMBWuNKeFqntHXTZFW78xJD
         seuaqpJK9RyI/W/C2lzZivuXB9goE8DGvNcnPGchBWB5Vej0/uE5j2WJfr3Fbj0yKdeN
         8xzf6d6XReSGfwfA1va5KRdsHMXtqiarcG9MUSzApphoo7fH3+OusYDxBVv4tAHubo2q
         zetruWGZVql2sytALPAUtezeET7fO8ajWu8/dcO/8BiCq4w4fYKu9lpcgsWJ3exdKV+N
         E4bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4ALa6k0hESH6jdS/pdhP9yR2oZJ8c6TLMwwa6JY+fcY=;
        b=TF9uM5qJ1hB3jpim3g/AzeBHSCjFPrCMvI5eOX8tbDh99x9zen9IBVgfU7M4y0eeR0
         MV3nHBUrv5XRl78xnv636gzDC8j+Yez0Zvf1aKMpVpjPLwsBwTqvnv1+lQutQVUWI7rl
         OMEOT0R7ezsAjxpiFjl2yPiIzKMVuJgau1iWXI51LUFXmtuu3NPDSoyHJWube8+sNXhN
         BzeEI1wx5SRjxmF3x85dfmL1x/VCnnbclU8mLmW/LTgHCYzs+2RBVh29Z5eVYrPpMJEm
         Ztn+jvafuvXKGBBcv0fxihguQoztotE4oNG/sQDjuac3IrG79itgQ3hg9s8oSVcAQi21
         ZUAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ovmq7q3y;
       spf=pass (google.com: domain of srs0=y+ii=qm=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Y+ii=QM=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 33si3340998ply.312.2019.02.05.06.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 06:52:31 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=y+ii=qm=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ovmq7q3y;
       spf=pass (google.com: domain of srs0=y+ii=qm=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Y+ii=QM=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (unknown [212.187.182.163])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 244062081B;
	Tue,  5 Feb 2019 14:52:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549378350;
	bh=YYosVEfjw34D+TtsvSvjOuSr//0DVVoCCC0u5tckTSg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ovmq7q3ygf3dUZSvld8v98BmehEcCgKjFOy0jqxgyBxS6+WMOCV/6hMgE5l/hdHxv
	 Xm+TqVPW5KvDFspngtv9FTADycQDVU5Kw5mOat15bNfnYd1E5j1jQHoMpabShuQjoC
	 33/u7zZk3rYPncQDjznRJQ0EdO4oOXMQHanHU5J4=
Date: Tue, 5 Feb 2019 15:52:27 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190205145227.GG17950@kroah.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-5-keith.busch@intel.com>
 <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 01:33:27PM +0100, Rafael J. Wysocki wrote:
> > +/**
> > + * struct node_access_nodes - Access class device to hold user visible
> > + *                           relationships to other nodes.
> > + * @dev:       Device for this memory access class
> > + * @list_node: List element in the node's access list
> > + * @access:    The access class rank
> > + */
> > +struct node_access_nodes {
> > +       struct device           dev;
> 
> I'm not sure if the entire struct device is needed here.
> 
> It looks like what you need is the kobject part of it only and you can
> use a kobject directly here:
> 
> struct kobject        kobj;
> 
> Then, you can register that under the node's kobject using
> kobject_init_and_add() and you can create attr groups under a kobject
> using sysfs_create_groups(), which is exactly what device_add_groups()
> does.
> 
> That would allow you to avoid allocating extra memory to hold the
> entire device structure and the extra empty "power" subdirectory added
> by device registration would not be there.

When you use a "raw" kobject then userspace tools do not see the devices
and attributes in libraries like udev.  So unless userspace does not
care about this at all, you should use a 'struct device' where ever
possible.  The memory "savings" usually just isn't worth it unless you
have a _lot_ of objects being created here.

Who is going to use all of this new information?

thanks,

greg k-h

