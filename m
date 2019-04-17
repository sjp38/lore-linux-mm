Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E6DC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23EF22176F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:09:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="jrHBLtqh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23EF22176F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B662F6B0010; Wed, 17 Apr 2019 04:09:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEF526B0266; Wed, 17 Apr 2019 04:09:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA1E6B0269; Wed, 17 Apr 2019 04:09:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1986B0010
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:09:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n6so21607140wrm.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:09:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=SYuZrgQB7tJG7K7f5LjyBEKaXZO/UGBfG4FuxsfdE1o=;
        b=LrYoJXw6N7vGxNkbSH+0JJyDBvOd6yeyKPZBbX5EGIoWFueeKxR814tDxDUgnN0X+z
         fqiygyMiwuwRhTMJnkeS9SKXGlmvWz55CbBI7isiD0A2KlHx0TMAzBiJC+WZo1WIlgdQ
         bgP/9ZlkOZ0xVA0C609bSbj8Q0TDvsbcmxw7E1JdDW5J3sZg8OAd0fKchCk0LPDhuX8J
         U9mjI/GCks3Q4rZArA9pE3U7TML+WHjJOSlchJ8Ctu75zxC7MVKeCqYN4ejpWaxHKPMc
         Lr5ZL2JxaHH7wzx9tBrVqowXdFGNZi50pvASM2ihpmRebyYPpYp1IEGimIFfjZqTtTiY
         UseQ==
X-Gm-Message-State: APjAAAWOpyclZE7NQOnaYJXyH7XUnoOCz8uotEnKZf3tKgP8uvdU/rff
	dms5Yw6ipiZFfHt+i/c2g3Qlr2tcZKo0lFG0LY0xikPtMJTHODMcJlIvpG6Gz5PMVancNWw63LD
	Cd3x/ik434zPSgU/i1mLFqX5vcI/5Rula5n3N/pt615mG93JwYnuDykOdOzCpUXamDA==
X-Received: by 2002:a1c:3507:: with SMTP id c7mr29870581wma.20.1555488596845;
        Wed, 17 Apr 2019 01:09:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFUxhceHavekJ4l3rfnuyKBKNDB4LR2ajApF+7BZz9zMi31xl4Iadg/of1MfowOQ1U3CVn
X-Received: by 2002:a1c:3507:: with SMTP id c7mr29870517wma.20.1555488595858;
        Wed, 17 Apr 2019 01:09:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555488595; cv=none;
        d=google.com; s=arc-20160816;
        b=bI985dz01CruDl+jCFCEqXsC5DCML0Kg30lhskcdX5k7TK1YBbkTBGhF2xWpFtFxbX
         5dsr7CIVxOYAq6X6pyCalXrXDwO8okhzpjjHXHyhJ6fx4CVEM2oNFaLl3zvxR9zi8Mgu
         eXzsfb2PMgwL4TNOpFmHpMcmwhmHCIHoMabpPvetmdRaeS6wKwXPhZRqXFhZuZaxUlsB
         dTcPHvbQiPeSPHkX3FPQf76ZvOD+tja2PLS4oYkkmuxFU74VEyDSwZF23oRyA9oqE8V7
         ob1JBaI9mKMJzD3N3B98BELOPus4EGg5Y/5zUCKYsPdIZilDOEZOeZTDqXQpOf67M/O/
         2ILw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=SYuZrgQB7tJG7K7f5LjyBEKaXZO/UGBfG4FuxsfdE1o=;
        b=bOZCFHzSVqmEoyxWcz09QW6wQzjnd+x3x4EJcpSfUXPNxv7Fk8IPMlOR1kmNENcxr0
         LTzsZ0cFtMJDhC7RMBpg7S/CQAoqEAgbaQ3hbtjhHWuJ7obe1CUWzNu9iYat7wJp+3Y0
         zdOhNWSqwiv224oPjDCjnHEoAf8eXQ8vlVEQPmgUpOL6LE5rYj8WBRQknzHz+hqD9CGv
         7UHXB3BePSfxbbuJmQKDmL3UHAN7QxQxAzGymX2T6Xi+8p/0euV0OQyY7ob/ghLh7j3a
         Dl8ym7/xGqLDU5OjijufIus9Lmoz0FKw+wgmfJN+ldFoYsqxw0HD/ViB9WvlHLCoz2Er
         YaLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=jrHBLtqh;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id j6si37259897wrn.331.2019.04.17.01.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:09:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=jrHBLtqh;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SYuZrgQB7tJG7K7f5LjyBEKaXZO/UGBfG4FuxsfdE1o=; b=jrHBLtqh/DMPI1om+61hhVpcB
	n8FRHS0icipmzIceW19zbPG8NLeJ2chHhS2LCguRJL2nKWwMTCs0dgqSEykSqcvTghjoc4G5iBsGB
	7AtlZx0McyFUjB5I5IAIzwyh4ZWARQpVwiSIAOBVYRI2ShdM8YzrmcT249NhjvPNc8UXrIPFOn72H
	t9JE5CJDrBpI9ykx/cY4zLHxaJ4E7ErOMHV65gfGCjxb8BRmKhtza0QkFuWBtnFqENTkjeG5A1gA7
	s2+SLKOR7iw8y3dR2q72GePIJKw2JaM2E/e+ZWCprYAKpqJai2dBLOUcCixRU/FCIODy9rzWXod5O
	ZBsX5BqxA==;
Received: from shell.armlinux.org.uk ([fd8f:7570:feb6:1:5054:ff:fe00:4ec]:52136)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hGfdG-0000L3-7q; Wed, 17 Apr 2019 09:09:26 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.89)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hGfd9-0000gr-CZ; Wed, 17 Apr 2019 09:09:19 +0100
Date: Wed, 17 Apr 2019 09:09:19 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rik van Riel <riel@surriel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Biggers <ebiggers@kernel.org>, Linux-MM <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-crypto <linux-crypto@vger.kernel.org>,
	Laura Abbott <labbott@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
Message-ID: <20190417080919.54wywpzrt3psn4vj@shell.armlinux.org.uk>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org>
 <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
 <20190416021852.GA18616@bombadil.infradead.org>
 <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
 <20190417040822.GB7751@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417040822.GB7751@bombadil.infradead.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 09:08:22PM -0700, Matthew Wilcox wrote:
> On Mon, Apr 15, 2019 at 10:14:51PM -0500, Kees Cook wrote:
> > On Mon, Apr 15, 2019 at 9:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > I agree; if the crypto code is never going to try to go from the address of
> > > a byte in the allocation back to the head page, then there's no need to
> > > specify GFP_COMP.
> > >
> > > But that leaves us in the awkward situation where
> > > HARDENED_USERCOPY_PAGESPAN does need to be able to figure out whether
> > > 'ptr + n - 1' lies within the same allocation as ptr.  Without using
> > > a compound page, there's no indication in the VM structures that these
> > > two pages were allocated as part of the same allocation.
> > >
> > > We could force all multi-page allocations to be compound pages if
> > > HARDENED_USERCOPY_PAGESPAN is enabled, but I worry that could break
> > > something.  We could make it catch fewer problems by succeeding if the
> > > page is not compound.  I don't know, these all seem like bad choices
> > > to me.
> > 
> > If GFP_COMP is _not_ the correct signal about adjacent pages being
> > part of the same allocation, then I agree: we need to drop this check
> > entirely from PAGESPAN. Is there anything else that indicates this
> > property? (Or where might we be able to store that info?)
> 
> As far as I know, the page allocator does not store size information
> anywhere, unless you use GFP_COMP.  That's why you have to pass
> the 'order' to free_pages() and __free_pages().  It's also why
> alloc_pages_exact() works (follow all the way into split_page()).
> 
> > There are other pagespan checks, though, so those could stay. But I'd
> > really love to gain page allocator allocation size checking ...
> 
> I think that's a great idea, but I'm not sure how you'll be able to
> do that.

However, we have had code (maybe historically now) that has allocated
a higher order page and then handed back pages that it doesn't need -
for example, when the code requires multiple contiguous pages but does
not require a power-of-2 size of contiguous pages.

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

