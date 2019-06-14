Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFA62C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76C522177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:30:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YQSkaSpA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76C522177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DAC76B000A; Fri, 14 Jun 2019 11:30:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08CF46B000D; Fri, 14 Jun 2019 11:30:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE37D6B000E; Fri, 14 Jun 2019 11:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B708A6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:30:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so2000056pfa.23
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:30:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kl3kvlzwneXJSMiwL0sU4khQ8YV48d3RO1QJiq3DuDk=;
        b=YcLl+u1n89DcC7u9XyE5uimRXKoWof0QX8EPsC3x41GWh+CyNmYqmUqEwf8NYvdtzf
         8bjB8V1jnugqwGUgiXjVh1Y17xz2+QD4Bns1P62VSdtnmr0RCToiBigYR3G1WZY1TMZM
         iGQCRjD9l6zJr3EwH/WV+aTKhWYqDRMbvzWtmtUTettOlqp96p65PY32YLD40ZB/h5P4
         iACUARnFgZeJrGpNZl7mSof1QX9jH17BB3K8oL6T1dHhwXmbR8u75qItQ4ElWiDAoQlB
         bJbB3Q/B799cZF4yM4IGIDs4vm1tEPVgMy01uEjj2XaWAcR/uge3NKY3H/agTCROv/qx
         7eJg==
X-Gm-Message-State: APjAAAWk3Zc1VHVfDl56baHfM7pzNXXhGv3xc+dgqdkdW9lHfG+IcKyh
	E/jPUQZVbnHiaI028LdUERLqHupwuO0TxSqkXGuwx8Fsa4baJkU2jgFQyz/PEChWUhdq4S+xVDv
	dJJdg6uFNIV5DUKEbYpbWIufjOhnLWREHZzLZeM9IC+g0jc0tKkFjx0QA5QnSBWwbfA==
X-Received: by 2002:a17:902:7083:: with SMTP id z3mr29313326plk.205.1560526235333;
        Fri, 14 Jun 2019 08:30:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnd8Y2TnAciJ1TTJOckWbWmnsJLwHJLGd6nhYTOVoo+O4pS8s8hhGyH78rncraPiw7Hg+I
X-Received: by 2002:a17:902:7083:: with SMTP id z3mr29313271plk.205.1560526234686;
        Fri, 14 Jun 2019 08:30:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560526234; cv=none;
        d=google.com; s=arc-20160816;
        b=g+wgduck9EnHjM+fOZV0t5eP6Za+XuDR2UeyWSlhawOjG81kiVWszjAd9NrsEqkG3Z
         ehaIGLyKU0O/bT5b4PSts9Gjs+jkn4M0UmOoMCP+Sp8GwkgQF/llYzA//BhzR2An93Nr
         G0Lpw24+pJwEctq6kXIKFhgaSd8YGMe3RndUTSgYJGb12zec/IzqMC0KINSrknWMAaXd
         dgXCn4Nva5WzVLfOdeL9rP5alRON7pTZXZCC30CExG4FQd+6hLDJMHveXwqz3KW5LB3U
         EQN0KU29fJS321157vwrEt5IKueC6u66TXgKAOxJx6EDITncTfAufU+425G0RCpNTMv3
         dFuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kl3kvlzwneXJSMiwL0sU4khQ8YV48d3RO1QJiq3DuDk=;
        b=O0KNazsg74381pocie0jdli5SzAqIFIAg5I+GnDcohaGBfPiIK/XStmmC9By08XBPc
         GfTkiJLYJDxvATZ7uz41QvpY8SG5z5DREPNAqUktWo+oocu/lWy5a4n/8KC3b/971y3f
         Hph+SVGiVlbvHArhVhVGJm60zs1MATJhqMS+KgdyskzYYmjktRAkADgD9PxirOX9YPPi
         Ez9z3C7PXyG8FSQULuGMEWNTvOM1+n5XSLjGDsIFuxuxfIk+dLqpxIdFsQyrYdnR8R5Y
         3T8pQadPMwQ/S4vrjXVsdyPJziUFEfhYfmtPldDCoVrHkWZU+HUKBHxUdpdQubUX3LSZ
         xlKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YQSkaSpA;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b5si2670238ple.81.2019.06.14.08.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:30:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YQSkaSpA;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CD9E42175B;
	Fri, 14 Jun 2019 15:30:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560526234;
	bh=yHr9pq/10KysBErHEUNYe66X5QjENZmZbRJgZ95Q5/o=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YQSkaSpALbREELFlyjYwtyXX2zZ40opkg5+4KefS4XBIuG2ytKNe/HlyefrPeKCy0
	 E/FugLo4jefFccnnPx66ACowyYQe8Bea79xHMfRvngOsTctElVKuYIxt72NvyX9Rye
	 Xmh7GqKPGUeRorB/KJsSF7isbiZer4sAIhDPDf20=
Date: Fri, 14 Jun 2019 17:30:32 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: [PATCH 12/16] staging/comedi: mark as broken
Message-ID: <20190614153032.GD18049@kroah.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-13-hch@lst.de>
 <20190614140239.GA7234@kroah.com>
 <20190614144857.GA9088@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614144857.GA9088@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 04:48:57PM +0200, Christoph Hellwig wrote:
> On Fri, Jun 14, 2019 at 04:02:39PM +0200, Greg KH wrote:
> > Perhaps a hint as to how we can fix this up?  This is the first time
> > I've heard of the comedi code not handling dma properly.
> 
> It can be fixed by:
> 
>  a) never calling virt_to_page (or vmalloc_to_page for that matter)
>     on dma allocation
>  b) never remapping dma allocation with conflicting cache modes
>     (no remapping should be doable after a) anyway).

Ok, fair enough, have any pointers of drivers/core code that does this
correctly?  I can put it on my todo list, but might take a week or so...

Ian, want to look into doing this sooner?

thanks,

greg k-h

