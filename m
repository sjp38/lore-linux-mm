Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1073C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 01:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DFF32085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 01:44:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VYE7PKot"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DFF32085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1BAA6B0005; Wed,  1 May 2019 21:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAD706B0006; Wed,  1 May 2019 21:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F77E6B0007; Wed,  1 May 2019 21:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 652776B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 21:44:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so437285pgo.14
        for <linux-mm@kvack.org>; Wed, 01 May 2019 18:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y53VfYOiA/MXZf8Wo2SPne1jzkwcek0/8OpLxdvECJY=;
        b=UoZ1kqLmVtWHUhllhS6D1+PwFSi8/JDfBRyTW6K+9Oa1bxWa0q5S14SB4x91kxJk9+
         FqxhPgubyIA8hOKWQmWv2w92RG1Br10mY2WHLMdu+g4O+yQKMykQAKJb7sQiimCWomGM
         7ItpuXwcn/xLKJuIUJJn6pGwktBUDooX5skwLOacbwUkJAb2tS6Rkxb+Ry6vXm98ni3U
         g0lM1ZIlVyMsyZ/VWjlWczR0OcB31eZp+CFOu0qb+k+iw7XZOJ/+RlC3EkZKawqhOmht
         T4W+BijbiSZ2tScCWRMEIlNe2nXaNDhUs/2Mm2hihnkGHZSGCW1qUWPrTfzSLigurlwS
         lZKA==
X-Gm-Message-State: APjAAAX6CmYHfkFpCB6otL1VsLL9MWh/JDVPwCREe/gi0TB2bk7Hl5mO
	xwGFtFAhYZ2ZkVfjKNYRv3QxTBzv2kWyy8Sb/esWD3FkkneoGIoklScegZ1/fyACSfeJXaRnK7A
	3rrmsFPbxL5WHryzGqx+7SyckaaAlC7vrBI+ZGHWsS+1Z5bFJJoevqx4U4tTK6BOBhA==
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr788096plb.45.1556761469917;
        Wed, 01 May 2019 18:44:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu/IH8qjde2zJHv+VEDeh53Lq7xMfwpWRTbnA050QNvayplfIh6kh3rJTqLKKwgQEcR4SG
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr788035plb.45.1556761469060;
        Wed, 01 May 2019 18:44:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556761469; cv=none;
        d=google.com; s=arc-20160816;
        b=D9akx2o8KEdGvTeHnCSzIISChOIcPPO7AIORuAoQ7WvWu7aiaZcNumAnElrToT6JAF
         fQHsVy7sfwYTh2bTgcBTW/nbqrLNGDSFUx5yLjjNOEI+lXDsgkwhoPsCgJWUuVPon285
         CqB5pJU531897lh8Jre/u/jWKly3d9P1OdYlv8dHi4js4xYGmaSYOC+6jpM6iM5ERvtb
         E77A/oQv+sf4p6y+vXMdUWHCck4tlGDrf68F2vuGgLa+bXBbvpWJ1fuh2Bypr7oAnbRN
         oB7M1anAUQrSmh83mNwAYGYvAdmlLjMTeQXdTbT+IUu5L6wrwd2TPOferBbzrrtIk+QE
         KK6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y53VfYOiA/MXZf8Wo2SPne1jzkwcek0/8OpLxdvECJY=;
        b=ldDlehfEW/KkwyH20ohw0v/3JbAhghwH54sRHX8o0S+V2ea6gRCh60rzVY9cvPpCrp
         UtMxiLkRGhhgi2edR17vZxlb4B6xdSE+V/uN41rLUGhm/Zur+MLxUsHyEa9kudw2FniU
         LOE+9YLO0vbFR7O5k0srMEKYlAMsyBNyRrcB8Fclm0s52XVm4odehCxAF+Bf8fcrR+ew
         DvcnyRnz0keZlSd18m+ixVLKZIh4ABQ+KPXaB0Ww6RX3JXXILUVJT+qAwftX3G4I8q90
         C0W2Gh6wZqno24bf37WIy0HmqzBs0Ux1kCjSsxV6/dblrukUpmDyWgETj9pk6RO2XEnZ
         8m2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VYE7PKot;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d6si17034277pgk.129.2019.05.01.18.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 18:44:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VYE7PKot;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=y53VfYOiA/MXZf8Wo2SPne1jzkwcek0/8OpLxdvECJY=; b=VYE7PKotQxs/oJ2smNzmRlGn7
	vC6rHSwDHr9gQfV0YtYSV2yUVg4ZPWpN9SNVskAe1K9CRoRofZ7esUPRUzjgohFzwqaecc+2w3qJz
	hrXp6+62HOmTD1Im9ww2zQqLMPNvskirWueS2ha/Fs1kBPGsLEI2dMoz8IxeSDP3bDjgtlU7qzDFG
	s77flvY9VkhFc1AItHA6SNFCp1m8POxF8PBmqMR/XjZt2UrOQpxJcfqvVJpx3IRy6MqZR3t11mD0N
	kdnTGVwr45z2IZj31/ujIKsogxqwCXe+cepwam885j4sa5uFaQ4AEudexWUQk5FxE2t0N04oTFd4T
	32ML/tHlQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hM0lq-0002IA-F3; Thu, 02 May 2019 01:44:22 +0000
Date: Wed, 1 May 2019 18:44:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jann Horn <jannh@google.com>
Cc: Jan Kara <jack@suse.cz>, Linux-MM <linux-mm@kvack.org>
Subject: Re: get_user_pages pinning: 2^22 page refs max?
Message-ID: <20190502014422.GA8099@bombadil.infradead.org>
References: <CAG48ez3C11j5On4kqwSBCZGtpS5XMohwEyT_2ei=aoaTex7D9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez3C11j5On4kqwSBCZGtpS5XMohwEyT_2ei=aoaTex7D9Q@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000800, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 06:19:00PM -0400, Jann Horn wrote:
> Regarding the LSFMM talk today:
> So with the page ref bias, the maximum number of page references will
> be something like 2^22, right? Is the bias only applied to writable
> references or also readonly ones?

2^21, because it's going to get caught by the < 0 check.

I think that's fine, though.  Anyone trying to map that page so many times
is clearly doing something either malicious or inadvertently very wrong.
After the 2 millionth time, attempting to pin the page will fail, and
the application will have to deal with that failure.

