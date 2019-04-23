Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D642CC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94556218DA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:20:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="U0ZAOGTH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94556218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36B16B0007; Tue, 23 Apr 2019 12:20:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE41C6B0008; Tue, 23 Apr 2019 12:20:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 986356B000A; Tue, 23 Apr 2019 12:20:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA6D6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:20:11 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id s19so2476860ljg.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:20:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9lZI3PImqx3T4CK/0DFoAjfnTtOk7dOVBphM/XkSKVI=;
        b=K6JlDByFlPDoQXMl8vwGz6tAleeim/fIYivRjQaFWGXh+f8FWWL2CyPod0cBWk7qxF
         YPMoRKn9gItoDFfBF1MuQN+1MMpSvRF23/VaGggy6j6PFqpIIUzPqM5XI77j1YFpZllw
         CZqnLsF6MmZT5mXFF01x5cphGiG2lEhg3P/Pek6TOe6dCltegAaAwV+DRtVLgusboAaa
         Zmfe1yqxL+pDcuxXIXSuaJLyIF4Xm8r5xfx2gfB2IlBA7izviVd3Xs9ud5erVf4dWJkX
         z15t96fhTvyCxiClMZnZ+71iIEWcq10kfpbKoaMpSMq2J2eIAzlDEBW0exBXIaAmaJwt
         H+PQ==
X-Gm-Message-State: APjAAAVyUMKWZcJNN/dTZcERN/HWcosjsNQ0SMw4ja7fttgu+Z7uAgZJ
	HDyEcEVvqYRmImAdjknA/JHvwyrx5qnxwfYl4Lqnxu3b+85LwTNPOmI9cg2rVgXvRmGDdOk7Hjj
	nQwAYqeNyu3g5I0ALyfNkNyu1MckvaYQ7foIk3wQUvgJMJj9wnXw+4tVSg+N+7aPn3A==
X-Received: by 2002:a19:f50f:: with SMTP id j15mr14837535lfb.135.1556036410287;
        Tue, 23 Apr 2019 09:20:10 -0700 (PDT)
X-Received: by 2002:a19:f50f:: with SMTP id j15mr14837478lfb.135.1556036409430;
        Tue, 23 Apr 2019 09:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556036409; cv=none;
        d=google.com; s=arc-20160816;
        b=uKd1fxMKHm4s++9w+4GjJZeBLAF39Z7oHDG/Kbu0L9GzxZvPKkxZt8373cG3sBBsWq
         7IsQbd4tTm/V3vfTC9HeOSBYYaUbplH8JeQETBLbCUmbm6CuLVEtE3bOThQ9GLzT3v3A
         ihBNip7loDF8JGCKk+x9kkdXLLwknWSOHrchNrFeNwoPEFpUDMgzILg0pJKLoxcusRtc
         ArxIe/QGf7xpX+9kqVZa4zRQed7SSaeJ0iufFanAslr19t+Bo5fjDP7fVGXrp3eAr8q3
         tMk8QDo/hiIKi/3LKQzoFmqp5pQvmwyr9YWkfK+MQw25lZpfloVHrrm7v7eu8jaujOid
         QBFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9lZI3PImqx3T4CK/0DFoAjfnTtOk7dOVBphM/XkSKVI=;
        b=MYViJIjw6ER0a4KCbZKEkLQrFRxLnGZmV1/gsfzi1HSHya0LpiI49Xuhd5+lCmNJKa
         wz5aLKpGBU9XgxP2/lQo7JxMTdN7fnAuTbF1hGA2za26lcJuYiPfYoF3FVwf0lhTmOwh
         HsAxglvNbiqEg3BTIyjJgHZlasemN/SuU34st6jbV6BrcGh338hVlLfb8xbRL5z59kJd
         jGQQO6Fp1O+6EczD90zt/QzLiheTnHUy4fwb94a+aUN149pfPCqVYHi+0SE8+4JrjdYH
         S55SIVw4DDRy6p2AgUKBIXzjHtA5BmhyEBQhmK6OKiflFFs1VRFchXBAKysfIZu5Mt/X
         KJhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=U0ZAOGTH;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t13sor2551249lje.28.2019.04.23.09.20.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 09:20:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=U0ZAOGTH;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9lZI3PImqx3T4CK/0DFoAjfnTtOk7dOVBphM/XkSKVI=;
        b=U0ZAOGTH5UzOQdSVmsRebl4caZMqgVo2nPoPpTPrrdJ2jTA2RW3NvPCtg1KZ42Zvcn
         G1ZGbbk7dpA34xaZlDxhRhMjPICHO6n25H8k2Y6VQo012xfUtNyPqEP4sg7Co05cV8zT
         6xNAONXbiweJJlYFDC8Lw3jO/2/rX7GIsZO6s=
X-Google-Smtp-Source: APXvYqy8z3ISMOUFUIcweVO2oXH/dP5ciAzBJLjV/iC13YrX1VwJRd1NA4q4tvNQObItsnAdIQ7WCQ==
X-Received: by 2002:a2e:2d02:: with SMTP id t2mr12762231ljt.148.1556036408032;
        Tue, 23 Apr 2019 09:20:08 -0700 (PDT)
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com. [209.85.208.175])
        by smtp.gmail.com with ESMTPSA id b20sm3352976lfi.78.2019.04.23.09.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:20:07 -0700 (PDT)
Received: by mail-lj1-f175.google.com with SMTP id v13so1506959ljk.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:20:06 -0700 (PDT)
X-Received: by 2002:a2e:5dd2:: with SMTP id v79mr14738625lje.22.1556036406473;
 Tue, 23 Apr 2019 09:20:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org> <20190423082448.GY11158@hirez.programming.kicks-ass.net>
In-Reply-To: <20190423082448.GY11158@hirez.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 23 Apr 2019 09:19:50 -0700
X-Gmail-Original-Message-ID: <CAHk-=wg_yKXPmkTcHWPsf61BXNLzz9bEUDWboN4QfeHKZsCoXA@mail.gmail.com>
Message-ID: <CAHk-=wg_yKXPmkTcHWPsf61BXNLzz9bEUDWboN4QfeHKZsCoXA@mail.gmail.com>
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
To: Peter Zijlstra <peterz@infradead.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Mark Brown <broonie@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 1:25 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> Now, we could of course allow this symbol, but I found only the below
> was required to make allyesconfig build without issue.
>
> Andy, Linus?

Ack on that patch. Except I think the uaccess.h part should be a
separate commit: I think it goes along with 2a418cf3f5f1
("x86/uaccess: Don't leak the AC flag into __put_user() value
evaluation") we did earlier. I think the logic is the same - it's not
just the _value_ that can have complex calculations, the address can
too (although admittedly that's really not supposed to be common, but
you clearly found one case where a complier misfeature made it happen,
so...).

I also wonder if we should just make "count" be "unsigned long" in
do_{strncpy_from,strnlen}_user() too, since we've already done

        if (unlikely(count <= 0))
                return 0;

in the caller, so it *is* unsigned by then, and we'd not be mixing
signedness when comparing "max/count/res".

                   Linus

