Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA862C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D71621911
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:44:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DTMevEAy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D71621911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 359E18E001E; Wed, 24 Jul 2019 20:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3358E001C; Wed, 24 Jul 2019 20:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ABC08E001E; Wed, 24 Jul 2019 20:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7CEC8E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 20:44:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so29653769pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HOMehB1vdHub2fgtZm471U2goVIT/mnfZWSHdivROoc=;
        b=DTYKdsfO9w5Wac2COIVgrIaghwjai0ZRJYpMINJZ8EVcHcsjVqu3t6yRmcbfYl/EFS
         dP4LhW0H8ceBqmeBOYVz8cIfUtCVFn9I1CwuNgv6733udIP2t/dzCD+kT6ii0RIDa/lj
         YTncUxFGSVDQVGwbFItRNb6yTLQmFFnNDyuxkevd9epFXt5zcvPXVuaZ6IrCO1drHrVV
         mn+Ytlbc/C62ARG1InIM0GisTCB8bCV0/kQBDuLw4Bce0fm2oPetr9JEuHB3zc3S9fpW
         8VajSrM8GVDbNrqsilj76BqbCzOA+RpvHi7N7Wvxded4q+PrG4OjTCl7XKvzVzJ3cXSI
         oUZQ==
X-Gm-Message-State: APjAAAWA05I8KvI3cntyX9U8uHz3eHoqQPw+s3HiJCoY0MYm9rVm38xS
	ZblJc90Gnq0gZxff0gZUhw20sydp9WB1sliRzXn7ilw3paTXRhHb2oAbElSkD1rYOf+VuatSxQl
	bIHuHOG2Zo3xmAit68SO0edGt3qCLNbtyzDkkqBE7Y8TP7jqVvvIEV31joJmtJnc3KA==
X-Received: by 2002:a17:90a:1ac5:: with SMTP id p63mr88451663pjp.25.1564015465572;
        Wed, 24 Jul 2019 17:44:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6+85bzETf0aXwmTPNZH3heWolcMfb5/a3BZf8sE8s9BwykEU3iYCJtfhlEhhOo2tSCDUG
X-Received: by 2002:a17:90a:1ac5:: with SMTP id p63mr88451625pjp.25.1564015464835;
        Wed, 24 Jul 2019 17:44:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564015464; cv=none;
        d=google.com; s=arc-20160816;
        b=A9zYsQU51dksHMo82/EENcc8SGMHYX2HTnYdKROk4Fl4SdQthAyyYZwjINAL0DhRsH
         LTQPSVCCZDfXma0gHiiyPXbX7FfsnPN4BqulaCfbfSF1W9LTen9A8QgGAGsO+z4SNdPq
         1KJt+bOTbgbGsPepfBgIk5MG06wCPGq9aUPAhjOJGLCe8aGxDI5+tRwxPkVbY3FgBD6O
         YqvAGXezG0QOAooA+qtEjvqr3FRC7gelIrA8uW2JtKHC2qqB/f2J+QMIe7iCyYR5tjs7
         eDqgDyJOn2PlCWzENW4EevaeaGjeUGzHtG80baCoyyq4wmpTSkv6WiXAFbgcI0NpDNy/
         WFDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HOMehB1vdHub2fgtZm471U2goVIT/mnfZWSHdivROoc=;
        b=byu78d1HnrZ5nfvu8nbAhPNgS2dbS7JESbGgTc0wnKnwiHrAUnImu8HbqSx07O7+Ay
         RGUnad8LKxb9CgtOlHU0Rv/WVYDJxPdZM2HyXBKZjI+MvIf8xMP/9TF6gRoSDkPrgsc8
         JAlEzE6Wi6tC+hQZPIG2R/PnC7vSKz1DbKM1/ZxUR+d1L4iGPTQLbZkmpkMsq9kbTxMR
         EpM+PwsfR5+1Qs9OAOAW9+NGgAHpze85/YWXtFUx7RWvkg39G7VGfTgALyCT85C/2Ipp
         gVWWJa6SuxIck6CcvKdSn64b08odPMAqrR+vEG8mSRup/bAYNJaXE++Vue0Vi6bUKH/x
         MdGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DTMevEAy;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p35si15061081pgb.484.2019.07.24.17.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 17:44:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DTMevEAy;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 251A921901;
	Thu, 25 Jul 2019 00:44:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564015464;
	bh=BnJm16XIJ4U5h0/wFfNFjUiyQUQlm05rCuTqzXG01x0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=DTMevEAy6MsZBxplreEMB+bJxmKA1GsWpZtLmWP6cVbMq2QKKqVCfOMcytQ8gUcHi
	 2JRtFP16ImDGp/MasraDgzI0X9ruqK1X25hWfedDjzH+kLP0i3V4/xHmTmNp9rmAY5
	 OHff/q50Keh8KHkK1MMdNgOMrgVrKIzoTZZ1Fr0Y=
Date: Wed, 24 Jul 2019 17:44:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [v4 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
Message-Id: <20190724174423.1826c92f72ce9c815ebc72d9@linux-foundation.org>
In-Reply-To: <6aeca7cf-d9da-95cc-e6dc-a10c2978c523@suse.cz>
References: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
	<1563556862-54056-3-git-send-email-yang.shi@linux.alibaba.com>
	<6c948a96-7af1-c0d2-b3df-5fe613284d4f@suse.cz>
	<20190722180231.b7abbe8bdb046d725bdd9e6b@linux-foundation.org>
	<a9b8cae7-4bca-3c98-99f9-6b92de7e5909@linux.alibaba.com>
	<6aeca7cf-d9da-95cc-e6dc-a10c2978c523@suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2019 10:19:34 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 7/23/19 7:35 AM, Yang Shi wrote:
> > 
> > 
> > On 7/22/19 6:02 PM, Andrew Morton wrote:
> >> On Mon, 22 Jul 2019 09:25:09 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >>>> since there may be pages off LRU temporarily.  We should migrate other
> >>>> pages if MPOL_MF_MOVE* is specified.  Set has_unmovable flag if some
> >>>> paged could not be not moved, then return -EIO for mbind() eventually.
> >>>>
> >>>> With this change the above test would return -EIO as expected.
> >>>>
> >>>> Cc: Vlastimil Babka <vbabka@suse.cz>
> >>>> Cc: Michal Hocko <mhocko@suse.com>
> >>>> Cc: Mel Gorman <mgorman@techsingularity.net>
> >>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> >>> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
> >> Thanks.
> >>
> >> I'm a bit surprised that this doesn't have a cc:stable.  Did we
> >> consider that?
> > 
> > The VM_BUG just happens on 4.9, and it is enabled only by CONFIG_VM. For 
> > post-4.9 kernel, this fixes the semantics of mbind which should be not a 
> > regression IMHO.
> 
> 4.9 is a LTS kernel, so perhaps worth trying?
> 

OK, I'll add cc:stable to 

mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified.patch

and

mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind.patch

Do we have a Fixes: for these patches?

