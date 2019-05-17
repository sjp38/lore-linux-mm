Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3AE5C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 784B920848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="BrIhPn8i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 784B920848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03E536B0003; Fri, 17 May 2019 12:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F32806B0005; Fri, 17 May 2019 12:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E20236B0006; Fri, 17 May 2019 12:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA87C6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:27:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s5so4701530pgv.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=iWEen/ZJGfJ/91ljuOGunKKjV2wkX9buixAuCmp2VbQ=;
        b=lMRi2yZ8GoUQ0//TXmU8ipTVv0Y2pp8UI41tK3Zd7saTCRxA4phrHl+U81xVKK89aR
         Bd9Vr3PyfNtUW0kcDzLnNoxgfFG8BAZH0mgb1uVvFJUazS5PJD68DOmPHSRfS3S38KWm
         Re/vYV3G92ETy7JWOD52AYHk1I7iFsj6UpqCrIi41yc2RGgnWkUvKWpcpJ3p7ZgWXbMc
         ydw0B+6fXno5tqYTA0mbraVCyvNGkmYZWSQZLI4mzYYILjOch6H8RA6iI8pHxHwbgFEN
         RqOmDJ9lI/yeywC+dPjZ8onJTIjCzG8fCWJ1nJ9chIxalwTkV6apJdoPXLuZvP+Kvlwy
         pk+A==
X-Gm-Message-State: APjAAAUExV7SyYv0ulN2f5hbhCzCsDopX8myrSH6iCXvsgZ9CvMEFBqE
	X1EknjG5NzmyVg1z5Ya5g10z6qRsYmE9hSsbOIv3qL/GJmCvzE3qQ2wpP4mlVFvp2ww0RiJrdSX
	e2mCo44M+4vO+TGuKZXesXuz+ds1/g20uOvnQQR0eHXwRucY7t4vGW7r24zmse4vifg==
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr59345002plp.179.1558110477228;
        Fri, 17 May 2019 09:27:57 -0700 (PDT)
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr59344936plp.179.1558110476495;
        Fri, 17 May 2019 09:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558110476; cv=none;
        d=google.com; s=arc-20160816;
        b=z11ZtA1RtgCId36H+lEMnWAcAlvvxctilWbGoPVl8iJSms+9eS4XaA7C5EUfMe19OW
         6MaWFiLhb5qFKL2jfZfRMIySxa4s1HWIeggH0wg0oPfuo+dm/4dzksq2zt3ja0JxSMpP
         PEC+Actx/UcOJU4ddPrjC0IlQGleTfkvy5OyhNLy6JR9HayCxlMiOsortaKePxxU3Y8a
         KhyeWydIhooYvuQs/u0DK5o+TtgpWcjD0gbfImctxvr/zdQC7CWG+Sc0d2A00ofXS8Wf
         5S3A0QQ/ifL7vSeCYJ1Q3DIjCN/5VdgMX988pQpUOGchMwx3VM5XsaS7M4CRg1cpz7p6
         TM6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=iWEen/ZJGfJ/91ljuOGunKKjV2wkX9buixAuCmp2VbQ=;
        b=ekevJERAF3jOb5oqv7QxhzSsSXwga2H3JGWWEkrzwamMMXpNwg2gj7I29y/+4k13hB
         iCxV4IeGGSUFROQYNjgbWzFniLgHiX8TgJvq94nip08jyE+YXFMoBD08U36o7zs5DbfI
         NjRV8w9vPAIqnVisBnSBG7ep2b3GHfjoxpB0t7mdD7FsnMqk57O8A/AFRPGoOdn4X4vn
         3PTvouB4sGhINikLIfbK3e4pJSytnyr9v+JXV7rwoMOY2evVZFtT7ySOiDNgcQUBUPeE
         m6aF9sgaHqhqO5fP/AqQgjPIe5ZR7laBmU6agdc/rodaBMZyKxEQZ9qGk6T84ZOpQRix
         /zaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=BrIhPn8i;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor10127773plt.30.2019.05.17.09.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 09:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=BrIhPn8i;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=iWEen/ZJGfJ/91ljuOGunKKjV2wkX9buixAuCmp2VbQ=;
        b=BrIhPn8ivTpMxlGPBk6IKIJLDMLnaVlDNMmu/vyM0gUSzZQvMLtGhLveRkfKi2vAM6
         +YkxY+z/cz2xTsv4w3Vlqtv9pbXvDXBqlfpTdOthbYK93wuom517jGpjWySLJNPNrOSc
         h8Jjt1InPKK6ea8zEWJIYE8CvdlJcSCOeFKdo=
X-Google-Smtp-Source: APXvYqzdfBNgSus/Lm8itRXOgphQ1CTGG6b41OjNny+0hxO3EQG2Jz/Uzp0pZo6RricP0oBOyE23uA==
X-Received: by 2002:a17:902:7d90:: with SMTP id a16mr56467129plm.122.1558110476011;
        Fri, 17 May 2019 09:27:56 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id i65sm12436762pgc.3.2019.05.17.09.27.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 09:27:55 -0700 (PDT)
Date: Fri, 17 May 2019 09:27:54 -0700
From: Kees Cook <keescook@chromium.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
Message-ID: <201905170925.6FD47DDFFF@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
 <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz>
 <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
 <20190517140108.GK6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517140108.GK6836@dhcp22.suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 04:01:08PM +0200, Michal Hocko wrote:
> On Fri 17-05-19 15:37:14, Alexander Potapenko wrote:
> > > > > Freeing a memory is an opt-in feature and the slab allocator can already
> > > > > tell many (with constructor or GFP_ZERO) do not need it.
> > > > Sorry, I didn't understand this piece. Could you please elaborate?
> > >
> > > The allocator can assume that caches with a constructor will initialize
> > > the object so additional zeroying is not needed. GFP_ZERO should be self
> > > explanatory.
> > Ah, I see. We already do that, see the want_init_on_alloc()
> > implementation here: https://patchwork.kernel.org/patch/10943087/
> > > > > So can we go without this gfp thing and see whether somebody actually
> > > > > finds a performance problem with the feature enabled and think about
> > > > > what can we do about it rather than add this maint. nightmare from the
> > > > > very beginning?
> > > >
> > > > There were two reasons to introduce this flag initially.
> > > > The first was double initialization of pages allocated for SLUB.
> > >
> > > Could you elaborate please?
> > When the kernel allocates an object from SLUB, and SLUB happens to be
> > short on free pages, it requests some from the page allocator.
> > Those pages are initialized by the page allocator
> 
> ... when the feature is enabled ...
> 
> > and split into objects. Finally SLUB initializes one of the available
> > objects and returns it back to the kernel.
> > Therefore the object is initialized twice for the first time (when it
> > comes directly from the page allocator).
> > This cost is however amortized by SLUB reusing the object after it's been freed.
> 
> OK, I see what you mean now. Is there any way to special case the page
> allocation for this feature? E.g. your implementation tries to make this
> zeroying special but why cannot you simply do this
> 
> 
> struct page *
> ____alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> 							nodemask_t *nodemask)
> {
> 	//current implementation
> }
> 
> struct page *
> __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> 							nodemask_t *nodemask)
> {
> 	if (your_feature_enabled)
> 		gfp_mask |= __GFP_ZERO;
> 	return ____alloc_pages_nodemask(gfp_mask, order, preferred_nid,
> 					nodemask);
> }
> 
> and use ____alloc_pages_nodemask from the slab or other internal
> allocators?

If an additional allocator function is preferred over a new GFP flag, then
I don't see any reason not to do this. (Though adding more "__"s seems
a bit unfriendly to code-documentation.) What might be better naming?

This would mean that the skb changes later in the series would use the
"no auto init" version of the allocator too, then.

-- 
Kees Cook

