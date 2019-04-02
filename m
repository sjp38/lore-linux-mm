Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB770C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:56:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B1AA20883
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:56:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hK6ppKR5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B1AA20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064416B0270; Tue,  2 Apr 2019 10:56:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013756B0277; Tue,  2 Apr 2019 10:56:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF7A76B0278; Tue,  2 Apr 2019 10:56:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A57886B0270
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 10:56:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c64so7020988pfb.6
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:56:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5UOXVWvFl5UAzraCZj+ske/KJHH3yQrrfZpYHDKJQmQ=;
        b=sUVzsjwIzKoMSTHudZNEpb5Bi7JhfckMwaFEIO0MUFms6VSoL7E4Q43PtjGHEA4gg6
         kGKB0CCBXadpXVtOZR9jZHfpyIAktbK81/JEGOYbZhtlKwMCu0lAJZkcYhAGTnZ69CZs
         wkNiRn0XXdcg5XUBk38v5mYXXVk1ILBUjWow0Fjqyp5b5zvZ88809bsYqYkWPYjoFQd+
         jzIcDjogFbydgGL9yCGtjOo+xauT7nN3XqSvhlHep7SF3oKh1KYkuFGUZNrkZA7M9weT
         jJFVLKfERb8OOH9yZo/vYDTZ6gB9Zjj7WFQrExftpiib+ThhPbV9UDSaWm4nkfjKbOpJ
         O0ug==
X-Gm-Message-State: APjAAAWP6Jtr/dB5ihToknc+M4Qq5WQ063vWIJcn1BAIbuzP1J837UyT
	ulXoe7N2/UjvxGPR/zbf118v6P5+3kLsmg2oq0EFjp2PnG1JEa3aJT7/4tCISJXGr1IXe35hG+U
	sjhbftoT1tSvweG067PbPVQox3ac4rotKEdU1+FdM7FmUdlQFh67y2crGXe7ek+/hBQ==
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr16626471ply.124.1554217009261;
        Tue, 02 Apr 2019 07:56:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyaBReMy/oCdsIbGQ+Qrsl5+YS7TLfHwumiAyK1+83PxKxewNmf64tdh6tR2ZzjReu28lA
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr16626424ply.124.1554217008583;
        Tue, 02 Apr 2019 07:56:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554217008; cv=none;
        d=google.com; s=arc-20160816;
        b=pIB62GQJ72/AMtWzpaHmuK7HGjs+RTdF4MesQF5ko5GqFTtz41gfZwsqHKXZ5VvzAr
         sHEokEoa++GDFSwkkNUqPEWcAiFXmHnBjHK/4ifAukbs+WYk/v++ZMMeNZzkCCk/DT1X
         +P+PKMWU69Sf0jK21DhBp7rrINvwL8ujzHIKKQpsPh8yZ+fnxobbuk+1SDf7yTlDknp5
         KyYhbdgVaSG08nGjBeSQS7dlPeorVL5ap0j+SsnAp7zogUXRRWYfJYp8SiDtOzvJZZ+v
         g8d7OYa8FtBY1yyWdhwovuH6Mk1XcnalIgpPpEzOEBrdUxcPTjD3UQViNHfSZF8LhytF
         zxyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5UOXVWvFl5UAzraCZj+ske/KJHH3yQrrfZpYHDKJQmQ=;
        b=pVgaSrExDqLB53KQzkOSGOu9l2HHFriU7sbLTqC27oVQJjVPokJKfhzrifbpCRIJvs
         201dwuWajaLrlnZdkm6KfcJmu0WdvZ03oyy8rvnWogFO4CHXOmytttADa+tQ/Yme/T+F
         U4+YJwd9CBf4sydfgLqQRZqr+bpK2iGgrF2TxISqli92mq5ofJvS6+ghjxOIoArpiwOr
         9tq1T8SRd4GNpIEN+6eXToJpLubcAulTXoWFPh8USwWN8HXJoYgR8ijgVNftNAC0NcR9
         HI7o9JIWZI7MwtCz7DdEyd+I9Uan8kBvVixmGJiDTAwjHb/ejNkKLbE3bRqzTOvBIeNZ
         Mt9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hK6ppKR5;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u22si3825134plq.193.2019.04.02.07.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 07:56:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hK6ppKR5;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C08A320857;
	Tue,  2 Apr 2019 14:56:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554217008;
	bh=hclZDBgxp9QJ7c8nzh9OJopvW3c47Cyce5/5oPk9NGo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=hK6ppKR5KX3Usy0NaR0c6bIEUr63tJXZzCkxAYs3mbW4b0jPaYAunIZCmBoq/KjZP
	 OPa+XHDhvXa4uvXwQBg9PcMApE5YW1SlUku3SRX2HVz1fTprPcVdsaV/BLeWzJ/xT3
	 RuLteiGUc76suQJLF1t1uBvVyvdBWiJFm5zrTyik=
Date: Tue, 2 Apr 2019 16:56:28 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Keith Busch <kbusch@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCHv8 00/10] Heterogenous memory node attributes
Message-ID: <20190402145628.GA16110@kroah.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
 <20190315175049.GA18389@localhost.localdomain>
 <20190316030407.GA1607@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190316030407.GA1607@kroah.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 08:04:07PM -0700, Greg Kroah-Hartman wrote:
> On Fri, Mar 15, 2019 at 11:50:57AM -0600, Keith Busch wrote:
> > Hi Greg,
> > 
> > Just wanted to check with you on how we may proceed with this series.
> > The main feature is exporting new sysfs attributes through driver core,
> > so I think it makes most sense to go through you unless you'd prefer
> > this go through a different route.
> > 
> > The proposed interface has been pretty stable for a while now, and we've
> > received reviews, acks and tests on all patches. Please let me know if
> > there is anything else you'd like to see from this series, or if you
> > just need more time to get around to this.
> 
> I can't do anything with patches until after -rc1 is out, sorry.  Once
> that happens I'll work to dig through my pending queue and will review
> these then.

Sorry for the delay, all now queued up, thanks!

greg k-h

