Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31516C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F259F20659
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:57:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F259F20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A410C8E0003; Tue, 25 Jun 2019 03:57:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C9678E0002; Tue, 25 Jun 2019 03:57:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B9AC8E0003; Tue, 25 Jun 2019 03:57:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5608E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:57:23 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i2so7556610wrp.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:57:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+pYd+epVLeg814mF+hnpsLw/6K6pRxUMqBdHU9Axc0U=;
        b=OvgHRotDfIkH1YotTrCEevMyQC5c9OAhqJMz/Wlr0vqPMkNxuix2W4kgsrzuOi5UOC
         J6F+ozdtw+R9l2tS+siJLzZyhbjAIc0VKWxNq+HEilZ9NUmF8hY7UZL6NAQEG0PuS1J2
         Aoc4dumqwpP/CvFj5/OlOvSuG3w0CPvVfaFhQmaISZCrrsG6cR+t6Ul5Wn26hkInfX+v
         yv44kxCcJcwXG6q+Fxap7r2G8m7JGjJtiDJ3tdhIJVGOf4o1MzvUAGtkZeulYjxGo/4A
         GASIvAC99x8HZ2S/cmpos0tQadrV3iQY5BHycXujYru6mv0UkuEDw9nKZY7A+pmvEyqa
         nkKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVZivlBFBiMjjpegeG4gIYHypSHeR61B2J7q9y5fjoedSvEb7r3
	eSzh4FXEpH7wxNdLlEdDTt9CoXRwwZbxEiNADdzCMkU81aN/Ew6OdxGHQMRSf+KtirjJrpmhc9+
	eRFKQh9wQYVXpPJ1feyVuH8YokeS47LmcwmszZixb41NeoMEJkRIq6tDpwxtEPVfRUw==
X-Received: by 2002:a5d:4b52:: with SMTP id w18mr2518304wrs.331.1561449442862;
        Tue, 25 Jun 2019 00:57:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQc506qg3ljjR97pGPUciMlj1X4yPXSE/UpMpOzktYuGzLBmRD4K2j72y5UjHh5a4KZv62
X-Received: by 2002:a5d:4b52:: with SMTP id w18mr2518261wrs.331.1561449442296;
        Tue, 25 Jun 2019 00:57:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449442; cv=none;
        d=google.com; s=arc-20160816;
        b=Kh+HZN+BNZhGS+QD1ulKPK9bOzsldNWPTcWI96QeCWoPI55WpVUZN5LhYpgv3KUQjT
         Nwn1EKooZm4gING8sJiN8eSMTkctAVWUd/NugQnJgpqpZUm1zdJLd1FULnixMFwrRCPJ
         G8mPwDTi2YEUAFMTQtr3+f7Uz5uugFUHY+la9+GORofeUkNSjmIUvBsDkHzPf4OdTxIk
         Y3wvjIvrdPzLpXX0FcN0ZXFJU5swkMLJaZ3ruFR+YArbharO9Jv4+f54GxhuJCU+8vyh
         pLNd7w7DujCM6koeZmaiYKjB0PW9Y1aVQ0jFutYcMvwZQ+f1yriqhV9/X8dYHkmQnNqs
         sP2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+pYd+epVLeg814mF+hnpsLw/6K6pRxUMqBdHU9Axc0U=;
        b=GsjWrAuOGBorVRQWCm1A1zyVK6IfTbhZhfH3RCqdfcnPbWerAI6172pX6De0pmu2bz
         e//mA/u7EXWEVbcZZNjQGvIvyHXBLOBBoH9cNRjc52SciEqwgUFVnP0QzwNvIQJV88oS
         cL2J0EXXiC10QqJCoVENWqQl5Aeq3xtbmG9r6NerskoI5gkDY2puIlhUaDCalj9JWpN4
         uinACDd+RLkoMqbTZ8d797oV4WsxXfPI57OG4P7VdHebFqIKdkJtOWUDVudRNjYSDOcd
         bujIZZtjZbZp8DAvXY0uFrqrirgGMP+33XQBYQbZNNwr/mz3SkE1pRT62N7+5ZAMn1gV
         vHBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t4si1395985wmt.14.2019.06.25.00.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:57:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 1831068B02; Tue, 25 Jun 2019 09:56:51 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:56:50 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 11/16] mm: consolidate the get_user_pages*
 implementations
Message-ID: <20190625075650.GF30815@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-12-hch@lst.de> <20190621144131.GQ19891@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621144131.GQ19891@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 11:41:31AM -0300, Jason Gunthorpe wrote:
> >  static bool gup_fast_permitted(unsigned long start, unsigned long end)
> >  {
> > -	return true;
> > +	return IS_ENABLED(CONFIG_HAVE_FAST_GUP) ? true : false;
> 
> The ?: is needed with IS_ENABLED?

It shouldn't, I'll fix it up.

> I'd suggest to revise this block a tiny bit:
> 
> -#ifndef gup_fast_permitted
> +#if !IS_ENABLED(CONFIG_HAVE_FAST_GUP) || !defined(gup_fast_permitted)
>  /*
>   * Check if it's allowed to use __get_user_pages_fast() for the range, or
>   * we need to fall back to the slow version:
>   */
> -bool gup_fast_permitted(unsigned long start, int nr_pages)
> +static bool gup_fast_permitted(unsigned long start, int nr_pages)
>  {
> 
> Just in case some future arch code mismatches the header and kconfig..

IS_ENABLED outside a function doesn't really make sense.  But I'll
just life the IS_ENABLED(CONFIG_HAVE_FAST_GUP) checks into the two
callers.

