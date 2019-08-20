Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEA70C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AEE1206DF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:38:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="J0JfbJ2k";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="J0JfbJ2k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AEE1206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51396B0007; Tue, 20 Aug 2019 06:38:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E01FB6B0008; Tue, 20 Aug 2019 06:38:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D17CC6B000A; Tue, 20 Aug 2019 06:38:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id B08D06B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:38:08 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 63303181AC9B4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:38:08 +0000 (UTC)
X-FDA: 75842456256.11.hose53_45921da63a70a
X-HE-Tag: hose53_45921da63a70a
X-Filterd-Recvd-Size: 3199
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com [66.63.167.143])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:37:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 9F35A8EE302;
	Tue, 20 Aug 2019 03:37:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1566297471;
	bh=nPXOc4ZVyRqxGhlQ4aY6zZ2t3ir/odcoGQr5/9oRWno=;
	h=Subject:From:To:Date:In-Reply-To:References:From;
	b=J0JfbJ2kzDsl59qe3BDl2ISaolgWuBCqguDzJNM0qamEHEIGj37gfxyds7ARByVGb
	 AMM6/0IjdY78GIwyIOzRVVxIRsWqaF0rM5Ggkq6gYe2JDw11dsaNbTLzmkiUFrxobP
	 jpg+M/K6xANHbbCeeuv6gxlIh0F2Nlf9UHFCKx5E=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id InBc22n-udsf; Tue, 20 Aug 2019 03:37:51 -0700 (PDT)
Received: from jarvis (host86-134-253-248.range86-134.btcentralplus.com [86.134.253.248])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 79A3F8EE0E3;
	Tue, 20 Aug 2019 03:37:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1566297471;
	bh=nPXOc4ZVyRqxGhlQ4aY6zZ2t3ir/odcoGQr5/9oRWno=;
	h=Subject:From:To:Date:In-Reply-To:References:From;
	b=J0JfbJ2kzDsl59qe3BDl2ISaolgWuBCqguDzJNM0qamEHEIGj37gfxyds7ARByVGb
	 AMM6/0IjdY78GIwyIOzRVVxIRsWqaF0rM5Ggkq6gYe2JDw11dsaNbTLzmkiUFrxobP
	 jpg+M/K6xANHbbCeeuv6gxlIh0F2Nlf9UHFCKx5E=
Message-ID: <1566297465.2657.14.camel@HansenPartnership.com>
Subject: Re: Do DMA mappings get cleared on suspend?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Paul Pawlowski <mrarmdev@gmail.com>, linux-mm@kvack.org
Date: Tue, 20 Aug 2019 11:37:45 +0100
In-Reply-To: <CAKSqxP85cbYXt6q72aajXUTombZb-wbEfoWteBQrjJFO890rfg@mail.gmail.com>
References: 
	<CAKSqxP85cbYXt6q72aajXUTombZb-wbEfoWteBQrjJFO890rfg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-19 at 21:49 +0200, Paul Pawlowski wrote:
> Hello,
> Do DMA mappings get cleared when the device is suspended to RAM? A
> device I'm writing a driver for requires the DMA addresses not to
> change after a resume and trying to use DMA memory allocated before
> the suspend causes a device error. Is there a way to persist the
> mappings through a suspend?

What are you actually asking?  The state of the IOMMU mappings should
be saved and restored on suspend/resume.  However, whether mappings
that are inside actual PCI devices are saved and restored depends on
the actual device.  In general we don't expect them to remember in-
flight I/O which is why I/O is quiesced before devices are suspended,
so the device should be inactive and any I/O in the upper layers will
be mapped on resume.  The DMA addresses of the mailboxes are usually
saved and restored, but how is up to the driver.

James


