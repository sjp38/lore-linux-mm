Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C62BC43612
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 04:49:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE3D720883
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 04:49:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="amwtGCvK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE3D720883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31B528E0003; Thu, 17 Jan 2019 23:49:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A2408E0002; Thu, 17 Jan 2019 23:49:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1439C8E0003; Thu, 17 Jan 2019 23:49:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 942418E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 23:49:52 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id s64-v6so2916092lje.19
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:49:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Gqf9qHHa0eKIHV+14V27XEKAlPK94YNO0a+RM1lW6M0=;
        b=PKdlLaRKDj5+0FFA/mplI7lzHYpZlmJDtY6f5TyHXGvW99ubUokDyucbc7IIvRF+1P
         FTWpMUJ42BEFFYsjuyk5XB7Rx2dJUQ3sjfhEBwK2D08HOOwdAvuSy9G7bw9+HrII0bbC
         +a0kSI25maFHqsCE7Fclw9zzI3qehJt3gAIgUQCsYBXfKrSCzptQj2MqkXx41djO90I/
         MYqEZ7u6HHwcNkPFiB+k+ISujcLsYLfleszbpxH7FHHkUjnbGIBk8XjwFmBDyaRpIhmE
         Wi6KlMYrLIGHkjVubDcpXrfdbJcnb31Fa5TxWTa4qNriapVyH2eHW26RJJYZDPlznbAP
         rnqg==
X-Gm-Message-State: AJcUukd7v5Khpwes51ExocGtP46i/lEaj2AXaVHGahxXmEmUxNXfP0+m
	E9tTnlSERTV4Nrye0lyCPfc1jTirG3Rk7tQmr/XCRCqSlucZcMyajlC/Qqjp1spWDbHFg/fX5Dl
	I03OBmlGECa9oTubq8p5X8gITWOdSlbf6j/jOwO1PgzEuWTYWUpI8z99Udz8YqJopd33fWoZ1M9
	2KVCiqibsOywBTxC8IZBsMPk78eLTPBl8mWeCw0B4NvS3mvONmw41Ec7YBYdV8BE9Pqh/cOLGWe
	FbIZOvybKpxROz0pRu6xdqxtwhvJl7EG/vQdKJu1wka36Pvd0m69EncFr8jnTRLvHuqRsQZ2Cnz
	CPDerwrUVXqcOwgX+KKO0xNUhXQvaOfcPp6hdCmNCuhV34zQUrgZ6xzzVbLoA/yUfxD9SvDdhQ7
	q
X-Received: by 2002:a19:8096:: with SMTP id b144mr12608419lfd.8.1547786991639;
        Thu, 17 Jan 2019 20:49:51 -0800 (PST)
X-Received: by 2002:a19:8096:: with SMTP id b144mr12608384lfd.8.1547786990140;
        Thu, 17 Jan 2019 20:49:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547786990; cv=none;
        d=google.com; s=arc-20160816;
        b=FZMaX3Ev/7bwGpq3kSnxlFJOGQdxZNGJsGRBlUOaSql67WhHYRHbBzM5BaBm8J9Vt3
         WCozmy3zLp6YTIsrwrbkeQ5+uEYxc6Ys94PMXwORhBQTgwJYt5M6trFYfqLSScjJPE9q
         mixl8HBsEMhVrhxpmoCryxlMhUZ5UUgoivvcioAz7n9mePVoOis7M8pydDZKnHI2FMny
         W8r+zIfUptoS3s5/iO6f5oWBrJ75y+uL3eO//ch2VmYddIdzcrGZl6CVzWIT9yycJjsb
         ISLSfNbdu/F1emADDLy+a8GPqXQLMzGsFd/erPJH5HPKoy6CQd5yGql5UFBER0PY32Ap
         z+Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Gqf9qHHa0eKIHV+14V27XEKAlPK94YNO0a+RM1lW6M0=;
        b=Mpr/2BWbLAeXz+zRPgoCqiMw1dIawBD0qAmHvR1qNXmJNWep7uPBom8OhyPoTtECev
         BlYZKlrxmDw0Gg9VZ7o/3QoVuyQ4xBCsCTlTUl6YSRce7uaUHtWSvWytSNLMgQyGrRaD
         oJgUAbwS7zKYH/wyZbj58iML3zrsc8l4g5x4GvRgMn/BQDGNgZcM8NDm+JKgpt8zyy0E
         J/OYHu5VFkRWPkd+LdG7EbZLJX7E6yFmYMjLssqa/JMI4RbsclAzszv1a+vNVpT2LpZ8
         CUVNE8TnQbfZzQnok00lKP6ZE3h5aC06hNjs7RMoWY86KpSafBrXb8OrJM7uGPbukwtG
         Bt+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=amwtGCvK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4-v6sor2436612ljc.11.2019.01.17.20.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 20:49:50 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=amwtGCvK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Gqf9qHHa0eKIHV+14V27XEKAlPK94YNO0a+RM1lW6M0=;
        b=amwtGCvKbkeY8xeTsPStBlygztpu7+NzIWZeZMInmmPPgYzP70KMKK+wXQun03oZTL
         4gaqpdKCC94C/fIW4letO9lVl33BumTvbRz3lEu44trR3vQ/1GBqPj4MtSJ6uCOREp/d
         /2WdUfwUpfb1hyWXK5ciVRMxO8irBXFtrq4F0=
X-Google-Smtp-Source: ALg8bN4uHNqRNMZ9QVofZsqXKhIzZzbg7WzfFwsN4M1LVH//GGCkKQccmdGswmPqYl26iGPOkATNow==
X-Received: by 2002:a2e:3308:: with SMTP id d8-v6mr5070727ljc.38.1547786988781;
        Thu, 17 Jan 2019 20:49:48 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id k3-v6sm542700lja.8.2019.01.17.20.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 20:49:47 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id c16so9524678lfj.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:49:47 -0800 (PST)
X-Received: by 2002:a19:c014:: with SMTP id q20mr11103285lff.16.1547786987162;
 Thu, 17 Jan 2019 20:49:47 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <20190116063430.GA22938@nautica> <CA+t-nXTfdo07EBvVo+mu8SRhrVyB=mEPLDQikHfpJue1jALJtQ@mail.gmail.com>
 <a056deb7-9c11-612e-2b3a-6482acca4ff6@suse.cz>
In-Reply-To: <a056deb7-9c11-612e-2b3a-6482acca4ff6@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Jan 2019 16:49:30 +1200
X-Gmail-Original-Message-ID: <CAHk-=wi0MXm4zTC6jjS1TBfbHW_sQq_OcyfeLBNGJ29m88pt+g@mail.gmail.com>
Message-ID:
 <CAHk-=wi0MXm4zTC6jjS1TBfbHW_sQq_OcyfeLBNGJ29m88pt+g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, 
	Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
	Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118044930.L2vh12PJt4mMB7C84ZIX5SCzKzriY-utt-1FGAbY-W4@z>

On Fri, Jan 18, 2019 at 9:45 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Or maybe we could resort to the 5.0-rc1 page table check (that is now being
> reverted) but only in cases when we are not allowed the page cache residency
> check? Or would that be needlessly complicated?

I think it would  be good fallback semantics, but I'm not sure it's
worth it. Have you tried writing a patch for it? I don't think you'd
want to do the check *when* you find a hole, so you'd have to do it
upfront and then pass the cached data down with the private pointer
(or have a separate "struct mm_walk" structure, perhaps?

So I suspect we're better off with the patch we have. But if somebody
*wants* to try to do that fancier patch, and it doesn't look
horrendous, I think it might be the "quality" solution.

              Linus

