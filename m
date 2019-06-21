Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D5A1C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:15:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF4D1208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF4D1208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653106B0005; Fri, 21 Jun 2019 04:15:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DC2E8E0002; Fri, 21 Jun 2019 04:15:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C838E0001; Fri, 21 Jun 2019 04:15:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC9196B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 04:15:34 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y130so1043268wmg.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 01:15:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gvbRTCQhZvqkaynZX02aoLCskbMv6rjKoYxxWYe5ZtQ=;
        b=Joyn50aBDLQfnfZe4ybFrBeUvKqq7AR9T3gy25Br2k9XsoIX2n8PslfrHkpMNO69Jt
         bsO8QLKwdo1dNTLfdLypp4ZVdTFZHWsfQUijmR4PTTXK8soiiCgsd5Byf1XTtad+RWHN
         kvlTCceQo4tfdG8L2serQSqRyDQrWzUMM8qNkHSoDF8xEkM+mfBkrqJiiLDL5Blk3x3P
         SOIFE2EG1QW3qfW9bQKENVRXGPqQDVuQM+PgSC/4Z6sm2ajLJ4+mW9CYpm1+KOjT87wG
         ZvwI5/K1Mz2ryhl5zCTLamzaaBEGMsvdZ+jodeHM9eUwhehamQZSfST31kG4p7a2VhCA
         Kjrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW6njviotymjVZ/xH2/rTaupWUnLNv7rsOwTbnUyAXBGhKDxuiX
	Lsj2cgc3BuO8UJnJD9tHOe08oIu8oaLyDdJJL2TmfuvXBPyRILh+G9vuxb612xNp6LIJxQHRAY9
	GQDwr6SEHBMsTq9Ba222Dv1KuaIi/4BAY07dW8hF31ZVxcqWAw+YDkkXFKdShgaTKmA==
X-Received: by 2002:a05:6000:124a:: with SMTP id j10mr2069687wrx.191.1561104934486;
        Fri, 21 Jun 2019 01:15:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwHZwWAmApSCyjRJEX81tZGagEJAi5d9IEmF7lw5GRbi7QxbRreSegFlxn+KWVXSEtbg5P
X-Received: by 2002:a05:6000:124a:: with SMTP id j10mr2069613wrx.191.1561104933680;
        Fri, 21 Jun 2019 01:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561104933; cv=none;
        d=google.com; s=arc-20160816;
        b=ircockXMfTtps6Cgm4oXNI3KGZ2rJAeeYcAiBkti9TPplD4rKLoUwbpY4UnOppxGBI
         lYrJyxQv4nm1ioqzlxP08GBn+KPvd++JGvELJOpmIrlQgkB5rutYdiQevu8JdrpYQ4k4
         +jUnimPQrhIC+npmelyD0JNyr3jmu58E04129ngcqq4qN1pKmsEqoBee3mD0C4g7UiU8
         oTWIPdDVgEgSWpuBxtikOzjtYhwNQEwikVRY6GyDO08dV00dLAY0vqdovuNb9Jd8Btit
         K+J2pbpqCW0Ll64K0tmXjfq6xp2g57kIqlMzwmYaH0bEnTxyBk2u47ep76cBXFOMtnq1
         kfVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gvbRTCQhZvqkaynZX02aoLCskbMv6rjKoYxxWYe5ZtQ=;
        b=oDFwqf5VpOC7t0VtPvCOXCu11+wHQkNdW3TAOHF8hhtdko9eYigMZ/puMg1adI8lTm
         bpg76MfCQTUUwcYlxENWlHBsItvuUdn7JgpRRMK/iZWle1NuZgDPUwuy0ZLWZTbOohmX
         aEkcP7LNfIK+K5tVUyJzISsY2htESEEC0YL7TlldkQIu5sAY0YyzQ9uyncJ9h6W2lry4
         gKAvv5TMjSn5gcN+J0fVtiv/qVmy+ImEYmCCmqIjgPmro1HjcC3LyG2PIMLvr+mcoL/L
         9G643Qe8lYzVYICRTiVTfR2bmPHoy3+ROwR2vvgAmpKYMPMKrmuuobRzdBJytP8bC0OJ
         d6pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q4si1869017wrn.99.2019.06.21.01.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 01:15:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id BAE6368C4E; Fri, 21 Jun 2019 10:15:01 +0200 (CEST)
Date: Fri, 21 Jun 2019 10:15:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, James Hogan <jhogan@kernel.org>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	linuxppc-dev@lists.ozlabs.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Burton <paul.burton@mips.com>,
	Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
	the arch/x86 maintainers <x86@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments
 in a structure
Message-ID: <20190621081501.GA17718@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-17-hch@lst.de> <1560300464.nijubslu3h.astroid@bobo.none> <CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com> <1561032202.0qfct43s2c.astroid@bobo.none> <CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wh46y3x5O0HkR=R4ETh6e5pDCrEsJ94CtC0fyQiYYAf6A@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 10:21:46AM -0700, Linus Torvalds wrote:
> Hmm. Honestly, I've never seen anything like that in any kernel profiles.
> 
> Compared to the problems I _do_ see (which is usually the obvious
> cache misses, and locking), it must either be in the noise or it's
> some problem specific to whatever CPU you are doing performance work
> on?
> 
> I've occasionally seen pipeline hiccups in profiles, but it's usually
> been either some serious glass jaw of the core, or it's been something
> really stupid we did (or occasionally that the compiler did: one in
> particular I remember was how there was a time when gcc would narrow
> stores when it could, so if you set a bit in a word, it would do it
> with a byte store, and then when you read the whole word afterwards
> you'd get a major pipeline stall and it happened to show up in some
> really hot paths).

I've not seen any difference in the GUP bench output here ar all.

But I'm fine with skipping this patch for now, I have a potential
series I'm looking into that would benefit a lot from it, but we
can discusss it in that context and make sure all the other works gets in
in time.

