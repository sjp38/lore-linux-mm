Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BD75C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1811B20881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:04:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="u8ZxO+aI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1811B20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6E3C6B0003; Wed, 15 May 2019 11:04:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1E136B0006; Wed, 15 May 2019 11:04:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6066B0007; Wed, 15 May 2019 11:04:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93B036B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:04:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g11so11640pfq.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:04:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=FKh5p7YUNtptnQS9Ece7TuhC8ViP4880CqVJILUI6fQ=;
        b=lszP52V1Kg6c0qYvxWmnv5sXjg3vTIwiifurX5LKxGTQMM4Nvwo/spLiVtk0g2xojW
         TyfBGoq/XAX4UNmAbarYvmtjT/Ba1LbQ//7P47jVGk7icg6wG8HbtBPUIoz7EOdblBBm
         tXch9u90ZIc7IRtHh0oWfugc8aP0rYfv1gtV/x3IUTRUWtCO/JCYcXLRaD8w3P4kI5G0
         MQugzyIDqSrpKOwKIHx+NSamqSfc8WWlFa2/OVp1kCVnvtvg9cb/eNs+14Wp89Zn8nt1
         kjI/NshHSim3X63Y8Dj+qi49DtcYGJK9zB3HQTcj6YralkiApuc7MrscmVmjB9oF6s1V
         vSGg==
X-Gm-Message-State: APjAAAUWVeAH6dU11QJ5OE23tKjun61MA1vLqGzIadZAwB59CAROScpx
	/Cofe1lXwRVfauv0AH2XA73MQ+eh2ZI2t3PtI9hKYHGkyphIg2OoUo33cliwaxUHSUnRIb1LoSb
	Zzrdhc6LttCITkk4bXNQTz4vpaCxam2yiVIPcLZUwVsbsdrwpYYjQh+ZU2unFnpjkfg==
X-Received: by 2002:a65:5785:: with SMTP id b5mr8281186pgr.252.1557932651149;
        Wed, 15 May 2019 08:04:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2KxHh2RxAYQpVcKyx0Tv67WLnOyO2BzoaWX+2kwVBvp8fNovsU09pvwTtQVIv8uawGtDB
X-Received: by 2002:a65:5785:: with SMTP id b5mr8281067pgr.252.1557932649695;
        Wed, 15 May 2019 08:04:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557932649; cv=none;
        d=google.com; s=arc-20160816;
        b=iuivrPHBxW8iptv7cyHK/6vApv40oQRb3IKVOqavT/UFqJKBNAcn2wxk0G1oyJDRX6
         9tTCS9VlpnQQaB3tFRBCsvNId59ZwjHLa8lIHOmd78NCx0rOqUFZ6+lHQ8UBcfc2cV0d
         KKgu0/I07SxuezC/sOhqpMOsslasQrubO2kXgO2JfPyBjXXgkhClhRe13eOgEFtSF+wC
         SJcOTZbBOEngo8yYztFt85+qKaOmSFk1SIdarApxKQhhYC7D7B3yZmMWT32ZxGt1zACU
         8yovXgNK9dP9Tl1Pcmt6ecawOiTt1q5KdnlUflrWe13Ma3jCJV870bIRzfAwXYBkFnsO
         cOJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=FKh5p7YUNtptnQS9Ece7TuhC8ViP4880CqVJILUI6fQ=;
        b=zdEalRqsD5hLL6l45YGr/jmk4a6PWrBMSeBiPeFrCMf5Muiouv8I0KaLKNesy4dUT/
         OEOE4QNqJge0arX3OZrh9BYmEBLGXdbWxVF9xS7TS9MrAzIO7DH2DyJzZjs1TQBpSj0B
         N4Ew3CPYriWC90SBtdHfT/6wu1l3WSQelyGaejKJ1iXLpD6cEgdvFc8+PaSvFyEshaJK
         okqC0t1+xzBWfnGNyxAz8ymhdzKZjtbLxiD9JfMgDrRpJ4fSVVMlS9OZqTNh0gQrt0NR
         pwiKavFzj0gQ0u6ECuzLzJ/mTpBtg4lvfNFd5FwZbKeqBilPM0nTE0XQ5IzsGfWbd/VX
         n5vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u8ZxO+aI;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p16si2005836pgj.312.2019.05.15.08.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:04:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=u8ZxO+aI;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D396720818;
	Wed, 15 May 2019 15:04:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557932649;
	bh=35dYv7cUrj9box5GYfZLkLxBHkEcek2CZmiVu9HLksA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=u8ZxO+aIhqlvTlqv5offOKjWeovz/LLOQMt+n6wfRE3fY6Id8zD51XO3GFgKVxRBd
	 +OBfpOCFQHP4uYuF5BdcEv4Nyid7GcUUVqS5LhlbJaoIiy8XgNtIBbbBfFg1oXxZ07
	 B+ETbWC1AsIJB/rVtskuygrba2bnCMpjLU/Jfr1o=
Date: Wed, 15 May 2019 17:04:06 +0200
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
Message-ID: <20190515150406.GA22540@kroah.com>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
 <20190515144352.GC31704@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190515144352.GC31704@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 07:43:52AM -0700, Matthew Wilcox wrote:
> > > W dniu 25.04.2019 o 11:25, Lech Perczak pisze:
> > >> Some time ago, after upgrading the Kernel on our i.MX6Q-based boards to mainline 4.18, and now to LTS 4.19 line, during stress tests we started noticing strange warnings coming from 'read' syscall, when page_copy_sane() check failed. Typical reproducibility is up to ~4 events per 24h. Warnings origin from different processes, mostly involved with the stress tests, but not necessarily with block devices we're stressing. If the warning appeared in process relating to block device stress test, it would be accompanied by corrupted data, as the read operation gets aborted. 
> > >>
> > >> When I started debugging the issue, I noticed that in all cases we're dealing with highmem zero-order pages. In this case, page_head(page) == page, so page_address(page) should be equal to page_address(head).
> > >> However, it isn't the case, as page_address(head) in each case returns zero, causing the value of "v" to explode, and the check to fail.
> 
> You're seeing a race between page_address(page) being called twice.
> Between those two calls, something has caused the page to be removed from
> the page_address_map() list.  Eric's patch avoids calling page_address(),
> so apply it and be happy.
> 
> Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
> backporting to stable?  Nobody realised it was a bugfix at the time it
> went in.  I suspect there aren't too many of us running HIGHMEM kernels
> any more.
> 

Sure, what kernel version(s) should this go to?  4.19 and newer?

thanks,

greg k-h

