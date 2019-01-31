Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07B7EC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:47:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD0B8218E2
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:47:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD0B8218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57D738E0003; Thu, 31 Jan 2019 05:47:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52CDD8E0001; Thu, 31 Jan 2019 05:47:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C218E0003; Thu, 31 Jan 2019 05:47:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 149CE8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:47:33 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so2731391qkm.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:47:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=7Klnp9xiG7n1L15f+AlJ3ik5g2TslEmy+UDFykUbMv4=;
        b=bmSdcxJ+0ynTinP8SezqGO5T4NMGipBWq1xtcpkwsOFBLFmBytT523doOImLmw50NU
         N74f+Uf3H2CknXuCoDJNvaVjS4nluPgxxXbRO/ecG0nd+QwzI9IT6HVDctYa84UODrCH
         0SJXrZR4J07gn9SsoUWUsGvhwVF+bALnbDMq3UZ3lyh9M7wmFOoEPQ+Hon66guV/dw/e
         66FDLQE0ojZPfS9p5ng4QCUEPyVMVw/2t/8BGEbmyjtkzOfxAQBauE8hXqjr+cMg2ZIr
         dwLAyDD7LBhjD4evWS7VwyZkizSqNQLEvfAwI6R4i9pZV71ory6llz4yLSvs+RtpvgP6
         H0+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdhit+cYW0swxKTOYZMNbkaDoGyQc5pDvdywomLSGbnR4SOWE1x
	CVvEfTtM+kuaH3HjhBAFu1JiTqPJxg20JFRkXwlIF5oJsJc3zTf0DcN8AFjZtMUea0I8o3tZ0FI
	nfuZFiQizKvlNDp/ZFRKRLpANpdZ/mG431Wuj3hqV3OhrJ+IH20YrwBLsA7L1phrZvg==
X-Received: by 2002:a0c:b5c8:: with SMTP id o8mr32517902qvf.213.1548931652825;
        Thu, 31 Jan 2019 02:47:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7JjgaNeGfyjYZkgqeX9avnPI27HY1couVvs9UNbZUXoMuMDDTSxnwnj0enREg+ef3KJoiB
X-Received: by 2002:a0c:b5c8:: with SMTP id o8mr32517883qvf.213.1548931652319;
        Thu, 31 Jan 2019 02:47:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548931652; cv=none;
        d=google.com; s=arc-20160816;
        b=Bxb0q+5VkxAb26FbidklmKoiqk0ZSiioYEPq+5rdfzkUlw3OOPRBRHPyceY4zi1sEm
         ofrZvXopyHG8dK9vdMCYhB1RKJMe0Si/xgyGHEZ7dIvZp8F0gCzaKr4/lwGmTvriAiz6
         vdWHJCJDS7SIJuFv1UbfXOthPu2DggmunpyREB6ZcW8LDzUyN3esLH/tSL3i9I8/Tn0K
         PbXY8kbSYQT8oLKZG0l5IfM+bGi4gecykq3Jl+Gb54obN8jyFxdkrLR1DEbY1Ty6P223
         Fc+geQ1nXxuDbHXBnJSNU6uyPMzIDbegAi0cxpi0vBSqNZoWGS1ygh4Ozy156ATjPQKN
         5IKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=7Klnp9xiG7n1L15f+AlJ3ik5g2TslEmy+UDFykUbMv4=;
        b=UjbUjJMaKGSnsZWjzfbopMXSdiwTHu/0UOPJdY5vV/x6J/1r+W97oKyLMCDjUd93gc
         uUK3Jl0y/kvqbUfKO66iIXSVc9uS87RfKfZ5sL02V/vy6B+0LPkTRd3TNUtzTxi/Z4bj
         KojI2qiORART42fk1iVKT5M2aw8mD3NjKxjkwCUCn/ahWxBg/D7RTq5VJzqyPt9lWmfQ
         DWkoXR6cDRofHNIZ9HhOKIWu2J/7+RmTc4u+xrGLdT8QSpnDr9H6h8XVPf7rX/tZHgsR
         An2NajcIighs05K+sqSctC98cNghbgK8FADJa1KfwJr9b4obauPuEjm+DiVQ4HHnYnTu
         cDjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si2761005qve.86.2019.01.31.02.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:47:32 -0800 (PST)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0AD4C1393E0;
	Thu, 31 Jan 2019 10:47:31 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-116-50.ams2.redhat.com [10.36.116.50])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AAC2A608E5;
	Thu, 31 Jan 2019 10:47:26 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,  Andrew Morton <akpm@linux-foundation.org>,  Linus Torvalds <torvalds@linux-foundation.org>,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,  linux-api@vger.kernel.org,  Peter Zijlstra <peterz@infradead.org>,  Greg KH <gregkh@linuxfoundation.org>,  Jann Horn <jannh@google.com>,  Dominique Martinet <asmadeus@codewreck.org>,  Andy Lutomirski <luto@amacapital.net>,  Dave Chinner <david@fromorbit.com>,  Kevin Easton <kevin@guarana.org>,  Matthew Wilcox <willy@infradead.org>,  Cyril Hrubis <chrubis@suse.cz>,  Tejun Heo <tj@kernel.org>,  "Kirill A . Shutemov" <kirill@shutemov.name>,  Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<20190130124420.1834-3-vbabka@suse.cz>
	<87munii3uj.fsf@oldenburg2.str.redhat.com>
	<nycvar.YFH.7.76.1901301614501.6626@cbobk.fhfr.pm>
Date: Thu, 31 Jan 2019 11:47:24 +0100
In-Reply-To: <nycvar.YFH.7.76.1901301614501.6626@cbobk.fhfr.pm> (Jiri Kosina's
	message of "Wed, 30 Jan 2019 16:15:55 +0100 (CET)")
Message-ID: <87imy5f6ir.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 31 Jan 2019 10:47:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Jiri Kosina:

> On Wed, 30 Jan 2019, Florian Weimer wrote:
>
>> > preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache
>> > contents, as it reveals metadata about residency of pages in
>> > pagecache.
>> >
>> > If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page
>> > not resident" information, and vice versa.
>> >
>> > Close that sidechannel by always initiating readahead on the cache if
>> > we encounter a cache miss for preadv2(RWF_NOWAIT); with that in place,
>> > probing the pagecache residency itself will actually populate the
>> > cache, making the sidechannel useless.
>> 
>> I think this needs to use a different flag because the semantics are so
>> much different.  If I understand this change correctly, previously,
>> RWF_NOWAIT essentially avoided any I/O, and now it does not.
>
> It still avoid synchronous I/O, due to this code still being in place:
>
>                 if (!PageUptodate(page)) {
>                         if (iocb->ki_flags & IOCB_NOWAIT) {
>                                 put_page(page);
>                                 goto would_block;
>                         }
>
> but goes the would_block path only after initiating asynchronous 
> readahead.

But it wouldn't schedule asynchronous readahead before?

I'm worried that something, say PostgreSQL doing a sequential scan,
would implement a two-pass approach, first using RWF_NOWAIT to process
what's in the kernel page cache, and then read the rest without it.  If
RWF_NOWAIT is treated as a prefetch hint, there could be much more read
activity, and a lot of it would be pointless because the data might have
to be evicted before userspace can use it.

Thanks,
Florian

