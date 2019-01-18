Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8098FC43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 04:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B5822086D
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 04:55:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="TAG5o0xZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B5822086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8C7F8E0003; Thu, 17 Jan 2019 23:55:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C14948E0002; Thu, 17 Jan 2019 23:55:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2A6C8E0003; Thu, 17 Jan 2019 23:55:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43C418E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 23:55:15 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k16-v6so2924265lji.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:55:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XLyFz/NJZgEoOZrZ2eJV4Pp3mn+Ctdtd9w409+4P7/w=;
        b=oXrjYbdaJq7T7vSYt0SeahvIRMdqdxcoah2fE+67DAdsff2fvyOWicxGmSezurL9SB
         JmT9eP9CHK65Kq5WpqxXnPqGAcM1UgLhg+n6vqL4gRT5JNGeY876k5kZtIlowVwnwEXl
         Ax3kREkxfQpwOXG8UzP7KBetqFYzAXW5ll0tTfAW521pp4KQx+LJONWODhCFdy9sw1Ah
         dnvNpvKBL4kSY3NLx6QyHnKMHmj3Z9ySl8F01R4a7oepI+i0d2CK1xXAt7Eax77OqhrY
         sD+PQspT7oU43MxNNiyxq3Uwae3MUuNP+pb1wgoEZWJ4t9ARyTP15yW2xzWbkvyl9Np5
         cFgw==
X-Gm-Message-State: AJcUukcC8+RbTpDikEOUWdBQ18jMwge+zbjRTwPhJhZKMMIBcRmsYd2S
	v3rQOq/NNPsAyYAZ/aAvUwwf63hRN0pcfDguHlFoahXp67hSKoziB0nd4lkUnB0Yzmn/98nyzON
	gWXw3b0QAiLAJr3R81SeR9FvQ6aA+/1Eg7QWwOAXHdhnJ+OOaAADT0jr1yCwrxCGJ6J+qqDgaoz
	P6MN0TwVA4JYEHHVwWkVptS68+bF7Yhnvn5kEBOBCPeSJI0SPBM/b/9MEjzi//e42M8YN9HVlZX
	zLJ8JjGEFONv8PHe1ij51GEgt0TGIe1Nx3zIzUrWvUo0BBKcXeL+/wLPFB/G7hrPd6Z1bNWADJn
	a55oRa8B6rUaPmyzeJCA4vhTw0jwG1OGuMU7Tcku5vfVqwrvsYuK1gMSIwKtXMS1Xa1Y+mXGq23
	M
X-Received: by 2002:a19:a40f:: with SMTP id q15mr11319383lfc.4.1547787314687;
        Thu, 17 Jan 2019 20:55:14 -0800 (PST)
X-Received: by 2002:a19:a40f:: with SMTP id q15mr11319357lfc.4.1547787313279;
        Thu, 17 Jan 2019 20:55:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547787313; cv=none;
        d=google.com; s=arc-20160816;
        b=q0BcLpQPlB69Zn+fzSCuwJldDqoKOrncblw3+QT90Odn3t3W1Iw1OhDF1ax1/Xaa2a
         L/c53qiZIvNd1/NDXQC4VNYOrzhbpw6iaVw7y/c7egS63lZRABcug2NxJnMtJjJgQCYc
         hm+TUeMDrDFY+7cuAwdATUXSbYgHmm8b229Bcs+Msludq0TQKwLasdOk1AuI2fj9MB7U
         VkkEMVGs4nF4EHa7KU1JH608WjbHH+tEYoAKeiQ7bHJPUM5Syt9LSd11FrXcK8gSvqB5
         ybmFuSWCRX43GIGrTx0sG2ePPdHuvzH21RqFdEDbLMQx8tpQsOzSyRRvQmLgJKUsPAYQ
         Cr9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XLyFz/NJZgEoOZrZ2eJV4Pp3mn+Ctdtd9w409+4P7/w=;
        b=uO77umLR/KLP1gXa1eaqJ3Mb3X6RqFEBKxxTONk16hKZmB3Yg9grNKndxGuv/OcT9c
         3+Bu1LIe0vYjd61tZuYeeO0JWS9wDSJ+ZFymhGpWOIA3mnDywohbD6+sb2mTB14o2JsF
         g9TKXoOhGUq71QrMHElS5UTeBUFe2Gkrd5ak+pQ7whRfYByZNHEV1yCKUI+uESb7fT0M
         PbQfN941AInLeq+kdz2sWite0UGB26DctUGNOTVpD7UvkIVXOW5MvQt4S4+d5iQGsn/i
         tOt7mOMawvHjQMWn1fHQJhTpP5N8i8EeUn/qST+VlXbJwBJQHXgF38Px/RDHBduQjN3E
         vNpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=TAG5o0xZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor1131078lfc.35.2019.01.17.20.55.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 20:55:13 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=TAG5o0xZ;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XLyFz/NJZgEoOZrZ2eJV4Pp3mn+Ctdtd9w409+4P7/w=;
        b=TAG5o0xZtljWmnIHysbz45KQ7BDCtWjH7oSSuTR+4rp7IloXFuWN64OzjwO9g3M932
         sV0vlIJjAPfriDu66S9TRVu7irEbS5njMc5vCW3OHJdctjaAIqba392tFmtTx78fLJ86
         qgUbCJUPuKNG5XdI5ww/WGlqXQZ2cfDACqWcc=
X-Google-Smtp-Source: ALg8bN5HNGE48FzAgID1lC5dhjmJHeeL/0yvHvdG6vP2MRuuS/SSfrAFudTXxfKDdGIALdeYuS6nMg==
X-Received: by 2002:a19:1cd3:: with SMTP id c202mr12169847lfc.33.1547787312748;
        Thu, 17 Jan 2019 20:55:12 -0800 (PST)
Received: from mail-lf1-f52.google.com (mail-lf1-f52.google.com. [209.85.167.52])
        by smtp.gmail.com with ESMTPSA id x24-v6sm590976ljc.54.2019.01.17.20.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 20:55:12 -0800 (PST)
Received: by mail-lf1-f52.google.com with SMTP id z13so9518708lfe.11
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:55:12 -0800 (PST)
X-Received: by 2002:a19:982:: with SMTP id 124mr11265403lfj.138.1547787311695;
 Thu, 17 Jan 2019 20:55:11 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <20190116213708.GN6310@bombadil.infradead.org>
 <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
In-Reply-To: <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Jan 2019 16:54:54 +1200
X-Gmail-Original-Message-ID: <CAHk-=wg_MZgBvbH3cC9DT5MD694=SYO3+ns_2VnaiyV93vDMRQ@mail.gmail.com>
Message-ID:
 <CAHk-=wg_MZgBvbH3cC9DT5MD694=SYO3+ns_2VnaiyV93vDMRQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Matthew Wilcox <willy@infradead.org>
Cc: Jiri Kosina <jikos@kernel.org>, Dominique Martinet <asmadeus@codewreck.org>, 
	Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
	Dave Chinner <david@fromorbit.com>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118045454.bisbK-2ApVULp3GCYG55MMeJrVoqrmuojSZLbKs_eG0@z>

On Thu, Jan 17, 2019 at 4:51 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Thu, Jan 17, 2019 at 9:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Your patch 3/3 just removes the test.  Am I right in thinking that it
> > doesn't need to be *moved* because the existing test after !PageUptodate
> > catches it?
>
> That's the _hope_.
>
> That's the simplest patch I can come up with as a potential solution.
> But it's possible that there's some nasty performance regression
> because somebody really relies on not even triggering read-ahead, and
> we might need to do some totally different thing.

Oh, and somebody should probably check that there isn't some simple
way to just avoid that readahead code entirely.

In particular, right now we skip readahead for at least these cases:

        /* no read-ahead */
        if (!ra->ra_pages)
                return;

        if (blk_cgroup_congested())
                return;

and I don't think we need to worry about the cgroup congestion case -
if the attack has to also congest its cgroup with IO, I think they
have bigger problems.

And I think 'ra_pages' can be zero only in the presence of IO errors,
but I might be wrong. It would be good if somebody double-checks that.

               Linus

