Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FC19C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 15:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFEE8206DF
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 15:56:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ZrdWTpIg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFEE8206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39BB96B0003; Sat,  4 May 2019 11:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34C356B0006; Sat,  4 May 2019 11:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23D106B0007; Sat,  4 May 2019 11:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8A056B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 11:56:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h12so7085794edl.23
        for <linux-mm@kvack.org>; Sat, 04 May 2019 08:56:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=D/xUA4we+CfWIBMstY2ZZGUlR8dNMfA/8aG9kri4RSo=;
        b=RMXnYjqvH47DHRNlCl+yny3VO84Kpew2vH7/F1YTqqSyy3BNhYaY2gErhu7c+/beCb
         rbnAwwMMuwX7pgt6Jj69xadRX4DEsHEkyEgU8OswXo/I4VJKLeh13YgmUEh52DkiOkbE
         nKm2jis0wCG1LG8r+/Nngjv+alwI9PDPy3/F0K5QWnGIbi9PGczl2pmRP3f0xKsD8cRW
         0pSNUiIHmI4rq+UdXVDdFQuKveI32DIKbOygUPuvYU5zXyR/UpswI7fHilyujDKoxiMV
         PJvgaKodw+WOw6EdWGetOKHq83R4MwWqjHf4DNV2PgSVz9Rb2aJ5NKycroQvNfmaF9Vc
         1fQA==
X-Gm-Message-State: APjAAAU8SSM+YP1C3UbCPYH4QdCme54mFhZYQ1lRArXvPOKIFNRNWzrD
	MBWm5xUhBBy3qLydL9yg/M3voiSn23YyuuaLZGNP6Wu7oD+W5qYIa+hcQSyr+xEf7M9GUDorxQ6
	jEeDAvYA6gZMv6kX/FG4wFvZb0DKo8HsV2bzGONATvgWAHsajv5NGrv7lOjrXbqDtJg==
X-Received: by 2002:a17:907:104e:: with SMTP id oy14mr11540944ejb.253.1556985363126;
        Sat, 04 May 2019 08:56:03 -0700 (PDT)
X-Received: by 2002:a17:907:104e:: with SMTP id oy14mr11540893ejb.253.1556985362195;
        Sat, 04 May 2019 08:56:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556985362; cv=none;
        d=google.com; s=arc-20160816;
        b=HswuFRnwdSgEi6eym+v3zfNOgQ+0G+NNM60hvnGkky/2AvAs1cvhGcOjix0HbYz9b4
         9cQO40pNoVKawoe2ko1RyqoIoZzkTejUWo0sf/fw+eoEdvfsLtfQgl1tWHcnLke2Ve4C
         vtWNjg2B52OfQb+PRs9iqpvuJHQN16w/LdDUm4Lyif48mm53qwljwsC4xLGpyqC897v+
         qTxtVt+shQyNP5kkdbR2RuHZUX0oZlHVBqKqAo2vHKTNIEvFiFnvBVf6xac68CpWSfR7
         /s0b70EwC9q/k6O1b6HUusWQwo6jj5+ZXGQdFZty/UNJ5sJ0v8cpZakQA9pZQkGZxx3k
         xUKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=D/xUA4we+CfWIBMstY2ZZGUlR8dNMfA/8aG9kri4RSo=;
        b=t5IrJ9fM750DO9RrsAHUXb9+Bd4TNHqcKThTdaEcP49z4t1Ke99yBZHL7SlYtE+r03
         C725ssb5hCxsT9XX3by4ANOmMzPtYuE7Sq0VkeEXPgqu9TT4c1PsPRTv/qqZSwBdhxhu
         93CChvz2oFuCW1PnTr6og0P2chhvF5KnWKRst64X4GiUokdRib/BX9OiYP3py1kOY1MQ
         HMHgOjfsLUnAtAMHiW32aDuwz7ismHBY2vYeZaBbtNmGp3Xe+TyVKWiX4ACtfMz/sNvC
         j5fmf/h93Bx0+YNRQxG8aXtMh4MNZp0WY9Vjq1BfRSMI349rsfn55nhRmA9SEE/FEHp3
         xAyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZrdWTpIg;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor115595eje.40.2019.05.04.08.56.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 May 2019 08:56:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZrdWTpIg;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=D/xUA4we+CfWIBMstY2ZZGUlR8dNMfA/8aG9kri4RSo=;
        b=ZrdWTpIgvvrF424jIp+wrwRFjns9Vws1VhvhVyeQLQ8yUB0K/RtorMBF6hIJ8qdZr/
         EMNY9XodjCnuUSks5vvIic5f25dogm0UqOVLHW1qPGEa5AIPjIUxhdJ6vyyG+zQwjSVb
         Es6EOhcjogmP+jv9TmQXzop3fT6A5kIYR4QdSUVCyYBPBKteqVQv+Mr+7uyZmdwuPuLX
         0XuWwnIzEw5utfKyj4eEzEOCUe+bSQvYbR0zp66AsLiLTgD/1mSrqF+0Fi72jzDJxuSU
         jUBy/A5BIp4B5w1mm3m2TYLN7uiDehFBdz/RSQ6Qku4HP2JVpf746kbtSaqqIkqt/mKN
         QUJA==
X-Google-Smtp-Source: APXvYqwL1+OT6I7xDELCdfNz+oPiiC/N2OEv5oobeObUVGp+lISzqLMPEiMy5oB5eqPGvxPFUEwyNJ8Pi/qnMyQIUAw=
X-Received: by 2002:a17:906:3fca:: with SMTP id k10mr11517604ejj.126.1556985361722;
 Sat, 04 May 2019 08:56:01 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com> <CAPcyv4hAh-Joe3Pt0r5CPSaWpZ4YoNF2jNDcvbMF2fsQm7Hetg@mail.gmail.com>
In-Reply-To: <CAPcyv4hAh-Joe3Pt0r5CPSaWpZ4YoNF2jNDcvbMF2fsQm7Hetg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 4 May 2019 11:55:50 -0400
Message-ID: <CA+CK2bCVAuYFFee+P09H_5fN4w2BHXUS1ZeSVN7hxcCTwgobqA@mail.gmail.com>
Subject: Re: [PATCH v6 01/12] mm/sparsemem: Introduce struct mem_section_usage
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > I'm ok with it being 16M for now unless it causes a problem in
> > practice, i.e. something like the minimum hardware mapping alignment
> > for physical memory being less than 16M.
>
> On second thought, arbitrary differences across architectures is a bit
> sad. The most common nvdimm namespace alignment granularity is
> PMD_SIZE, so perhaps the default sub-section size should try to match
> that default.

I think that even if you keep it 16M for now, at very least you should
make the map_active bitmap scalable so it will be possible to change
as required later without revisiting all functions that use it. Making
it a static array won't slowdown x86, as it will be still a single
64-bit word on x86.

Pasha

