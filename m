Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09747C46470
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 19:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8CFD20863
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 19:25:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QK2w6qXc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8CFD20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 196236B000D; Sun, 26 May 2019 15:25:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 146EF6B000E; Sun, 26 May 2019 15:25:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0351F6B0010; Sun, 26 May 2019 15:25:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAB536B000D
	for <linux-mm@kvack.org>; Sun, 26 May 2019 15:25:48 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id p83so4846585oih.17
        for <linux-mm@kvack.org>; Sun, 26 May 2019 12:25:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=hHbIltnugKcSDkBP0lFOF1T4eFARSdfUL7k351u/Evs=;
        b=sbEhdyjGNqsFnTbh8nmPoygB2twL6xkrqFRykbQq/kTnQwu428M4vpgCLu8E6Al8T/
         8YYbJKO/EI7llSqTOiF2pROTTmmJsafN1Ywhvoy33RmgKAzKLpFqZ5/0rzEiWUhneQv2
         EgrR131Ypn3HOyvbA2L0mt/MeJxpcKTi0PYdCYu3n99RzVm6On+z/5HJCXyfhTH8eaIG
         Rv/sA3X+OC//P5ggBbnO1poDbYCkDrDgibaxeiu9TVdefeFSxpjpUHG2zclCXNRE90aR
         odZ80iQt7V/leYCDuqyNdmUo9T9lkq2zQQwHx1VW9WPaEfEoBRGAsWIrqUQndPq6rPM6
         CVcw==
X-Gm-Message-State: APjAAAX479F3jxWOoBEn/RO6SKdzQJTNVvbZlX4BETeeiOdv1M8t2k9r
	dtia85nQfW82xRLk0/1qaf8pB/gaKHWLsE0P5FIWQIVti91bJ2qGAUp1byLJLFeV2d8zrOGVLIE
	CJvQTwE+jMlS1UH1di+r1GWp659jwInloRdhlDPqpiOg80LVDwqrI3PhLSULcLFUc5Q==
X-Received: by 2002:aca:c794:: with SMTP id x142mr12948852oif.172.1558898748398;
        Sun, 26 May 2019 12:25:48 -0700 (PDT)
X-Received: by 2002:aca:c794:: with SMTP id x142mr12948833oif.172.1558898747658;
        Sun, 26 May 2019 12:25:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558898747; cv=none;
        d=google.com; s=arc-20160816;
        b=JF0nJtcw21PZYGwY4oqzVlP9XAzCRRQdSVEeBn2wiAjQIB6kLyRZ3Mc9UzIFIEtMQC
         Ebfnb0YnpgXnJ4UEs8dxK7j7CHTYfVSAX7sLs+B1R36w9DVvignb0eu0Caj9TRsCFllv
         7iqbSRyqXdqTMemg2dKRbw7Qym3vwyDQAWsjftI+TlJlgJ5gSbxGDktWiUnM84K3R9T2
         AHt6LxgbymEh8kL+GJ5w0NKv7/CuGwA0tphJqOsN5s75nE0xcduZA0UAQScOTAQvzNcQ
         Ke1FuhyvFxTiO7T5jX4jJXpEi3PD9EhEv3WrBiBDZ/64Ap1toH+7qUOsE9weXoYNKQlj
         /jsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=hHbIltnugKcSDkBP0lFOF1T4eFARSdfUL7k351u/Evs=;
        b=kswzAO6QDQ2eX9Z9jn7nhzjotWo4lZShBa36Bisj87kbpGzKi0ATFJS8t9VKo3Ko5Y
         LlRuA8sY2u+Tzpkv6IiMYTsoxuioSydSKoIp6mTQvMV7bKkWc5ZAxnFcg8l8ds/wXsfJ
         HCkOw+bhjmzQNIJIITWxjCURiEaXZ5scurD4P6HNOTqHZ4wj0DQ42qlbTR73kg4qtxkN
         bm0Uh/kGBSu9P6BuEX/P1HwDbx6kZ2T3kUGVOO0MQyKeROGNM5pdUZjNzS6JlPE+vHK1
         GoHGKBE10YmT2puxelMXOe7P0IxqooQ2LOiaYjIOB48tO3hTdeTL8yORLknnTs0HsL4r
         ox8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QK2w6qXc;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor3797770otg.165.2019.05.26.12.25.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 12:25:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QK2w6qXc;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=hHbIltnugKcSDkBP0lFOF1T4eFARSdfUL7k351u/Evs=;
        b=QK2w6qXcjqOvIUgpyQlpPFFjMAx81QOLpKVkdFtld089OLUqJpdi1Yfx3n2vrMdix0
         4bkuis4j8RuyeclsOLtCMzw/vbD1J+8e8S7fOugD1ShLWOnTFJg2shFLzyFJD6l36wux
         dHpEEcI+p4hl92BRM/Hk9Xb79aO2SLOAhVGFd87Yxkm6D9+LiSHad7jrdqQYB21u1nd+
         picqBODCleGqEvYomTllLg2bwr45cB2FKK6grOmMljelrhs/AJqjUt8oipo1j+wyxEYM
         IJn8fqoE8kmmLtjeueQUfNSRybqb8nGF3k8T+sOU3y1AOH5MAOFrFTM6pcjYcwe5eUoE
         HNow==
X-Google-Smtp-Source: APXvYqxVQoWiTR05hJVsUZbOaOESbV3MUJKHQDyMkTGxJ4szy2pu1e8Vna2Lax9Tx2JCqEE05NMJrA==
X-Received: by 2002:a9d:3de6:: with SMTP id l93mr7378609otc.51.1558898746865;
        Sun, 26 May 2019 12:25:46 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id 43sm3340057oth.47.2019.05.26.12.25.44
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 26 May 2019 12:25:45 -0700 (PDT)
Date: Sun, 26 May 2019 12:25:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
cc: Hugh Dickins <hughd@google.com>, x86@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Borislav Petkov <bp@suse.de>, Pavel Machek <pavel@ucw.cz>, 
    Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] x86/fpu: Use fault_in_pages_writeable() for
 pre-faulting
In-Reply-To: <20190526173501.6pdufup45rc2omeo@linutronix.de>
Message-ID: <alpine.LSU.2.11.1905261211400.2004@eggly.anvils>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de> <20190526173501.6pdufup45rc2omeo@linutronix.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-668670725-1558898745=:2004"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-668670725-1558898745=:2004
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 26 May 2019, Sebastian Andrzej Siewior wrote:
> On 2019-05-26 19:33:25 [+0200], To Hugh Dickins wrote:
> From: Hugh Dickins <hughd@google.com>
> =E2=80=A6
> > Signed-off-by: Hugh Dickins <hughd@google.com>
>=20
> Hugh, I took your patch, slapped a signed-off-by line. Please say that
> you are fine with it (or object otherwise).

I'm fine with it, thanks Sebastian. Sorry if I wasted your time by not
giving it my sign-off in the first place, but I was not comfortable to
dabble there without your sign-off too - which it now has. (And thought
you might already have your own version anyway: just provided mine as
illustration, so that we could be sure of exactly what I'd been testing.)

Hugh
--0-668670725-1558898745=:2004--

