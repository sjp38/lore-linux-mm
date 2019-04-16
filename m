Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E9D2C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B9A9206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B9A9206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB40E6B0007; Tue, 16 Apr 2019 14:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A60EE6B0008; Tue, 16 Apr 2019 14:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92A986B000D; Tue, 16 Apr 2019 14:50:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4136D6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:50:35 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id j63so174781wmj.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=MyRbhT6cWo0MY+NTkHm7WtzZ5R2icMPX+X0NaOBAORQ=;
        b=EMcHgUel8tT3C+iDrGY3+f5wL92MM+3z/KB64g8z8BskjSvEV6EI7VhcphPnL89gkG
         kuaDZ2ANeNE6CBwpj0Zt1hBD8LkzCdXNK7NA6bTxopvkIOwrCMauKR3HGStL51wqAU94
         yY2+CNLI83jrI4QOrQIQzbJXQynwnb1g+atA/fYea7jZuqOtDGSVr7Cxyfjgy7mNRd/w
         wAvPZPSk1FHL5QbrljnmLeK32oq7hGYf4DkGerHgPi/liCTnwTWcOm9YiQWDO/UGYEma
         4nXVKfHrQGQt8T/Mg1FbVS8ksJ77ai25gmG2ArT8DBBBoRtAYwPwqWsDkzCdACAsQDF8
         EaLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXxl8vPJbPpJQzIKfHN8IK/C+R2DqromqwxiW3m0WSmwBGfRZ59
	M24PghI2JBZ6R2r5+VJYV+E7dR+JWGxCathx/mjAtcDm3xTuyAk3yavb6ROGglokWIaKbYdDuS3
	yl44GqzguoIlGaT5CJUBf28CHXS+7vykLAYdFyfoVY12WlttC13E+9p03b4MeuZiaLg==
X-Received: by 2002:a7b:cb04:: with SMTP id u4mr29447837wmj.0.1555440634825;
        Tue, 16 Apr 2019 11:50:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNEUjf2qL8as68FPu7NjIfEO1x5ngVKprkAEADK6gpxggg6sRXt6M62+h5hAj5K1zrc9Ic
X-Received: by 2002:a7b:cb04:: with SMTP id u4mr29447786wmj.0.1555440633970;
        Tue, 16 Apr 2019 11:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555440633; cv=none;
        d=google.com; s=arc-20160816;
        b=BwpVoznoIdLywKGlf7xlhHz4wIyg2WEKCM9M7FxJeKHwqPWmWPlVPMbDKRNTYOZQHo
         aKEDlXGMuyYyfh4OpLcyRyFSu3W9Rmi+Y6xY7HuX2/AM3NNo7swY3ftxIcuA7en7ulyH
         RHVDbUm7HalQWMQzTo84PDXtDy8/T/mLkecB0MAkr3iVDKpA9uuKEBDvPNy7hcKzSb+i
         7DDY4xLNMJdBLnBPPdeWxvxPFJYqrAz2H5a7rGxXayMAML28EJaCAsw4pOomd2guu3OH
         EbOQTj43j6G7crcx1MLfJOUvI1+3YKfXx/y4r7VsHasr612GIvL2/3wCEgLD2DmorqhH
         7QnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=MyRbhT6cWo0MY+NTkHm7WtzZ5R2icMPX+X0NaOBAORQ=;
        b=kkaQbkdFj0dgaK5y6CqFUDKZN/ZvfIpL2smhNwo7yi9H9eTi6C4s8M7Aalb4CmThFk
         /gTFxflt5W8B2jZH0gsmfiL4zHL9qsuyyB0Rb9gqxygMNkAIjQepk1JYCngLslFqgn7G
         YrIYw0YsvKiqsLJy8BodXqyVBk3xYsR/pf6QPbIvysO+h3hT72uPoDVro+s3EmSD9RMM
         cAsoFeoDlTNdfpGM0RA6oy40FHS9JypSjWNLD/GejQD76Pgqzj7zZl8i7qsftoUjmEy9
         PHItDb/U8hRcyOkYkRIExfk/pfK5nAtY3qLKE3PfhpZ9MedxlUlYx7TmH9N8vgq/TKsR
         RhuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t17si139789wmi.174.2019.04.16.11.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 11:50:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos.glx-home)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGT9z-0001fF-2f; Tue, 16 Apr 2019 20:50:23 +0200
Date: Tue, 16 Apr 2019 20:50:22 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Vlastimil Babka <vbabka@suse.cz>
cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, luto@kernel.org, 
    jpoimboe@redhat.com, sean.j.christopherson@intel.com, penberg@kernel.org, 
    rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: remove store_stackinfo()
In-Reply-To: <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
Message-ID: <alpine.DEB.2.21.1904162040570.1780@nanos.tec.linutronix.de>
References: <20190416142258.18694-1-cai@lca.pw> <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019, Vlastimil Babka wrote:

> On 4/16/19 4:22 PM, Qian Cai wrote:
> > store_stackinfo() does not seem used in actual SLAB debugging.
> > Potentially, it could be added to check_poison_obj() to provide more
> > information, but this seems like an overkill due to the declining
> > popularity of the SLAB, so just remove it instead.
> > 
> > Signed-off-by: Qian Cai <cai@lca.pw>
> 
> I've acked Thomas' version already which was narrower, but no objection
> to remove more stuff on top of that. Linus (and I later in another
> thread) already pointed out /proc/slab_allocators. It only takes a look
> at add_caller() there to not regret removing that one.

The issue why I was looking at this was a krobot complaint about the kernel
crashing in that stack store function with my stackguard series applied. It
was broken before the stackguard pages already, it just went unnoticed.

As you explained, nobody is caring about DEBUG_SLAB + DEBUG_PAGEALLOC
anyway, so I'm happy to not care about krobot tripping over it either.

So we have 3 options:

   1) I ignore it and merge the stack guard series w/o it

   2) I can carry the minimal fix or Qian's version in the stackguard
      branch

   3) We ship that minimal fix to Linus right now and then everyone can
      base their stuff on top independently.

#3 is probably the right thing to do.

Thanks,

	tglx

