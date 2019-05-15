Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BA7AC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:37:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E14920873
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:37:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="esXearoJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E14920873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E8AF6B0003; Wed, 15 May 2019 11:37:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99A606B0006; Wed, 15 May 2019 11:37:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 888E86B0007; Wed, 15 May 2019 11:37:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5261A6B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:37:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r75so54136pfc.15
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:37:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vh6bWSTbkW68l7AoeMuMXgvnZlk2i0Osj181aaqGeEs=;
        b=GsYkKx33IwbV7xUhL8PwQUhQvg34c0NSngeoUn3rt2KkX2L5llw3Qqz1HGeTntNYeh
         cBT9RZIG7u7NHSaGAFSaQW2umofQCTxRfJn3mqMs030nwHDJ6A5iZWnex+XpxjJktpU0
         tNT3Cm376O3C3MGF9k6D4/QWcKHH5ISIn7GKpctn+qdKPgyvf/vmxk9APp0mezu6Hctk
         2GleoZkfvbY2iYY48L9Dg+qM6wC6Eg6ojpXBUhrdArAVdol5uWHPBvU05XZ/+j53uDQz
         YqqHHPtXxSDooooxbDlVSNWt4WVjdRKqwnNywUijDofLluwMsBpshg58zIdW2X2LS79W
         6RXw==
X-Gm-Message-State: APjAAAVzsgwYNDyjmqfEoAaC5Osyd7qDGeP6I47EFAt+gcAFuB0/5rlv
	s53cSlcSp0t3UG3nC+A8fHFXte46m/tKGsMOh8h5oqswMlJ7RtFjjXFsgVjiNVRmj43SvDygCyW
	pOZuNjan2OElcxT+dC7pQBC0+bd10R9SA2C4N6L2iqpIBuceTUJTgj31e+y3fv43kAg==
X-Received: by 2002:a63:f703:: with SMTP id x3mr43767824pgh.394.1557934661700;
        Wed, 15 May 2019 08:37:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7KV2OrRzLUyXqsBDZC64B+gJcS69ENLgxm2irjrY4zubDWVUEHHiTAW6AORTn+EIxFUnW
X-Received: by 2002:a63:f703:: with SMTP id x3mr43767776pgh.394.1557934661000;
        Wed, 15 May 2019 08:37:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557934660; cv=none;
        d=google.com; s=arc-20160816;
        b=iSg5zSlIgeOlnnH08N59Ykpe5KqV/OzgrlonOu8XvbVZVYzSDx69nBpo9Sg8vy4WtB
         fNRxTb+E2uDUF4IMzHV2LCqQG+Zt1xyKEqSM91ZOYLS5DsJDaPYXXhIfJuYmLXyMgST+
         4F5greg0XR8PTXye3fv5jKu/JGkCi10ZJnXZ6SrbXxNdJ3ObKX3U0k2gOVXpHS9rAIck
         42bp0jSBQ/BvIJL2h0lKrX2hE6pI9Cf8Ndnrp+X51VopBYBhq0oQKHaLJMg5LU0pxwwd
         zQweDh2b8VMVD0l2tR0BXf6aXa27OJta1YXb/PD4upp3yZciRfOtmRnxjPWbTaH/SAqw
         2Lxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Vh6bWSTbkW68l7AoeMuMXgvnZlk2i0Osj181aaqGeEs=;
        b=smPPEz9bpV8kNVp13OQahrgoK3wuBXB7pc7/1LKqpt0YMeNrGYRXfuogrCUl8X3Mwa
         sGypTXwadBRDoJGGPyzbgwe+ML/mAupwPIVkEJb5YnS6WeH0beQyu9l+B35llcjucfj8
         AETOTz1kN8ICXmHVmqMe/Lgo+E27Am83coxNRmV3RBixa4txK6X7q2zih6/SbR+X/PAU
         u/3CBdPsigQahbrXzZoqZ6dv16/y5VjJCqWlVlbsXFsI+5g1rPBsdETZzYFY56f0J5uH
         9Ysh0nNkUKr4rc2XMdTFdWbHHNo3xgqGV3lB3J9aTfE848J5Be0VhMPyOSSXUFtzryh0
         xTWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=esXearoJ;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y36si2083532pgl.336.2019.05.15.08.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:37:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=esXearoJ;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F41A20818;
	Wed, 15 May 2019 15:37:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557934660;
	bh=lIwfUgZLsOETAqKmdIH6ivluhJ74dnvjF64W3zo7G3U=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=esXearoJXyErGlUIXkOrnIwNQRHkRzCAqnhw7vp9RJR39xntePk7hOYLZEhbxtgA4
	 AaJRauP72JOUeasJHE7Wimfzcs5d/cquM0J5pC1xnS4aRGQ0Bcs/uw8xgNuQvJXYTk
	 Ip/EGnYVhJ/lQ34norEhZKVj9l199Bg7B6z4b690=
Date: Wed, 15 May 2019 17:37:38 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Lech Perczak <l.perczak@camlintechnologies.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Piotr Figiel <p.figiel@camlintechnologies.com>,
	Krzysztof =?utf-8?Q?Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>,
	Pawel Lenkow <p.lenkow@camlintechnologies.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
Message-ID: <20190515153738.GA27219@kroah.com>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
 <20190515144352.GC31704@bombadil.infradead.org>
 <20190515150406.GA22540@kroah.com>
 <20190515152035.GE31704@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515152035.GE31704@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 08:20:35AM -0700, Matthew Wilcox wrote:
> On Wed, May 15, 2019 at 05:04:06PM +0200, Greg Kroah-Hartman wrote:
> > > Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
> > > backporting to stable?  Nobody realised it was a bugfix at the time it
> > > went in.  I suspect there aren't too many of us running HIGHMEM kernels
> > > any more.
> > > 
> > 
> > Sure, what kernel version(s) should this go to?  4.19 and newer?
> 
> Looks like the problem was introduced with commit
> a90bcb86ae700c12432446c4aa1819e7b8e172ec so 4.14 and newer, I think.

Ok, I'll look into it after this round of stable kernels are released,
thanks.

greg k-h

