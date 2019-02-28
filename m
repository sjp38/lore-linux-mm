Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA47BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93DC12171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:31:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TPOF70l+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93DC12171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 344EF8E0005; Thu, 28 Feb 2019 04:31:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F3CE8E0001; Thu, 28 Feb 2019 04:31:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 196848E0005; Thu, 28 Feb 2019 04:31:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB5E68E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:31:14 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id k198so14520868pgc.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:31:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=d4QzZuqdocoX3Wsls3v18nsgWJU2PE88zazs86EGUbs=;
        b=fGseBbtq8jTYrWa+cKK4pczo7gp18anzlk/CYcOe1ILykmYZS+Mwq/hw3sU/2NIDXU
         V+lfxmeYD68HcYZ2FaLHp1GJ1sx2QgIG0veJ4Z1vr1bYurqu36XWXOFljRnRIBwvrNcB
         42SgYIk7H5j7uv5H7YBCZzckrCNu2bizpHGG1qUI8z5VuMK5KS42dT37SdRdFn/PDQwH
         s1Hba+IYYwXipKmTq1cOOZJU1KrU4Y6Ubb4q8w/WrkmSVtVN9aVDz6waais2SlR/C/E0
         NyNdGofHMrAwemLXDhhil4JqzSyX8vEFYaCorccTiB6fvgRwUJsMAlqFqFIXt+J015fB
         +sVg==
X-Gm-Message-State: AHQUAuZCqZqDdRigdiZsxCsX3ukUiG2Vyjhf8zEWh9inRUkRQo0xR2lq
	UyZ7e7lSK3JQ3MHH9gbiCy0fgyUWozHmNi2fG3ts0plroNozhlL+BOBP7LXINKq/cEsggZFXigx
	XVp1evfxHJq04XQfIf0gKjAFsHeXu5ZWQxD2RDHMS4cj+BeTxnA6uSeXpy8CojUF4uZzuc+gkz0
	ZsEPXOn1pQKWjzjkL/+nwArR0pxhGmjFUiCiX0f2j89fK1aZYgd/9UBRt1yofoxJzUn7PzFnGO8
	xPfFaevezLegdPotg0OhpWmG6gkKZX8fzB8WULdjBnsgzRvYO4B2DniLhavSVHmSIiItvHFv8g3
	dGjBeT3Hbx0XUL9GhKzwroTAaAFIym8IkaAPItE9CQS6AG09F78++N68mgZysW6VHOqwlLx9EFx
	4
X-Received: by 2002:a62:11c6:: with SMTP id 67mr6421976pfr.68.1551346274199;
        Thu, 28 Feb 2019 01:31:14 -0800 (PST)
X-Received: by 2002:a62:11c6:: with SMTP id 67mr6421918pfr.68.1551346273284;
        Thu, 28 Feb 2019 01:31:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346273; cv=none;
        d=google.com; s=arc-20160816;
        b=yxfEnqLWv531h9K2pIXs9ONA0HUEE2NxWorary7y1jjOHI+ErK0/EGFvmO5y5Rt04K
         finOgnMla/XcLyXI1NXts8o8PEsIYMH8LKN8LJbUd+6/RMv4ADV3SHsXbwFxucdnoEm2
         JXniCtuRNxotmR0KqvR+oOSE5RlduQ281gxrTH9uoQQI3MNd/C+19BIZBhmnoU27jzwk
         22GMVsoOrefEJXq9P5+6rCcMI3dl37qQJ7OJVAIFILk/7t4XjO6b2dCzWKDoF9K8nf3k
         jujdEqgeUql6uvj0HXO6UHYIIhrmBOT6hpL3sttenpJbCJSrlI52cIKormESaoqrwEXc
         va0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=d4QzZuqdocoX3Wsls3v18nsgWJU2PE88zazs86EGUbs=;
        b=WSomcWdjA0+n5QXRJiNp0MPAG0XmAeIROnGTTdJSluNPVvbaHSxntgsgl/Wtb1xXkn
         EYrSsw4Uwm5GeoibqXtedp9zuRLrMEHXL/4dFwzTOGQ3GCcuGBVParxp9/AqietjA73J
         o7t+5aoGwknao1Ae9SMmIxgSvvNZ8ajH93FdwjqptBwK6wppduj09edmK/2cfpujea+5
         S15A+W7HqvqOyFqDO2BGPVz6sp1QDFUF95vOp9zz4qvrHE+9+PK/1DOqTCQrwf58wbIu
         M8YI9o89iswFN27vlzb7CE1yiik0L+lKpzGJMvqzMKZmzfDlPBMD6jfFKT2Iyrz0gqie
         6XGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TPOF70l+;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n66sor29872457pfb.61.2019.02.28.01.31.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 01:31:13 -0800 (PST)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TPOF70l+;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=d4QzZuqdocoX3Wsls3v18nsgWJU2PE88zazs86EGUbs=;
        b=TPOF70l+VhlHudre+pcQnY8sYceq3rKVBKAposUJ0dyLEf8d/Vyig8Oht0V3WyzSnU
         1XwDjdPCf7ICz8Ev63ZAd1IvS/z32Spwl+z9maxCJoCycdDD/wmGYQQdOrH6EF/8d1+0
         EdE3GtgrHo/dBV+VolGXvxlN6GQAlUkRSvsGJR/dU1k5fzVqJuPf/HaWu2zpsjaDG08P
         CVkwH1GqldnZCbDfKHZznxaPmRR+hbsTdmyDFPAocEFeFkyd9JlVX/9A/8hRfCHx//5m
         ZfYnNIFHeCGK9HygoMiSinPbFnZyM0Q1pn2OzeicdAnLjggSxy+Wu9Xu7a0tillrwpxx
         +hOQ==
X-Google-Smtp-Source: AHgI3IbwRzOIPDEoBfrgEf9CVvrRjcMb9acSZe/cOgNcEqmht12pnl1+M+snypll7vIJQWt1J+721Q==
X-Received: by 2002:a62:e005:: with SMTP id f5mr6653575pfh.64.1551346272915;
        Thu, 28 Feb 2019 01:31:12 -0800 (PST)
Received: from localhost (60-240-164-4.tpgi.com.au. [60.240.164.4])
        by smtp.gmail.com with ESMTPSA id c130sm30343174pfb.145.2019.02.28.01.31.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 01:31:07 -0800 (PST)
Date: Thu, 28 Feb 2019 19:31:01 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: Truncate regression due to commit 69b6c1319b6
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de
References: <20190226165628.GB24711@quack2.suse.cz>
	<20190226172744.GH11592@bombadil.infradead.org>
	<1551246328.xx85zsmomm.astroid@bobo.none>
	<20190227123548.GK11592@bombadil.infradead.org>
In-Reply-To: <20190227123548.GK11592@bombadil.infradead.org>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1551345851.d2dh3qfxpd.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox's on February 27, 2019 10:35 pm:
> On Wed, Feb 27, 2019 at 04:03:25PM +1000, Nicholas Piggin wrote:
>> Matthew Wilcox's on February 27, 2019 3:27 am:
>> > 2. The setup overhead of the XA_STATE might be a problem.
>> > If so, we can do some batching in order to improve things.
>> > I suspect your test is calling __clear_shadow_entry through the
>> > truncate_exceptional_pvec_entries() path, which is already a batch.
>> > Maybe something like patch [1] at the end of this mail.
>>=20
>> One nasty thing about the XA_STATE stack object as opposed to just
>> passing the parameters (in the same order) down to children is that=20
>> you get the same memory accessed nearby, but in different ways
>> (different base register, offset, addressing mode etc). Which can
>> reduce effectiveness of memory disambiguation prediction, at least
>> in cold predictor case.
>=20
> That is nasty.  At the C level, it's a really attractive pattern.
> Shame it doesn't work out so well on hardware.  I wouldn't mind
> turning shift/sibs/offset into a manually-extracted unsigned long
> if that'll help with the addressing mode mispredictions?

If you can get it to pass in registers by value. Some shifts or
masks should be ~zero cost by comparison.

>=20
>> I've seen (on some POWER CPUs at least) flushes due to aliasing
>> access in some of these xarray call chains, although no idea if
>> that actually makes a noticable difference in microbenchmark like
>> this.
>>=20
>> But it's not the greatest pattern to use for passing to low level
>> performance critical functions :( Ideally the compiler could just
>> do a big LTO pass right at the end and unwind it all back into
>> registers and fix everything, but that will never happen.
>=20
> I wonder if we could get the compiler people to introduce a structure
> attribute telling the compiler to pass this whole thing back-and-forth in
> registers ... 6 registers is a lot to ask the compiler to reserve though.
>=20

Yeah I don't have a good idea, I think it may be a fundamentally hard
problem for hardware, and it's very difficult for compiler. But yeah
some special option for non-standard calling convention might be
interesting.

Thanks,
Nick
=

