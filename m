Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61747C43612
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 097EE20859
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="PPNwGegn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 097EE20859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626448E0005; Wed, 16 Jan 2019 00:58:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D55F8E0002; Wed, 16 Jan 2019 00:58:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EABD8E0005; Wed, 16 Jan 2019 00:58:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id D41A88E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:58:55 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v24-v6so1310762ljj.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:58:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZZS1U4v3VDXUyEzZkch2LpzJzGSGpGfSwXpd93MlFK4=;
        b=t1IHlXTaCz+cp5080JFFUdqyGoPqRnI5cDyYBieGjo7n+EsKITm6lzp6iYWgkmASuv
         2WHnKQvIOuQ+BPi0CYYkV5Vh9b1lIVlobsJQiEr+1CaO1h6kA9WJ5r+wC613Swuu2IaD
         NTex8FJlNWAcnjLvOPRiGI9NQ8tiWpRKx88UdMJXstp89zzF1WE97f75px2se8nxA+GI
         azxDq3uCRRq7v8qKOlD6pZ/BMZ6ipNc5O2YoB3bZsjxY+GfJdrgrtOu1c1DnautcJUyl
         +957mJy2Sbi2Yr/aC1k418lNJk3B4mM1xzoVoiWq27CZsMSn6wOfQKcYNoyO5pgoD/76
         ob2A==
X-Gm-Message-State: AJcUukewQZQqLAgeplqHv5PlmWcDnlEPTQdofbC4eP+6tNQXrJLMT/Hm
	NMI1nTapAgSC7/NyXxbzXU1Vp5MCl6Ajoxw2cmfwV4I9TLs+Qmm9WnK3JEPyJ2AzUvZxOZJkFUZ
	ermX53zhY+oqLUW9J1AD5o88t6JXqn5FP+UDgykQWkO/fmUXDHpS46GXxCc+zULFD2NPp5KfzAS
	nSvZBGileCgro+AtVFiZ3igTB2B1bY77+jKna3fx2PgOzzaDYALKQTJOM67RqxZlzbJn3Wl+WHA
	+KY76RFb/VBhdzXY61LoOjupqnWOUi8aCoLFSoyncl4TJMRI1hZ4/oxrGnYJdmFDjr4Ab9CaRKK
	2w5sKNKxbAklbfKQ0b0u4zELT5P/I05E8VUwrnFiuMhdNkyV9GMGyyRqxp7jeAgJAf3UEpROGGZ
	N
X-Received: by 2002:a2e:3e04:: with SMTP id l4-v6mr5083038lja.148.1547618335222;
        Tue, 15 Jan 2019 21:58:55 -0800 (PST)
X-Received: by 2002:a2e:3e04:: with SMTP id l4-v6mr5082996lja.148.1547618334093;
        Tue, 15 Jan 2019 21:58:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547618334; cv=none;
        d=google.com; s=arc-20160816;
        b=uHrFRVqqtivLhLW0Wi5JYFVLxEaQTJlzHn7mg4Qzpkb66OHQbUjS0k3SSxRsdDcE2y
         L3T7SdxmA0fQqgdjABixD+Ql3CUeEsIraazcrPytKCDpHGjx9CBwBcoSDF/IvtvhR/qh
         kBqenSjUu/3Cq8g3YdeR9fqIXIt7Vsb6Xh9PPBD6gAeJhgjl1wmPu7mWFE45OiLdbpa7
         JDpk6xUCr3prbcQO1AY5ijplDno3y/UNhY6dZS6Zv2qpfr0T2lZbWHgKjt4VdYuqgcDa
         SGZPCyCDYGrwU4FF0d9r9sbXQNvySR79cNcwPHdzJb7WuAKJgxMF42f/KgkCqIG5ubGm
         k6TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZZS1U4v3VDXUyEzZkch2LpzJzGSGpGfSwXpd93MlFK4=;
        b=l3DTDs2pztj7FON63EzHmjAS7s3kOHUgeZTnCZe3GZhmUERDvP1UNBcymQKvAiKW+K
         5LxNKv8FpuJsnMRhsZzg58j6A1Mb6MKAlcHWoQVjubF7pArczVqthhsiJbE92xcVp+PZ
         MB1mvP7hkS6BqXWDhC0YC3CHkG+UQBU/bgxJWEShNP/XuVHFsSwPnWOStlSn4my+Diiw
         Jl+oYmItqJwES2KYJyeELIpu7omCU9hw4r0WCIDhhSD1hczzgmy0/jkcweAuZRjVTP+o
         dIucDwl59tze0k8YCGHln9bXWJ1fxTMXVW/rP+B4L8LxEAQY8098EMGIA/RrgmFvYCCU
         +ngg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=PPNwGegn;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor4017832ljg.10.2019.01.15.21.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:58:54 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=PPNwGegn;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZZS1U4v3VDXUyEzZkch2LpzJzGSGpGfSwXpd93MlFK4=;
        b=PPNwGegng2NcNnY4scnYrVjmXI/IOp7EcDNxzrLfLqB1Z6oAmDCmQFBvGCPnpyNDak
         t+OaiqHTIpJ5WZRC0xGNwJ/DmR6oi4yJAQ1xfTGRPzfSsREsHHbLttRkZXqm3asv03xb
         D2ojNpW7Jvq3VlY3z0zP4wGyOck8ObDRQi2NY=
X-Google-Smtp-Source: ALg8bN4G1gJfLwlenlhJCRjB/v2Z1ujVlYYodhK5ty/N/5h47g+hrcebBQ6DsH7eSzwDgIeZ6+kgFw==
X-Received: by 2002:a2e:81d3:: with SMTP id s19-v6mr4689004ljg.138.1547618333379;
        Tue, 15 Jan 2019 21:58:53 -0800 (PST)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id b21sm986000lfi.7.2019.01.15.21.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:58:51 -0800 (PST)
Received: by mail-lf1-f45.google.com with SMTP id u18so3895757lff.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:58:50 -0800 (PST)
X-Received: by 2002:a19:4287:: with SMTP id p129mr5557953lfa.135.1547618329349;
 Tue, 15 Jan 2019 21:58:49 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica>
In-Reply-To: <20190116054613.GA11670@nautica>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:58:32 +1200
X-Gmail-Original-Message-ID: <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Message-ID:
 <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, 
	Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116055832.RoJIicvarSriJso7C65Mm-QzvkE38BqkBhhCjIOjiMQ@z>

On Wed, Jan 16, 2019 at 5:46 PM Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> "Being owner or has cap" (whichever cap) is probably OK.
> On the other hand, writeability check makes more sense in general -
> could we somehow check if the user has write access to the file instead
> of checking if it currently is opened read-write?

That's likely the best option. We could say "is it open for write, or
_could_ we open it for writing?"

It's a slightly annoying special case, and I'd have preferred to avoid
it, but it doesn't sound *compilcated*.

I'm on the road, but I did send out this:

    https://lore.kernel.org/lkml/CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com/

originally. The "let's try to only do the mmap residency" was the
optimistic "maybe we can just get rid of this complexity entirely"
version..

Anybody willing to test the above patch instead? And replace the

   || capable(CAP_SYS_ADMIN)

check with something like

   || inode_permission(inode, MAY_WRITE) == 0

instead?

(This is obviously after you've reverted the "only check mmap
residency" patch..)

            Linus

