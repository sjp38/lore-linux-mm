Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B02EFC282C5
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 17:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 687AB2184C
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 17:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="G54Ed2/a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 687AB2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F19AB8E0037; Wed, 23 Jan 2019 12:06:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC81E8E001A; Wed, 23 Jan 2019 12:06:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB69C8E0037; Wed, 23 Jan 2019 12:06:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB7948E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:06:12 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id t3so1258988ybq.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:06:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=HNCegrmxHoxYKtGgIrNR+lBf/jjXvPvl9X+DRYbXV68=;
        b=bzq90KJRBvhPV+aI9vQ3DXqwDBc3WYQ2klH8CGe1UwhakXGsAEffUxSwbZPhroKliT
         zSNMb2rbYAlLR52vsbRrD/wggf0vlKXOSVQS9Oocu/zSVs5ojPf/RhfDX3mi44Rnw7DH
         zw5wBiCAD7Tl8Mp7dfsSh3VdVlzmRuJQLYXkEPqOOY/5DPodYpfdwjoIPbwB7X3rM4vZ
         DYFg4kvQUq2WiZ9mrGAuJsmDpHFgkE7ev51L/eWIHN2FVx35plWCoT3YnK5iy893xsE9
         6y7WDY7vO/spRmMpe01BQEBY2bmtYHkefelwo4k2GFTd1rbboBFpFzyPEFgXlycas1iy
         3ApA==
X-Gm-Message-State: AJcUukdbcg9kBrriPUZrRKpea1WS/a6CVI8TpTcoRkn5224BCzQ2GAEH
	tpX4qyZCTTGU8ODxBkl7QRfH5TkuFzd0djbqKm8ucBowkkPrcM3MntOZj7k0krBvVeEUIDra+Tl
	f6KoKGwh2myCOnz+33iqiy+uQDdbvGqurmktA9UJkuy1krNWHzr0izrbtNaQIYaherg==
X-Received: by 2002:a25:b44a:: with SMTP id c10mr2769737ybg.505.1548263172427;
        Wed, 23 Jan 2019 09:06:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4q566jkk49+lFZ1GDuS3U9O0K5o6HpkSONZGhlI97WM7aMnEtnkEIqKPgnIMixj3E1PiXk
X-Received: by 2002:a25:b44a:: with SMTP id c10mr2769665ybg.505.1548263171620;
        Wed, 23 Jan 2019 09:06:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548263171; cv=none;
        d=google.com; s=arc-20160816;
        b=RpCQT6WMfJUO0unafGoYfDGV+rfVwotjdqGYzL+2qLflR3r3wp0RiSRina1vK1/RQZ
         QbWaFTgIJ6soK/10wtiuw7kWRt0OwxAWlwyc2iGBD9vG5uzj4pz6Odd+qzTkq745CDO8
         WCXZD7WU6aJIYbU+lgDdbYXFZ7akQ+DZaOwg7xO1Hc+lcqtyfIscVs1Czz06thUvAE5B
         GKrtYD0RLghcZi9bbfAUhdrIWu5so2dFzbJDFDaxJpRN+YjmU3Y4Z35kTXU7e+QMHQLA
         clgVE1nz9SdFxjZL8Ins2T85d/hTXqkzh6doNAL1YhUplgIagduO1aAutyqf56tPIK7X
         Ep+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=HNCegrmxHoxYKtGgIrNR+lBf/jjXvPvl9X+DRYbXV68=;
        b=sXQ9aI1MZoK8B9WJ6W1G6ZGinChVgXBJPOpt6B0/qCvyIohj3VHrPbHRuyVCkV6fT7
         HGVoDzeH6GlDvOXc9XqcyhnrM/ATR3niBL3diJl59pfQXkMD7gDqOgGLa0Kr6ePUB4x2
         e/QGov+LTjVPOQXL+EdDnkG4zWv+f5heGETJ5CR1lmnxlM5l4/EVjvTmw/HAtLqOjOSW
         V8MB7lkIks92ODCj5DQachDtf0lut/dvap+MjM1UY1uncpA8Okla1kNym7D7jcnLMoGy
         mysITJ1KCUkJJv3RoQpL/kgTLhn1DcQc4JaDFP+d7a7aptlLaPE7bMQRc9XgMpzavoeg
         Gp4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b="G54Ed2/a";
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id d11si3014134ybe.382.2019.01.23.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 Jan 2019 09:06:11 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b="G54Ed2/a";
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 8F0998EE27B;
	Wed, 23 Jan 2019 09:06:09 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3H4iM5LmBZ-7; Wed, 23 Jan 2019 09:06:09 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id E703C8EE02B;
	Wed, 23 Jan 2019 09:06:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1548263169;
	bh=IQnhYHscQeLDdiG9MTTzOYWlFyns9kqljgzUWLrltHo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=G54Ed2/aqrGbVSOajSEmTCZGY1wWL0I7FGVzcN/gXmGuoSXNbp0hz1caxnq+pvyW0
	 yJ2lmWiGuONID19DRCA6kppGvDTwuN+JQuHXWnu0NQZ7VsofDIj3A1NoMuZJwhF9cZ
	 3IDCh3j2fjI76b73WTN0R8CoH/Wym7r59HmUmH+4=
Message-ID: <1548263167.2949.27.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Amir Goldstein <amir73il@gmail.com>, lsf-pc@lists.linux-foundation.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong"
 <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara
 <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Chris Mason
 <clm@fb.com>,  Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Date: Wed, 23 Jan 2019 09:06:07 -0800
In-Reply-To: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
References: 
	<CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123170607.FDaQtuB8jVfk4aeV0iH7h5AWvwNBV-9Xud8Yj-YkQOE@z>

On Wed, 2019-01-23 at 10:48 +0200, Amir Goldstein wrote:
> Hi,
> 
> In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong
> brought up the subject of sharing pages between cloned files and the
> general vibe in room was that it could be done.

This subject has been around for a while.  We talked about cache
sharing for containers in LSF/MM 2013, although it was as a discussion
within a session rather than a session about it.  At that time,
Parallels already had an out of tree implementation of a daemon that
forced this sharing and docker was complaining about the dual caching
problem of their graph drivers.

So, what we need in addition to reflink for container images is
something like ksm for containers which can force read only sharing of
pages that have the same content even though they're apparently from
different files.  This is because most cloud container systems run
multiple copies of the same container image even if the overlays don't
necessarily reflect the origin.  Essentially it's the same reason why
reflink doesn't solve the sharing problem entirely for VMs.

James

