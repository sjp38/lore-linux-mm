Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C840C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 17:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1DB120881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 17:54:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="cfYVpzfF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1DB120881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6149C8E0002; Thu, 31 Jan 2019 12:54:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C52E8E0001; Thu, 31 Jan 2019 12:54:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B4FF8E0002; Thu, 31 Jan 2019 12:54:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFACC8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 12:54:36 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id p86-v6so696904lja.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:54:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+/WNqBHx6t0a72y8JdVi8XzoM/zCOUk1EICcdBncvRA=;
        b=Gy3V8UEcAOkRUVSiCGioxf5EhvPLUrCjuCGB/rtRkEAucWZxC8w5sEI4LaA3PvLnqu
         11nOFXkqEySOkxN0+vhqKnHUlnlgXPyuVHxafV/pNN6xgK/E7CevA1PC6/ey7xXy4M1/
         +Hk36nacoJTdib8WgJ/GCbYqfoc66I2SxCRWEFdXD7TLLnftsP6lufUkLcQ/CeRg243E
         p7xsuCZSFwcnxntTaKw8yJPpGWRmhlVXAjgoukc7pF6kjEQ57TVXcNcusVxgL6OFybtD
         UfDZ44zL7oAwIPOJJlIi8njw/Mi4xvlyAoHLtVSvCbELvTamH07oZrJwfD1iWXZtMZow
         Gwxw==
X-Gm-Message-State: AHQUAuZUlxMPmmovKXmo4xZOfXJM7nBKbzrLp0UNygJE/JkClUxesYJS
	bM3HjdNxH62PSW+VMm6T2Lkd9SlaVw20lYhLToZOvJ4sjFTQ3ds9rOv2RoT3/+GR4gnCtFH5P5q
	kVQN0kRDjpaiuyIGJX2g1vyG0GEkEWhnmvhzHZdlW7SeI2kWAbFvla8RpmHYhr3zGyG0enPXbfo
	+gSTtI6/1M5vY5217vCvue9C3wn5NsESVyxhVkJoP5vby8Ef8sVXICihoxVzeUDjObYHtLFdIb9
	nUKXZrBsViadNjR69F8k8llT4QtxclVQlCC89oMZ3bcx843DmeRR2OpFs0YoLxJG79hqPs1Jbnw
	y5OAo4TVH98zciEHIsYsqodwV6uUk2THaGh33jYzGiNqX0971OIlN/8xOIx1yyYHqmHr+hDJQ7f
	0
X-Received: by 2002:a19:ae12:: with SMTP id f18mr2262707lfc.155.1548957276162;
        Thu, 31 Jan 2019 09:54:36 -0800 (PST)
X-Received: by 2002:a19:ae12:: with SMTP id f18mr2262661lfc.155.1548957275052;
        Thu, 31 Jan 2019 09:54:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548957275; cv=none;
        d=google.com; s=arc-20160816;
        b=bnntsyYhcyGomEmmXgkJN8ay3w1hbJA7QK8ORnO3RaSDxQ/9XYi+Rmyp3IaSZJJ8Iw
         iL7jtuM4WoJJFo0L/Gt3qXOVAERfIjX5FE6dMXLZFuU2GricPa3lxr2SinF0N87fNpF/
         QD2gzXjLPsKhX1oZR/FlSpTENsjIxF7RqJfVkKMfVLCn6LB1CBDsNuSEnPa8ZIlO3/M8
         nC/PQpW1jBAqwf7/fCrNTVTbk+0tXW567FR6c7AVfBDs9SZtsTngk7dzxa2O92inuxxx
         4gJ9Zd/o4GVmTHWQg4xu7tatHHiFjnGxI+mC9s7p49piLK752RmLx/E+s9ey7xAuw3JJ
         GSNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+/WNqBHx6t0a72y8JdVi8XzoM/zCOUk1EICcdBncvRA=;
        b=QV5W9A2PFfpFGlemUfhH7qONIfUbuRvm8kVqLyC8nPl6kZq05nV6ow8gZadlVZeL1o
         Li9O6mnMY0FPr1s1V2tEqtM1hKXGCVWVL8yanCxQHaPTG2LDanyd1t0YaX+I0vERNfs1
         L+9OZ7pQV/4lOd4+kVN0HGcw6NFg5LdMH/f7F5Ii9wH1uqgc1V5c8gtor47A6EdT9GLX
         uPzEzsgbXnJPcy+cTMN0oS0sHbdMa1wF6ZjjCopeC0OhGJ52ZajpPo3+emmlMwNLUnrI
         baf2+79TgMABNutJK7MSn0f648MtSAxNrp7nSPOkq4W61OYRH2nFznpO0IFFvxU4jPVP
         NAIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=cfYVpzfF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a25sor1689238lfc.21.2019.01.31.09.54.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 09:54:35 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=cfYVpzfF;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+/WNqBHx6t0a72y8JdVi8XzoM/zCOUk1EICcdBncvRA=;
        b=cfYVpzfF0BxeHbpmKTdtGzAEB++lXqSbRRBs/Mg7UrvWqhXLJQH+FkTiYQe0w2vdL6
         h+bs4UA2X9lTfD/JhRPt4W6/luECWOyqyTerzsu6KhEAfexcIeF33M8b5v6vrPX0DkBd
         ZOf//JDvJCzdvZkr/rTXN7MxegBSBgRnzMxFk=
X-Google-Smtp-Source: ALg8bN4nBW8MpqDLvd9swJQBALf7ldA8xLn92f5znWdiTZF+fx6GMDCnQ+Z0EZP7QQIapVMP3X2oQA==
X-Received: by 2002:a19:4e59:: with SMTP id c86mr29648118lfb.132.1548957274049;
        Thu, 31 Jan 2019 09:54:34 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id l7sm379709lfc.55.2019.01.31.09.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 09:54:33 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id v5so3007286lfe.7
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:54:32 -0800 (PST)
X-Received: by 2002:a19:ef15:: with SMTP id n21mr28224071lfh.21.1548957272169;
 Thu, 31 Jan 2019 09:54:32 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz> <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz>
In-Reply-To: <20190131102348.GT18811@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 Jan 2019 09:54:16 -0800
X-Gmail-Original-Message-ID: <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
Message-ID: <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is
 set for the I/O
To: Michal Hocko <mhocko@kernel.org>
Cc: Jiri Kosina <jikos@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux API <linux-api@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
	Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Dave Chinner <david@fromorbit.com>, Kevin Easton <kevin@guarana.org>, 
	Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss <daniel@gruss.cc>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 2:23 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> OK, I guess my question was not precise. What does prevent taking fs
> locks down the path?

IOCB_NOWAIT has never meant that, and will never mean it.

We will never give user space those kinds of guarantees. We do locking
for various reasons. For example, we'll do the mm lock just when
fetching/storing data from/to user space if there's a page fault. Or -
more obviously - we'll also check for - and sleep on - mandatory locks
in rw_verify_area().

There is nothing like "atomic IO" to user space. We simply do not give
those kinds of guarantees. That's even more true when this is a
information leak that we shouldn't expose to user space in the first
place.

                  Linus

