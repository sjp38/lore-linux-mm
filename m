Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA948C43612
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 16:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B407920675
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 16:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B407920675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431D68E0003; Wed, 16 Jan 2019 11:12:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E0338E0002; Wed, 16 Jan 2019 11:12:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2827F8E0003; Wed, 16 Jan 2019 11:12:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9D0F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:12:30 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so4157761pgq.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:12:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=uPRXlDclQzo4Oa6N/pVmeZlRDqbRuhOouJ5A1bsVJZk=;
        b=iNoYNYOjOUTQs+SatNPXNYnDsLtPcOjy5KFkCIJy01CnnBJQdYrM3FNeYY12xYQVEZ
         7ovRh27nepgGwWgyZwIqtVfTGjwjeHWS1qpoBdg7gUl17RovjgE601ULBBfYuwcL4mez
         UEEpGK7oLZU7uTKB+3sFJNO6UrTLKPgjG5y0oU/vvlO45yJ7XNsme1GZz0To9GPOY/Pc
         Fm8v1nhvo51E+db46hv4dPZDBy4QyovSef/MHHmpz3NqfTDin6adpttETsFZ5HlQxb5k
         Kqsnv7VvxEQz3GgO8mblNmiLYlX3bHDRViUiXx2A0OnUXR7ktnjtD0Bb7Z3wlsTOjk/f
         JkEg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuket174QoqWQq03r1D4FLcClOoHmoeVrcvY46RVMIm84SQjKUAIS
	RWTlXnAkrVaKsamfhgyYCPszbx1nQxJFTyylAvVlnmbyRlFlSSA72zAP15fnjr2Y8sVXIRrnQKc
	EDL5WoiaEdpDI03w5peQGdAcgIh4yMfsg3quNFAkzjHpc76wlAmfhEQWewYGH+Ko=
X-Received: by 2002:a17:902:2ec1:: with SMTP id r59mr10746800plb.254.1547655150142;
        Wed, 16 Jan 2019 08:12:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5IDlOi4UO8Dn0zgIwoyL3smt6PubVywDSs4cJu1qUE9JfkXeXd+SFGBR5h1k08ksf/kt8N
X-Received: by 2002:a17:902:2ec1:: with SMTP id r59mr10746702plb.254.1547655149000;
        Wed, 16 Jan 2019 08:12:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547655148; cv=none;
        d=google.com; s=arc-20160816;
        b=dPgM4HZkY3xchfzA+f0HwxsS5tXQ5kwwCqFO16b7ctkL5vffSuNwZfc4cnVTgK3Iy4
         fnMwvI3cOSOj4Y1zN8if7RAWTvdxYcTufh6Pq6LKZmoEWyAMlYkI3jTapRuCLHp6yaMw
         BZ8RZTG/jE/e5tR9XRzH2fjY5ksBORqnKEnPB3UjKIKEfwQRGLBiIKZNkgGFgXex/hH3
         rhHCUJ7452YJdC7KNEnQftXHVM37kYX+pyGACimSDKIQWI2W7qJ0bbTfT/pHa1E8fZ0M
         2boobQ2IBiIZZe0h4iAdPUGbeccg++HVhgkjEnRKbZdnjUVTtCifm5hySqo0iH4edaP9
         z4Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=uPRXlDclQzo4Oa6N/pVmeZlRDqbRuhOouJ5A1bsVJZk=;
        b=SDhVuo0bXsjfaIWaZskBFWfFkhEPBDdZefWivo31eYRw7jPClig+WwQGatHiTf3BCs
         AhzF6lJlzKnD4KoNAhHEcfW8K6ippsMNHvNnvKJQVcbfgtgLJLepiK8zF7oK7iFTkoJV
         baSanAV6Z8U/K0fMj96qBARqHupz8eRTqG8KWZuiugahTZwpJ0dbw/Mlhm25Ei7iQXIf
         X6GhPE2JuMtVCI8JLG5H/tntXD8AbOF0fVXbtEHJ64ndHKBlOHJzn3gDtELBNnUQq4BH
         ypoMVfNOzfpIKfbASEFwA7BNkZl75Wsa1pJiW139R4o5Cavx3Gz5mR2FAHpN45XQL44e
         cjUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si6859986pfg.254.2019.01.16.08.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 08:12:28 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9553FADC5;
	Wed, 16 Jan 2019 16:12:26 +0000 (UTC)
Date: Wed, 16 Jan 2019 17:12:24 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
    Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
    Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com> <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com> <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116161224.wtz4bp-Be8B8-uCzEd_VOSI0zGYuGRV2b2G983VDtP8@z>

On Wed, 16 Jan 2019, Linus Torvalds wrote:

> > "Being owner or has cap" (whichever cap) is probably OK. On the other 
> > hand, writeability check makes more sense in general - could we 
> > somehow check if the user has write access to the file instead of 
> > checking if it currently is opened read-write?
> 
> That's likely the best option. We could say "is it open for write, or
> _could_ we open it for writing?"
> 
> It's a slightly annoying special case, and I'd have preferred to avoid
> it, but it doesn't sound *compilcated*.
> 
> I'm on the road, but I did send out this:
> 
>     https://lore.kernel.org/lkml/CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com/
> 
> originally. The "let's try to only do the mmap residency" was the
> optimistic "maybe we can just get rid of this complexity entirely"
> version..
> 
> Anybody willing to test the above patch instead? And replace the
> 
>    || capable(CAP_SYS_ADMIN)
> 
> check with something like
> 
>    || inode_permission(inode, MAY_WRITE) == 0
> 
> instead?
> 
> (This is obviously after you've reverted the "only check mmap
> residency" patch..)

So that seems to deal with mincore() in a reasonable way indeed.

It doesn't unfortunately really solve the preadv2(RWF_NOWAIT), nor does it 
provide any good answer what to do about it, does it?

Thanks,

-- 
Jiri Kosina
SUSE Labs

