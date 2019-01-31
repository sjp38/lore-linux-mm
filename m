Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB94DC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:34:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89E1E218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:34:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AhA68lec"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89E1E218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C56A8E0003; Thu, 31 Jan 2019 06:34:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074868E0001; Thu, 31 Jan 2019 06:34:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECD8E8E0003; Thu, 31 Jan 2019 06:34:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE828E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:34:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so2155926plk.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:34:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=tG7iZlGAHpTabFEMX3yuBH7oDEDoZZ3WfHqqGxaohM4=;
        b=ITU4Upyl87km5M2wztrtGDpKFJGJCmuK9XWRDMi/QOg7UrgnZH7Mbjl5pwW6aCPd3B
         7Zo0XxBTZ5uzCB6X+mnajDi2sp/l3uaXhhKsR3Ab19H/oYJb8w/7jiijugCUiBJh886l
         en7F3hRcWBBSQIAnuVpa1KQ6Hu8PsFflv5tJNWO+wqwKHGlLRSA3itumaEzusXd6fVh/
         MFqu3MfYzoxZw8Lo9+Ql9swFRWIQJmcFYIsvdlZ3CkOwlU18hEYE7jfDYofFU0lYxy/m
         IVySy0iDDR6mt5x1PnVyTl9aWHX+ABjsZNhxJjmMohtpM0olreJMgH8rLgZpEDAlgksU
         zJXw==
X-Gm-Message-State: AJcUukcnHyDmvGzcHaPj/RiM3FHfZhi+0eWa44RJlzz2vFh6JuEip1Au
	LoKPZIAWDXetK4kvGGuJZGtCAI40hyhVmAL9xtgkuERG7SK/fO4iEfgcDmAguB/UNTRdF+TSCd4
	wNBLvbpcN4ihMeyHOJQz3iABsm0LjmRrx7cP2O1OwyUya7xjY0PLU/xknTh7IFjs18Q==
X-Received: by 2002:a63:20e:: with SMTP id 14mr31063530pgc.161.1548934490289;
        Thu, 31 Jan 2019 03:34:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Q3wxnInBSn6m30cNdjZBkw/p3nyBA07M2KWlzos2qLpAZSMGXB6CCTsG2zsrSjEOrHQuQ
X-Received: by 2002:a63:20e:: with SMTP id 14mr31063500pgc.161.1548934489618;
        Thu, 31 Jan 2019 03:34:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548934489; cv=none;
        d=google.com; s=arc-20160816;
        b=DgwaeZzLCEwW1gIl7ByzaTQjj+Y2XAQFsJniP6rS30MlSMMBbr7gxvV40ET0kfn+Rv
         nfmpWLmXThSY5mjY1nHWDbraZfyZT3k+KRRKyLa70Yj0a2rYRmDEu4HMILEV0JcnBXld
         9Tm1Mb/ch+aAsaXJSXtLdUk5DM9ppTHKDW6xOQpaLCBAVqe9ig2bTUqYv1Zq25gEhc9v
         kCRtzBiopT54bPyqKL4s67BfxhS/ErDx/RKZLM5iI1O9nKwwfF+cfe/8U8hi9ohFoASv
         Nk8ym2paaKn7I1q+vCdEHbam99oOUCkRdt7ApK6bYtIsBdl+BhXAgotHTE+d4vK7nWSq
         O1Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=tG7iZlGAHpTabFEMX3yuBH7oDEDoZZ3WfHqqGxaohM4=;
        b=IJsdJlAP6O5L5Z4eTuzMFBN2WHZLkIbcGCYCLyBZ/OYXlaEi6U5r7WV78qqdxRn52v
         fxZS2zF3TYZ6vd/d8N/V80AgojUv4V2GQ+61QxIf84ZoOMM03lkEKsKs0uMW2zaNLt14
         cbCYbu5tI58Afy3N4xkPyFcsL6xKKe0Jx7eWVrrZK+Eg09rRtfDkYy8DLdruRNde5fTK
         Drg4SekjUlzKva1kA1DPUpw4BUztaJfqJF6wB+EYw/PeUbVnfXOu0Gb3D1m2e46QkfnM
         2nsFADrHi9idwokEFKYO8cn6UD3+V3lrbtphCCeP5FyY7OpODli7S8igx4pIo+E5oHCE
         0eLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AhA68lec;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d10si4063714pgf.136.2019.01.31.03.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 03:34:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AhA68lec;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1859C218AF;
	Thu, 31 Jan 2019 11:34:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548934489;
	bh=SFVfJoJ5TREELE0WD6PH6m5/w/yW7Aknfnn9AUYvQP0=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=AhA68lecaRUyoHyE8td5xQh/w2blB1dTK5V42cd/a1IxY1uNaZMgLj0HIlwxbFjM+
	 yxCss+2pzG5OI/nbVrL5M2v1rtvk3vJ/Af+jBtXP7g/zo3vwo9/ivJ3l2OqkROiAHA
	 NLGcJFt00TOEsgplHJ4wFQmV2eQ8amQeX/+1Fpo0=
Date: Thu, 31 Jan 2019 12:34:44 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Florian Weimer <fweimer@redhat.com>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <87imy5f6ir.fsf@oldenburg2.str.redhat.com>
Message-ID: <nycvar.YFH.7.76.1901311223270.3281@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <87munii3uj.fsf@oldenburg2.str.redhat.com> <nycvar.YFH.7.76.1901301614501.6626@cbobk.fhfr.pm>
 <87imy5f6ir.fsf@oldenburg2.str.redhat.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Florian Weimer wrote:

> >> I think this needs to use a different flag because the semantics are so
> >> much different.  If I understand this change correctly, previously,
> >> RWF_NOWAIT essentially avoided any I/O, and now it does not.
> >
> > It still avoid synchronous I/O, due to this code still being in place:
> >
> >                 if (!PageUptodate(page)) {
> >                         if (iocb->ki_flags & IOCB_NOWAIT) {
> >                                 put_page(page);
> >                                 goto would_block;
> >                         }
> >
> > but goes the would_block path only after initiating asynchronous 
> > readahead.
> 
> But it wouldn't schedule asynchronous readahead before?

It would, that's kind of the whole point.

> I'm worried that something, say PostgreSQL doing a sequential scan, 
> would implement a two-pass approach, first using RWF_NOWAIT to process 
> what's in the kernel page cache, and then read the rest without it.  If 
> RWF_NOWAIT is treated as a prefetch hint, there could be much more read 
> activity, and a lot of it would be pointless because the data might have 
> to be evicted before userspace can use it.

So are you aware of anything already existing, that'd implement this 
semantics? I've quickly grepped https://github.com/postgres/postgres for 
RWF_NOWAIT, and they don't seem to use it at all. RWF_NOWAIT is rather 
new.

The usecase I am aware of is to make sure that the thread doing 
io_submit() doesn't get blocked for too long, because it has other things 
to do quickly in order to avoid starving other sub-threads (and delegate 
the I/O submission to asynchronous context).

-- 
Jiri Kosina
SUSE Labs

