Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAAFCC43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94B6820665
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="F2LZhLAo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94B6820665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 218528E0002; Thu, 10 Jan 2019 16:59:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C7008E0001; Thu, 10 Jan 2019 16:59:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08EC18E0002; Thu, 10 Jan 2019 16:59:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D31C8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:59:34 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p65-v6so3112965ljb.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:59:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TlBEbWJPRxW5ErqdsgMFn18xJNa8zguibIlrpYIe8GE=;
        b=bdAQrjkFijx/62IUhSJb9rehfwZo7fA188MoyGYO3b+OdhkZ5y8I9LQQKWhRnEqSgQ
         PxaUgAD9MW1Jq+uPAodl/021NJDn9Vqas9+Z0GetIcCCmP0QBlr1clU84mhqQD6rDx6d
         pzi75LLcrIJItabtIAgWuU64bfMvnnRcmKIEM0X0wWHidwy5ZHNKE3nG2CVHLHDmAWdy
         ttyh+AUmsYGZL7Fc3dkPRkRK/HG/LNw0DB7F6AGJ0pjRwquAIOEgPvNCp3ccvQPQDYYN
         bf4BOq7KywUd1IPWZ5/ruIwNj71qJj/qrNILQHOEGfPe9tiF5vDYu7jQx8ruvfEi0nxA
         bcaQ==
X-Gm-Message-State: AJcUukdOo1IyoAfuMePZ95IT/qjxjfSuJrTPHmQZw1HoL0rlgZYpbgo9
	aoNkupHP9eSC2lzt4/iu8neggAzeySmU49Mnm2hJeUtE66oulbrPl2mct/Pp1Ly3Kiuaf37GhHU
	zBH8DYkqfZ2k5NT9KNdanTJSG3dQTU2NcODpshAiDMwxZvalB8PTtXw6SRuaDiIg1AlW7IWGDNM
	UVml41hV3snctSmWQdsevDyhNmU50J4zSfarzQaCNosIW6QGxs1meflOzg46uHjpq5AJ3GDHzaY
	F+FyNBAbzMqI3wW6dd6cVf+Ef3CnyXmL5T8nLN9UcSKO9ZlCzm/fEa3eQdqYSR1ejabUJTjyseK
	93lUGKyf/eIFzdqzAOUcBiIor0T8CjgJfFFUU0YDQZDAy5wh5OQWOAfvmoWFLqVwYi6J75Nrhrn
	0
X-Received: by 2002:a19:c995:: with SMTP id z143mr5859896lff.79.1547157573800;
        Thu, 10 Jan 2019 13:59:33 -0800 (PST)
X-Received: by 2002:a19:c995:: with SMTP id z143mr5859877lff.79.1547157572844;
        Thu, 10 Jan 2019 13:59:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547157572; cv=none;
        d=google.com; s=arc-20160816;
        b=K98tS0hTszBfTe/r6FlCdksrXBIuGO2iOLlPyZsA4do0psaZUs4urMH5hCf4MGFrWt
         TXDxhoi4MK/QIB8GEkoTueCo51JjW5pYVVnZPW69FsdPr9qsfKVoi4fSJxYAfsmGDMlx
         6bs9q7KLd8SQx71yP2w6TbxAf0qfZhgwOIiUzYoxXIxsn92A82RsKSgxRkGIB+1EPTtQ
         HqikPbflIA7c0uFf2ng7Axv0lg8ObqYwRIdHhLEI4z8uHh2Y+4hDCi1igvwXZC0V2/Oa
         klFOTmn6eUfkhekFistjd6R1XaxEs10mZ3HxvExDeV6xlprxQzBKnE9iKqNGEbwmThGK
         p/0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TlBEbWJPRxW5ErqdsgMFn18xJNa8zguibIlrpYIe8GE=;
        b=CYBo4G8+dUoWCZERlqcOP2vfKOYL5JAvv+hkl49B8PDV2bt6fZ2ngkXmfdKjHuqVgI
         DFOM/56B3KAgazl0xuCqHh4jP3w/cCm46kQ0zpvcyIz3lIBGXhvyFgAtZju1F6174Xl6
         pm/5TrUTYR+i+CHkBl2GQv2zzy+JnqqgsZajea3nobWvnpFVlitpBNnjZsqlcDQve707
         r9aGLSGY9V/3uJIeo41haM9OaSvYy2y8/m5viomTpmnReDYncCQAf4xkKLYO27nCoOPc
         G+I7Ale6Qnq9WCeWuCS01z0DF5nLDTdxTVmvqIDrgDAocylpmhakEfwRj9gvBKzwoleC
         CHBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F2LZhLAo;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor44512306lji.26.2019.01.10.13.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:59:32 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=F2LZhLAo;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TlBEbWJPRxW5ErqdsgMFn18xJNa8zguibIlrpYIe8GE=;
        b=F2LZhLAoZnai3Q/v7fqXciTy8NtdW1LrmXu1KcpK9bQSVTukW+I9Mw0wK2XcWeA9e+
         RVI6eeeDM1+p8dJs4yLa7J8+GdgociTJLV6U/KCmP4VUU9Vq83aqthiREo2n7NIy8u6k
         T8BgPlRn/3ksKc7fBjzS7SBQFWfgmrHc8MZTM=
X-Google-Smtp-Source: ALg8bN4uaG7/8AzVbjJn/7KfbRQGxDgAUo5Kqoi4NAbRiaYFijhkMcRggcnkD32bSz9adCC7peEd8g==
X-Received: by 2002:a2e:a202:: with SMTP id h2-v6mr6991683ljm.72.1547157571908;
        Thu, 10 Jan 2019 13:59:31 -0800 (PST)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id q10-v6sm11799894ljj.3.2019.01.10.13.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:59:28 -0800 (PST)
Received: by mail-lj1-f169.google.com with SMTP id s5-v6so11085803ljd.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:59:28 -0800 (PST)
X-Received: by 2002:a2e:310a:: with SMTP id x10-v6mr7603918ljx.6.1547157568146;
 Thu, 10 Jan 2019 13:59:28 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
 <20190110144711.GV6310@bombadil.infradead.org> <20190110214427.GK27534@dastard>
In-Reply-To: <20190110214427.GK27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 13:59:12 -0800
X-Gmail-Original-Message-ID: <CAHk-=wheEc=K19yJjr4_rkNVxVmyxmbeOoDpwiuNUHZsR-BFBw@mail.gmail.com>
Message-ID:
 <CAHk-=wheEc=K19yJjr4_rkNVxVmyxmbeOoDpwiuNUHZsR-BFBw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andy Lutomirski <luto@kernel.org>, Jiri Kosina <jikos@kernel.org>, 
	Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110215912.eKb13Il2qG15163Vma7Dy1MFBoUjC75sQXCyjhTM3Ms@z>

On Thu, Jan 10, 2019 at 1:44 PM Dave Chinner <david@fromorbit.com> wrote:
>
> GUP does page fault on user buffer which is a mmapped region of same
> file. page fault sets up for buffered IO, tries to take rwsem for
> write, deadlocks.
>
> Most of the schemes we come up with fall down at this point - you
> can't hold a lock over gup that is also used in the buffered IO
> path. That's why XFS (and now ext4) have the IOLOCK and MMAPLOCK
> for truncation serialisation - we can't lock out both read()/write()
> and mmap IO paths with the same lock...

Side note: a somewhat similar version of is true even in the absence
of GUP and dio, for the case of doing a mmap of a file, and then
reading or writing from the mapped region into the file itself.

There are "interesting" locking scenarios wrt just holding the page
locked, and trying to then fill that page with information with just a
regular "copy_from_user()".

Page fault -> try to read the file -> oops, the page we're trying to
read from is locked because we're trying to write to it.

So we have that odd dance in generic_perform_write() which does

 - touch the first user byte without holding any lock

 - do write_begin() (which gets the page lock)

 - copy from user space using the "atomic" copy (which just gives up on fault)

 - if nothing got copied, go back and try again with a smaller copy
that can't cross a page. We might have raced with pageout.

It might be possible to do something similar for direct IO, although
simpler: just do the GUP entirely atomically (and in the fault case
just fall back to non-direct IO).

            Linus

