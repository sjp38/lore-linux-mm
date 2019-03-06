Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C276BC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:35:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87BC420842
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:35:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BC420842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233198E0003; Wed,  6 Mar 2019 17:35:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3638E0002; Wed,  6 Mar 2019 17:35:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 086108E0003; Wed,  6 Mar 2019 17:35:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B777F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 17:35:51 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f6so13921482pgo.15
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 14:35:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AJZgJR3Kmr9TdI3MyLmb8yU++bkqW2SFhH3bSfBEhq8=;
        b=Q07jXVQIeIfFziGumNgtDjMdAWilq0PKmi3tbq9r6lKPZlm8MOiTtYivyhUo0R7fQk
         IgPAwchEorspMkepHaWpQcF7d6nYIrTI6WfwTx8kwOi1pZRAwE4zDas+gtsG7lukAsXc
         PLXyR4mF9X9udsUyhmXOJZlbtSD2qwuHEDw9ukKhalkkAKK3Lbxt7sh/0pZkEUhz9jTh
         FznqMNwRJ7uF0bN0uBjdlbxskw16ORnR8ZVkHUVZBo4uXlnSu9zCqNMNfNjrPHNsAJyd
         Vy4hTixeFuGqhgRm+siBtHPOZMk5IArjJ4D/8qj6/kKyS9wsQlF6XvWtacY4IjMm6bmX
         85fA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAV/GcpXIBTJiP3ZXIh6jX3k2zWdgIiusskonFoaiT3bjsNAH/JP
	+vBSzOWyMPIyRBXNg/iXypLU0ODtPGAxUz3wnmpV5342srgk+CnvJItQ1LHTD/UdANeK0FTJS4d
	TLo4iqhY4mw3M9cAouTwy4sWKtTwvKTsvE2B+Qh6hHYKbRbgg91b/ocV1OqhByEqamg==
X-Received: by 2002:a63:6c43:: with SMTP id h64mr8084826pgc.22.1551911751400;
        Wed, 06 Mar 2019 14:35:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqxo7NwaDJ/1bDPnnDavxDprwcVEPXfW94t43A237kW27kZ8O0Up3eRDQhbvMxJRcm3D1hWj
X-Received: by 2002:a63:6c43:: with SMTP id h64mr8084761pgc.22.1551911750267;
        Wed, 06 Mar 2019 14:35:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551911750; cv=none;
        d=google.com; s=arc-20160816;
        b=XNzEGWpmCPYrIJHmmKSmYLOAC42IsOjWwz8Q1roDzpd2UeI3qutc0BbCnJX2Ro9bVf
         mmifxJZ2ImP1l0ZArFJdUSWhop1X2PhpMRwmmI9oLzG7RmIM7h0sxcyfYMjVqVTO38S2
         ex3pKu6cQO+Cr1z0FVdgoII515YR1HpCZWzsQEiT3dlZEbmwkPz0DlU4xs5f0rWiysGW
         SKDYU0Aeom5sh3IZmx+dz4Ktxgh0l76/nrPiwc1PolihYDP6TdZx/mBP9eNhdpG6UpqB
         VMcR0iNlaEc2dUgy1CWiepQTuM+vFlUsmca9AV1ndvPgeYTP/40yPTivWDIH5gVsPHSV
         cNXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=AJZgJR3Kmr9TdI3MyLmb8yU++bkqW2SFhH3bSfBEhq8=;
        b=Y1efT8yrSkJ+SIi6E5obb6KqQxecVnDEpZzfy9gEbSsG5qnAuvwkawR0lJOcpvEIk0
         ixl6E8zf2gR+gge5XiOsxajzgIYikWmE2NnLmsN8tIvrjpEYZjqv16c6FtYW249ACQS3
         DWsmIFbl0EfF9SPendC1lF4/3C3iuMBlPfzjz+rH13+kc8lV5zdeMwzqKyv5AnYfSmLk
         o6PYSPGcTdehNA6u7855MpHHZUGkQfElKICQJCeUwpv0Q7bkH56klgXtM282YYue4Rp4
         5M7PdIbiPwz06fPrwN4nOX9Iip+OxPQguJQG9s1nBzcqQZG/XUivSl5/FLfOy1+rmbof
         xMmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si2554303pfa.121.2019.03.06.14.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 14:35:50 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id AA70B5975;
	Wed,  6 Mar 2019 22:35:48 +0000 (UTC)
Date: Wed, 6 Mar 2019 14:35:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-api@vger.kernel.org, Peter Zijlstra
 <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Jann Horn
 <jannh@google.com>, Andy Lutomirski <luto@amacapital.net>, Cyril Hrubis
 <chrubis@suse.cz>, Daniel Gruss <daniel@gruss.cc>, Dave Chinner
 <david@fromorbit.com>, Dominique Martinet <asmadeus@codewreck.org>, Kevin
 Easton <kevin@guarana.org>, "Kirill A. Shutemov" <kirill@shutemov.name>,
 Matthew Wilcox <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
Message-Id: <20190306143547.c686225447822beaf3b6e139@linux-foundation.org>
In-Reply-To: <nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019 13:11:39 +0100 (CET) Jiri Kosina <jikos@kernel.org> wrote:

> On Wed, 30 Jan 2019, Vlastimil Babka wrote:
> 
> > I've collected the patches from the discussion for formal posting. The first
> > two should be settled already, third one is the possible improvement I've
> > mentioned earlier, where only in restricted case we resort to existence of page
> > table mapping (the original and later reverted approach from Linus) instead of
> > faking the result completely. Review and testing welcome.
> > 
> > The consensus seems to be going through -mm tree for 5.1, unless Linus wants
> > them alredy for 5.0.
> > 
> > Jiri Kosina (2):
> >   mm/mincore: make mincore() more conservative
> >   mm/filemap: initiate readahead even if IOCB_NOWAIT is set for the I/O
> > 
> > Vlastimil Babka (1):
> >   mm/mincore: provide mapped status when cached status is not allowed
> 
> Andrew,
> 
> could you please take at least the correct and straightforward fix for 
> mincore() before we figure out how to deal with the slightly less 
> practical RWF_NOWAIT? Thanks.

I assume we're talking about [1/3] and [2/3] from this thread?

Can we have a resend please?  Gather the various acks and revisions,
make changelog changes to address the review questions and comments?

Thanks.

