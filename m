Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66DFEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 233422175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P5Xhif6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 233422175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA9966B0003; Wed, 20 Mar 2019 07:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B59766B0006; Wed, 20 Mar 2019 07:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FACF6B0007; Wed, 20 Mar 2019 07:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEBB6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:20:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so2243486pfn.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:20:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=X0UZ2Ky/zStGHPaiYjOhz7nuC7+B3z5ZswtS2vYbX0k=;
        b=j4dXZaXQmg7oEd27OisKWtQg7gBkmweZrVNh0Nv4GODzdsJWzA2mq0zyiJ71bRRRhJ
         4QgXVxdy8fnDFpBoRiNzewSnXmWzcntmMh2BXLhkOM17S59bOoNzlYN5d/960Sde9rvw
         7EIC3tz0QUpjwDAjFTlMEnHJIk7G6sgBVqckfj2pnzkDDCKMIf8Rfi+u1yxDahLe+PZQ
         2g8e3dEyEjuqtEqoWvy8kOzULOPsIaD2hZm7qr59WFalNxrIQxfxGw033x0yBGpV7sKq
         22BQFIBdCnwkmL8yAKBwieVP5E4Sg6nA6kH7zR3RxRHdlO8sj1/R0z16+aknUdJNJOkA
         P1Yg==
X-Gm-Message-State: APjAAAVgGxVo3dIkXQLUSHflk7fklextMSZcip0xkyaxNDg5PAX3WqT3
	N3GROMqLxj+K/6edryw+64e8AOlxriPARj6B3JujqTJrl/BJttEdXsFdLZSVS5xjStfOAgI4Vs1
	qGyqtathMho2N8T89auPLpW2UlNi0PYbbJp2UeUllcKeekKhddLUC/OzyGjnvJ4fjqQ==
X-Received: by 2002:a65:5303:: with SMTP id m3mr6787510pgq.292.1553080854938;
        Wed, 20 Mar 2019 04:20:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYKwgJhjhLHRGJ4Y0u227HjEHc1ynUa2t6ltDUlYR4SgkIcKWEkpJXUVbuE0BjFTznjYzV
X-Received: by 2002:a65:5303:: with SMTP id m3mr6787463pgq.292.1553080854248;
        Wed, 20 Mar 2019 04:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553080854; cv=none;
        d=google.com; s=arc-20160816;
        b=LFgde0zThaioB34W8fSYCFOIcXcocJrpWwJ8cr7knz/K+1j14MSQMAxegsn9myESA6
         Yt49zXiHmfv8aesAHcVA+jEg8ys1V+FWIDylxqHfqYLxh0EJw1K/ALqtnbSdz0x6Vw3w
         90fbT9/1U1fOldgMj6x1cBLDHnV584JO7ecGml7w26bCTy/nxOecJ1xESSk1+bGgzeKg
         xPZRdzITnts3PQu/IJbg/0AGmYX1AK4paTUTkVYRCk3TLrDWWFZ7XpAopH4xHMyYUF6D
         1nJ67+UboV61xoVJdsV+rzmNB8IALh3iDlg6zHnFRhAkyNnLiomWprBRq6e2MYvBswAW
         I3jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=X0UZ2Ky/zStGHPaiYjOhz7nuC7+B3z5ZswtS2vYbX0k=;
        b=y7NVfOtjfPLpwOptnIsO7LHewHRI30ugOPpAQlhmt2j8MCDPH5iEiGYiHBlBpR33Kp
         CZPZXwp9ZviYC61aL+L/bYXLFFtYab3QSSz/YvvjsckJi3g6VVvWSQb1XBIrI5r5CaIr
         Nykd8xdwhvBPI3pwUk1rU9I6IPahhC9Cx4CnMpcEsdI+9w9tAtmP7OtrtA0PWl+1IYLc
         tcUo49/vFAi9nQqptb3G0YN5d2rrfPFoZGSRB8iuEo+XTYmMM/hzQT4+A1ft7PNwIzjz
         6CieN9xG6v23zCn5RdcyhUmI5zFUvzCMXnxtpND0G3pV99aJcKS+1BT8hgdwsYjoe7Wj
         osJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P5Xhif6s;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j19si1467469pgg.276.2019.03.20.04.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 04:20:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P5Xhif6s;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=X0UZ2Ky/zStGHPaiYjOhz7nuC7+B3z5ZswtS2vYbX0k=; b=P5Xhif6soKuu27UyLw0TJwt/C
	g7xrtrWG+7HryAGydpaDjOzzLE9hFy3fvrjNfU6qMKF/chFBOkOCGxxmntD1+x0rR+bV4YU33Lh4Z
	SK4dVmHgpGdCjSvZrwf1xQ1ib9/Du59c0XiSCwlT/FRVBuPZYYkHS8dbNVCpPzrtnYzsoJQJKnIgf
	OB6sdGR8ndX/HMvYrV6Qtp9sRvO1cc++XFEwXrDujZN248gpAulDa0RZsHpRTWocZlWQsEGmCS0IY
	ReAOcRWeLdr0STaS8VT7lut7bUqEbKmpgPDfEPdX8qfcGO1SiABMYc/usMdt30poz+7CBpRiWBBHu
	oFlP3BEqQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6ZGJ-0005lm-Qz; Wed, 20 Mar 2019 11:19:59 +0000
Date: Wed, 20 Mar 2019 04:19:59 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190320111959.GV19508@bombadil.infradead.org>
References: <20190320073540.12866-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320073540.12866-1-bhe@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:35:38PM +0800, Baoquan He wrote:
>  /*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> + * sparse_add_one_section - add a memory section
> + * @nid:	The node to add section on
> + * @start_pfn:	start pfn of the memory range
> + * @altmap:	device page map
> + *
> + * Return 0 on success and an appropriate error code otherwise.
>   */

I think it's worth documenting what those error codes are.  Seems to be
just -ENOMEM and -EEXIST, but it'd be nice for users to know what they
can expect under which circumstances.

Also, -EEXIST is a bad errno to return here:

$ errno EEXIST
EEXIST 17 File exists

What file?  I think we should be using -EBUSY instead in case this errno
makes it back to userspace:

$ errno EBUSY
EBUSY 16 Device or resource busy

