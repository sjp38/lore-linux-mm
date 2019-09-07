Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E923EC43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 19:55:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95FCE20863
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 19:55:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="M0wgqewN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95FCE20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F7F46B0005; Sat,  7 Sep 2019 15:55:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 281616B0006; Sat,  7 Sep 2019 15:55:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 148636B0007; Sat,  7 Sep 2019 15:55:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id E0ED36B0005
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 15:55:56 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 897CF8243760
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 19:55:56 +0000 (UTC)
X-FDA: 75909180312.15.men07_16b991c34ba53
X-HE-Tag: men07_16b991c34ba53
X-Filterd-Recvd-Size: 4399
Received: from mail-lf1-f66.google.com (mail-lf1-f66.google.com [209.85.167.66])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 19:55:56 +0000 (UTC)
Received: by mail-lf1-f66.google.com with SMTP id l11so7606799lfk.6
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 12:55:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=663xhzIHxf1pK8txAzNcnxHkg/IWtvcnbHcDk/Hfg2g=;
        b=M0wgqewNEoEY1SReAm1dZItv8C9F48pCqYdE249MYwIQuA6a9rDQ3vPZ1LWGw1upQB
         kJ/9CCrSG0gNE2Gwm1qOTEKQCzc3dQB/0i1U5m6mp+uZO3efppPPZoXX7FK9dlLnOSJP
         Hqpn9Ih4glGrGlUoRDU8T6+ayMV8VHlQJfvm8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=663xhzIHxf1pK8txAzNcnxHkg/IWtvcnbHcDk/Hfg2g=;
        b=CMgJhZ6zJTegpJpbOFBnbAo5OaDgC38Y+590ZcyNORsEBxWaaRFoXJZ5E7EOluA/ff
         ehTU/x8TcKNyZaCzeZa82VoLT1uxDsX2t3PkZEW7JMwtOtFyKmKipnVEgPbQa0yw0UlS
         zqgp/efLl4oAhNbJe1dJcu+jd7Dbn6VgUPebkyKexe4qiIPqm0OvHH3wkrBSoCF4Xnij
         jGYHoAdk3Sx3Wioc/8WxiNyOiek9C5okE1PXZXxRSj1UqaNRBTVI1llgzeKVUdDbny/p
         HG6zSv9oDCKd0XVOK+y0mfpubDTaCTsxb+JBILBhIK9qqohrAXinST0sPRFwEe58psvw
         RixA==
X-Gm-Message-State: APjAAAXxtx+tFsVy/4SzpNxy+a1Emhf5s6qDu+Q3Kq77oG+aNtYPH+nT
	pC4IdTojHIUeLQkLqa0MNiNwXggM3zw=
X-Google-Smtp-Source: APXvYqzUs/8qnhXqlh+1a4/e2SMxsb6lEgTaoxTPADm//DuXGSjHLmYz32JsNPJ5arajtKGV21mOdQ==
X-Received: by 2002:a19:9145:: with SMTP id y5mr10951195lfj.88.1567886153593;
        Sat, 07 Sep 2019 12:55:53 -0700 (PDT)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com. [209.85.208.176])
        by smtp.gmail.com with ESMTPSA id n7sm1595956ljh.38.2019.09.07.12.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Sep 2019 12:55:52 -0700 (PDT)
Received: by mail-lj1-f176.google.com with SMTP id 7so9038158ljw.7
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 12:55:52 -0700 (PDT)
X-Received: by 2002:a2e:814d:: with SMTP id t13mr10346678ljg.72.1567886152153;
 Sat, 07 Sep 2019 12:55:52 -0700 (PDT)
MIME-Version: 1.0
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com>
 <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
 <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com> <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 7 Sep 2019 12:55:36 -0700
X-Gmail-Original-Message-ID: <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
Message-ID: <CAHk-=wifuQ68e6Q4F2txGS48WgcoX2REE4te5_j36ypV-T2ZKw@mail.gmail.com>
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote hugepages
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
	"Kirill A. Shutemov" <kirill@shutemov.name>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 7, 2019 at 12:51 PM David Rientjes <rientjes@google.com> wrote:
>
> Andrea acknowledges the swap storm that he reported would be fixed with
> the last two patches in this series

The problem is that even you aren't arguing that those patches should
go into 5.3.

So those fixes aren't going in, so "the swap storms would be fixed"
argument isn't actually an argument at all as far as 5.3 is concerned.

End result: we'd have the qemu-kvm instance performance problem in 5.3
that apparently causes distros to apply those patches that you want to
revert anyway.

So reverting would just make distros not use 5.3 in that form.

So I don't think we can revert those again without applying the two
patches in the series. So it would be a 5.4 merge window operation.

               Linus

