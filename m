Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE5D1C43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 04:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A57920851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 04:52:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="C6MlEvjF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A57920851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE4518E0003; Wed, 16 Jan 2019 23:52:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6C278E0002; Wed, 16 Jan 2019 23:52:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5BDE8E0003; Wed, 16 Jan 2019 23:52:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3173D8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 23:52:08 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id y24so986752lfh.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:52:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7yg/fey2gwxJ3j2bGARMVT/eRJirMo8WI+36rgecn44=;
        b=Rf1UqqQ1Um6jdZGVCI6bDuDxdgNJ2vakuNB/G2HEChfwR+sCir9K+RQrtSrHRnw/Zg
         KHXD/W6RMMF8RinvG2Mfe3QuLaUQdlDQkeiFkaCqnyPRBgOasQMZlmtAbrULWJlgqW7q
         ldujFLV3juJ5tiOMAt/avz0k/XyHSD9iTfH4v9YFUUrV28Z8ijWyJvlbF8G5J5BUYAO4
         F1f13BobRc3ABdWWjQZcQaeoupji3Bs0VPnZQJqVe9EJcS4aSdTfQ5a01cC3nFqY0Fo6
         WuXCRVVUB+E9BxpPE0QqaX1wwbixw3hIoviWZqThclSl54b3hGiDbT14zNOQwqXmHTba
         BDbw==
X-Gm-Message-State: AJcUukcrJm5t91KNOaBxOVvzWkqNqbPiZKvnGU6p7UDm7VO2uqweVdaV
	jqviSpWxGH+S0w7m+rcQFjZGqV6FcfnVmIEiHjTuEzj0QQfF22ehtI6/V27wNzdx9TT3X+w3nL5
	2AAuCpeTSj36NZg07eb6I6FGSduuDBXsPDMMJQzozuyfvbe814v1L0+0PKu+5uBO9Yhl1OngrfV
	6xrVIlK3sJuLK8w2UL6zrWDkL69rMPNhVHP8szZDrC3Qg5EtcQMc1mOfbXUKLdW8EuH88KEpZEG
	fTkienz4gL43yMHlyW5jelkZ50RJDyJ+NWEIfbuQIfKpwdJ6hBtc20OxvIr1o7duDWRFu4a4tPd
	zv6CmdTSYlsHbH/eFHyqVh1pGa563E4rUI9vnssbChsutfb89ZGFwDmKwKHGvaCpPiCANqzpWhY
	V
X-Received: by 2002:ac2:55a3:: with SMTP id y3mr8768799lfg.93.1547700727206;
        Wed, 16 Jan 2019 20:52:07 -0800 (PST)
X-Received: by 2002:ac2:55a3:: with SMTP id y3mr8768774lfg.93.1547700725780;
        Wed, 16 Jan 2019 20:52:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547700725; cv=none;
        d=google.com; s=arc-20160816;
        b=hHTPzB36oJiCctosKG4v4y0C3yIoEuONzrvhgNlfXUI/GLtbMNHCPUnhF/pHDbQ/w2
         5MWgeQ0Hw6/3PiqON4/b950JyL6sq/L6DsWokA4JgfAw1DQbyh6Oc1Hm3pQZ+6+R2vec
         hFMN87Vj/+a7RoJ0yhYI6WOPbsjoBFIRLPClutPLjdjbtstk2UcjBMW5Y/zDpLoqq4L3
         15jx/Xu77ojuCzfZXlel1+HZiCZ7K4peDVw5Wbo0X4CjAqom4pEnPWbGQcFIIF8aNKCR
         uwtUxt+TP5wbcVFDX0GdamoGKI0i0jzKRhVC5iL/oCh3WDkwssYjwkFKmu2xTtbytpxF
         MZEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7yg/fey2gwxJ3j2bGARMVT/eRJirMo8WI+36rgecn44=;
        b=IIt8M9xjstAZ0XrGAD+cne1lTIU4feNWQn3PmILmlZ811d1e6SgI5ar+lqWhJdsLae
         +QaODvVeTFDB79TWUpuIPJKLtdtniP6htrgAQ1UIGPcHKOyG/CDBbSV0yQ40eVo4tAZE
         wbRJUSbF10o1tSn23D8tb9CSWGKqKqxuD1FeCfcul+bUtX05sroTWn7fmf744pQClnBA
         +grK1mH+2lY5lcVFtwAO+W2BN/lf0F1dXCLSrdpSctdPvuZc3nG4H9v75yvqolie/buk
         hh/e/E71XPCPevokqgcmaP4gQS1m6HbWzMpOxEKefwMia/xy8pZ1R+cSj3SphX4z58BP
         Badg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=C6MlEvjF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74-v6sor249882lje.7.2019.01.16.20.52.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 20:52:05 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=C6MlEvjF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7yg/fey2gwxJ3j2bGARMVT/eRJirMo8WI+36rgecn44=;
        b=C6MlEvjFBkcWofmUUmP+orz3WZY5+zYliTWZFP0dxTKmc6y20wo/64FLm3lY/8d7uq
         zRUrUISklDIlgc9mcichrGZav7zNAit4hsMlYOxsvg/fQVAkEU+k/3J7nNx7BOUgMqHi
         snOWNxQuPFTwE3YsEekTQj4G0UD1pozuqEmEc=
X-Google-Smtp-Source: ALg8bN7gLDJIXYVIBpzTa9keEpIXk3nSRV/q8/NTkbfjet8XXfus5pYbzMp7ba1d+1mZCONDvDfXZw==
X-Received: by 2002:a2e:21a9:: with SMTP id h41-v6mr8641142lji.103.1547700724710;
        Wed, 16 Jan 2019 20:52:04 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id x11sm83212lfd.81.2019.01.16.20.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 20:52:03 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id g11-v6so7423803ljk.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:52:02 -0800 (PST)
X-Received: by 2002:a2e:3e04:: with SMTP id l4-v6mr8407355lja.148.1547700722094;
 Wed, 16 Jan 2019 20:52:02 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <20190116213708.GN6310@bombadil.infradead.org>
In-Reply-To: <20190116213708.GN6310@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Jan 2019 16:51:44 +1200
X-Gmail-Original-Message-ID: <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
Message-ID:
 <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
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
Message-ID: <20190117045144.__Mq0QqqTO_-Mw_SRgElZHlswg1NA-jQAxad9gw5F78@z>

On Thu, Jan 17, 2019 at 9:37 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> Your patch 3/3 just removes the test.  Am I right in thinking that it
> doesn't need to be *moved* because the existing test after !PageUptodate
> catches it?

That's the _hope_.

That's the simplest patch I can come up with as a potential solution.
But it's possible that there's some nasty performance regression
because somebody really relies on not even triggering read-ahead, and
we might need to do some totally different thing.

So it may be that somebody has a case that really wants something
else, and we'd need to move the RWF_NOWAIT test elsewhere and do
something slightly more complicated. As with the mincore() change,
maybe reality doesn't like the simplest fix...

> Of course, there aren't any tests for RWF_NOWAIT in xfstests.  Are there
> any in LTP?

RWF_NOWAIT is actually _fairly_ new.  It was introduced "only" about
18 months ago and made it into 4.13.

Which makes me hopeful there aren't a lot of people who care deeply.

And starting readahead *may* actually be what a RWF_NOWAIT read user
generally wants, so for all we know it might even improve performance
and/or allow new uses. With the "start readahead but don't wait for
it" semantics, you can have a model where you try to handle all the
requests that can be handled out of cache first (using RWF_NOWAIT) and
then when you've run out of cached cases you clear the RWF_NOWAIT
flag, but now the IO has been started early (and could overlap with
the cached request handling), so then when you actually do a blocking
version, you get much better performance.

So there is an argument that removing that one RWF_NOWAIT case might
actually be a good thing in general, outside of  the "don't allow
probing the cache without changing the state of it" issue.

But that's handwavy and optimistic. Reality is often not as accomodating ;)

                   Linus

