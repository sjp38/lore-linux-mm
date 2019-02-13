Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CEFEC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FBCF2085A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:26:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qGrkOHz8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FBCF2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ED3D8E0002; Wed, 13 Feb 2019 15:26:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84E758E0001; Wed, 13 Feb 2019 15:26:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8B58E0002; Wed, 13 Feb 2019 15:26:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25AFA8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:26:21 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x14so2523752pln.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:26:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fuyNjv+gA9Cpq0mS7d0DHpZNnRQ2StHPyhGiej79BQg=;
        b=Mj24wTi9i3vw70vZrr52WtMGq/VG5zbH1QrNSVYGQU5wJqOuqtBS3KCBf30GqZ6dc0
         phsv5ZRzFFsCZH8YVAjHpLTERrqb0ke5WPLoBuKvjJaGnmX6QCQmRm3SvrHhXuunOSOY
         /iEbYDSPicO9g7eaz9bHdlRCqBHxO+rEzB1lH6nfoGqI3bbuBLHDwU/Opa6xGzSF51Ug
         xPgcfYgWEn14JLqiTMFb1d/3zkZ4rZAXjeDmanMalIIWZjztAMUsXyZ1+Ne9uLjI+LMG
         OcsYcCucL/H49ad5GOiMVlNzPTjhbr1Nfc0657zqybu459Y2gzwv21H1Y81G+1ljhBEF
         988w==
X-Gm-Message-State: AHQUAubKhZz7AeMqayH97tzaiQU8k0SIv8RQJHHaI4+wAAyyBBkFCoPo
	a5yPO3eiCQXf2Ux4l+ueKTTr1hVPRe9SKPakesQ6ROxtF5Rp2wI7u/1wGeR8NIElSKrMPMp5tZn
	SqvWWVm32ZB596/L/PUQqBF2mbN+8V2dvJmMCvoEtz3FoiRmcjWvoYqNh88mTqZ3MoA==
X-Received: by 2002:a17:902:be10:: with SMTP id r16mr2321390pls.304.1550089580833;
        Wed, 13 Feb 2019 12:26:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTLXOH8nS1ylbdDD7UT/gzEgoEr5P1bagR4VlbmWePLGtEMvfmjlQfT1BfRvoVR7eawFrF
X-Received: by 2002:a17:902:be10:: with SMTP id r16mr2321332pls.304.1550089580160;
        Wed, 13 Feb 2019 12:26:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550089580; cv=none;
        d=google.com; s=arc-20160816;
        b=QJXuPgBsOqjjGoMCGICgQEeX3lyJ63g4m/tg6Uw9JB/7Q2EdchGB9PMuy7oBOKXZ1m
         V4dVSnffPEQYWFcYaSzXhXHvEPQgYJgBvqPbLmy5actYzG6JkBDYfdHHmOgk8lCPr8CH
         3lY2dkOz13ewXyRENBiyFxjeH+wXtWs6IwICE6j2axUOD9Z96ISWW6DQ8ikm3mIQN5IK
         uaQll8N5mKCQQ0/8QmzhmSlOvVv2YzIYgkz9LDZLJ+7e0bYmjJ6W8v2oIkSVdn6HpZfM
         8ximktGhuQnX/UaM1oC8wMoYopwHT2jRFYAzcuAc/twhHzvi1hujkN3gxmOntbY/+tB+
         LvCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fuyNjv+gA9Cpq0mS7d0DHpZNnRQ2StHPyhGiej79BQg=;
        b=cPK/vP6fwqWgRl4PLbHzZkUGvfKfn1xYIjw9ckc7O/KGwJ/hG2iZRSJATnGJvp+WAn
         4gfmNnFwkJWZsg6pu2WtL3Kp7mjD5fRkFFaiG5NnStYSApBvlAnROIQxL/4LP6fiAl/v
         q2xixmY9VYjiN7L8FL+kf7jW7eIalcZaD/WOY8Tsw44LyKphWy2giZbQ2L9DHUXwxLe7
         NcK2g5u4GiDWDygU4p3mKa8eK3A3HqdiyWjlUk5vQqSgcNKiTuXzV6x3n4ARkRqlGULJ
         um5mGM6XNRXcWET8dU4vJdXFi1Mn48c603Tswj6+PSSKA80ZOZUcn5EfLmubg1ReQipK
         HpSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qGrkOHz8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i30si246257pgm.76.2019.02.13.12.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 12:26:20 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qGrkOHz8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fuyNjv+gA9Cpq0mS7d0DHpZNnRQ2StHPyhGiej79BQg=; b=qGrkOHz8qJCrWPVjL5jQPDQgS
	USOcI7mUSjEYxD36Eb4n+vEdFCMwhKc4EJKz1DDMC41pa7aa1qsVPetZT1FFYL7dxi59Zx8XHVeC7
	KBVChej3yiTi1dXFRaSPrWwsAH0ArhoXNVBYOuMpLzecL25EQ8+dXWQ16KQgwmAghhqaCImMA4giT
	brascUu2N5+MOPcWY+D4CHjsyvEV39+djsXMMlU3wct/HNkpiV8Nm0xZNzy76PcTGdXKbLDF3oC5P
	oiLhBL6ZAwgqRj0Fd+WyTLfvmLwgAOPtc+PezbKIGXD92zr0GnfTwRqGcndeHl5GoBs0kp7SzGBl6
	VnjE3xRgQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gu16l-0007Kp-LX; Wed, 13 Feb 2019 20:26:16 +0000
Date: Wed, 13 Feb 2019 12:26:15 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Roman Gushchin <guroan@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] vmalloc enhancements
Message-ID: <20190213202614.GV12668@bombadil.infradead.org>
References: <20190212175648.28738-1-guro@fb.com>
 <20190212184724.GA18339@cmpxchg.org>
 <20190212123409.7ed5c34d68466dbd8b7013a3@linux-foundation.org>
 <20190212223605.GA15979@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212223605.GA15979@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:36:12PM +0000, Roman Gushchin wrote:
> On Tue, Feb 12, 2019 at 12:34:09PM -0800, Andrew Morton wrote:
> > On Tue, 12 Feb 2019 13:47:24 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > I don't understand what prompted this change to percpu counters.
> 
> I *think*, I see some performance difference, but it's barely measurable
> in my setup. Also as I remember, Matthew was asking why not percpu here.
> So if everybody prefers a global atomic, I'm fine with either.

I was asking why you were using an accessor instead of a direct reference
to the atomic_long_t.

