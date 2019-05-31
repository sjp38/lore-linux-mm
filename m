Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DA25C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:19:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0560B26049
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:19:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A3WPnRqn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0560B26049
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1A86B027A; Fri, 31 May 2019 09:19:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B8A66B027C; Fri, 31 May 2019 09:19:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A7876B027E; Fri, 31 May 2019 09:19:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4375F6B027A
	for <linux-mm@kvack.org>; Fri, 31 May 2019 09:19:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so4698109pgo.14
        for <linux-mm@kvack.org>; Fri, 31 May 2019 06:19:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NGbXt3/IQA1b49aRJS6BBAi0DW9ybOJRqUfZBPY09dA=;
        b=DBVetRPhGVfm2lnNquTIBnYJfOqtBMHbdutzRuR45QxLiEa5BJnD38bss0S/nuqVGh
         xq2UhvSnOrLQUhqpAFg/J0iSjic9/vzEjZtcxvJeRxSwj8pxE+UW3UmGgTxuSD6hDEfR
         mdHHKqL4proS69IHEp52iVfvao87fo5mPJbTGGHbCR1H5RC6OwUQWN8ds/0WY1iMbavX
         1Syk5C3cYlMPZ55pyvUBTDRfkQFtNdSi7/CKMU4Ab7AaBp3jvEyvDt9RNSmHlQyqiS6d
         mPguoDEYFrhtIlkC5A1s5WiM0E0RojK1h7d7L43zQSfCKWBjRLz7ggxx6b6Y9FlarRnN
         aEMg==
X-Gm-Message-State: APjAAAUedWtIgmeQ8E7XJJEv8f5rAYANXiW1A7ZcHTzBjuInpoGiN/tl
	gF54Ca1eo9Nrdu+J+k1EBR7PoL+G8SzdqX9RpQIzTUZ72rMOz7C8t+qHC0zc+heKvQNi76h6xu3
	h+n3lqH1W1/SOfmJonoDtdRB1718QndvRldtGGFf/wb2LDkCn1EN+37pK844nb54=
X-Received: by 2002:a17:902:581:: with SMTP id f1mr9470989plf.343.1559308751856;
        Fri, 31 May 2019 06:19:11 -0700 (PDT)
X-Received: by 2002:a17:902:581:: with SMTP id f1mr9470887plf.343.1559308750926;
        Fri, 31 May 2019 06:19:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559308750; cv=none;
        d=google.com; s=arc-20160816;
        b=w+QVtDktkPrY7s+AMxgr/gTxUilWUTPC/CcLyFfX/f0NYiDb45JdyMnnfcjlqpAQ+Q
         Zj6LLySTIpBQzkWXWpsWsgjyd0+v7DuM7QQKEK16gRkITq9MALRIGJGR5PsAvQTuIr+S
         6KnPKjt/7UazehRCMdbqe6vOOuenLGeERXAcFvgJvAAReLKOrG+uvuoIDAM8sn00FN+v
         LYBp0fwMg2UnNlVKY9TVcnSruPVTRYwglHjvLpcApvfJYQ6Us5wLAv4p6ZzXYzQcMtoO
         MFxrmgWBlhG9T6HAwTZxO/ygkacokMQm0r1wReTCvTLPe/ipcFMrYLHlVixxJBYHwx+R
         mgtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=NGbXt3/IQA1b49aRJS6BBAi0DW9ybOJRqUfZBPY09dA=;
        b=C7yLFrSfXQ05GoGgEKrxh6aTuMiBJybRJiPgkS62iSU9QUdjFnajmjntdtwHfqyEd4
         o3Y8T5mrcFbFMuBuSDxH/0WDDwtOZaQjhCCgoBOFu0mhrgKclFrCKJQSIj2CeP9RiE4x
         zcmBGK9D2p31/ZCw8TB/NJe5DnlYMEYbIIhITZHIOsXQtSvZqBN6iJH8Hl+z6RWByleY
         M6rOQ2DhaCCXS9E5v87+9LfM4g4JSz/XTY6OWhUdIOXUVdKbD2Bu1KxAjCmD0x4iYudM
         PDPIpzCOp/kNDZztqlwMoGQuLGsOspsAPa4UldJHwGCDb/adA2+Ye0vlNB5pXwMFwzvZ
         kYxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A3WPnRqn;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z63sor6228791pgb.41.2019.05.31.06.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 06:19:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A3WPnRqn;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NGbXt3/IQA1b49aRJS6BBAi0DW9ybOJRqUfZBPY09dA=;
        b=A3WPnRqnTUdG3crEHGBb/NpBr+tWmhd8IyhewWKj1R4bjxJzKPyXLzw5G3U9Lnteyl
         S36wH0W0+2k1njFZy2Ds2f/9kFql5X0DZRwamUx250rLJpRwx19xr3wuHqAOJBBYxLq9
         D5yvDqjjRPT9mniegqhTMI69xTfamzNzmqGuYDQC27qaWbbK2U1nrf6NWOVP/AQgAVed
         27HAfAIiBEc/pMFVtc2MGWrATM8vpC7OKdA/xorvzdMTJRgsu4MAyOAQ07qRReLzaC1m
         vS3W5pSSEa4XJdth4E3PvyqmD9aT/s5qNUBsNMohsGUqNgFntqIxkqkXVq7VroDVR9nb
         xcZw==
X-Google-Smtp-Source: APXvYqwfmPTYrU4YNg70+w+fekZWbolWXYkyOovH8OK5qnvs6Xh/v3zPDoIKALH3CJn/NV3nmmscEA==
X-Received: by 2002:a63:6884:: with SMTP id d126mr9237347pgc.154.1559308750486;
        Fri, 31 May 2019 06:19:10 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id d186sm5485008pgc.58.2019.05.31.06.19.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 06:19:09 -0700 (PDT)
Date: Fri, 31 May 2019 22:19:00 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 5/6] mm: introduce external memory hinting API
Message-ID: <20190531131859.GB195463@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-6-minchan@kernel.org>
 <20190531083757.GH6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531083757.GH6896@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 10:37:57AM +0200, Michal Hocko wrote:
> On Fri 31-05-19 15:43:12, Minchan Kim wrote:
> > There is some usecase that centralized userspace daemon want to give
> > a memory hint like MADV_[COLD|PAGEEOUT] to other process. Android's
> > ActivityManagerService is one of them.
> > 
> > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > required to make the reclaim decision is not known to the app. Instead,
> > it is known to the centralized userspace daemon(ActivityManagerService),
> > and that daemon must be able to initiate reclaim on its own without
> > any app involvement.
> > 
> > To solve the issue, this patch introduces new syscall process_madvise(2).
> > It could give a hint to the exeternal process of pidfd.
> > 
> >  int process_madvise(int pidfd, void *addr, size_t length, int advise,
> > 			unsigned long cookie, unsigned long flag);
> > 
> > Since it could affect other process's address range, only privileged
> > process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> > gives it the right to ptrace the process could use it successfully.
> > 
> > The syscall has a cookie argument to privode atomicity(i.e., detect
> > target process's address space change since monitor process has parsed
> > the address range of target process so the operaion could fail in case
> > of happening race). Although there is no interface to get a cookie
> > at this moment, it could be useful to consider it as argument to avoid
> > introducing another new syscall in future. It could support *atomicity*
> > for disruptive hint(e.g., MADV_DONTNEED|FREE).
> > flag argument is reserved for future use if we need to extend the API.
> 
> Providing an API that is incomplete will not fly. Really. As this really
> begs for much more discussion and it would be good to move on with the
> core idea of the pro active memory memory management from userspace
> usecase. Could you split out the core change so that we can move on and
> leave the external for a later discussion. I believe this would lead to
> a smoother integration.

No problem but I need to understand what you want a little bit more because
I thought this patchset is already step by step so if we reach the agreement
of part of them like [1-5/6], it could be merged first.

Could you say how you want to split the patchset for forward progress?

Thanks.

