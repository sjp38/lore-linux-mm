Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1FEEC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:32:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A298E206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:32:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A298E206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A5758E0003; Wed,  6 Mar 2019 18:32:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2535F8E0002; Wed,  6 Mar 2019 18:32:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 148478E0003; Wed,  6 Mar 2019 18:32:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B28778E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:32:25 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f4so7736050wrj.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:32:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iEJdLLdI0p3kQ1WMlPlDYN0voWnGZNKexDZTymL7TBA=;
        b=P01p+mG0Zjw6f5Y2xLoLIuEspVmCwcq1HTn31+GXL/uKQ+Gl7er/7dQ7gWEdIQElM5
         AQBoE8/Wzbd9xODLMc0O308wGyEOR35wObpxU3K5+NKLCCL9ezoQyi1WivMnzh+d5ox7
         o8fVPUU8KBpauHSPqJE/k5JgM+WZ5JYe+0JNtEQUY6s9RGiex1Ytb7TF6a4S/JRJCvqB
         kMf21fTMTUkyieFPpoYPAwXC4+NMzVpQHeraLSH11jFX1FSjPtcMNmrJWKiwqgI4lHly
         ISI59rpkeL22nVfGDVoLbsFuUbNylBFmHiVNwYC2Lvv3qUB0nusWInvecgXTsUTn/TH4
         MwYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
X-Gm-Message-State: APjAAAWwzV6pFRvT+KWllkPKvVBKpGg4KRv5Tdz/R14ETuSEUITsQysh
	i6fDZCp81kvc8J+gyau7abMLpVI5UD0LRgjN4TSF8I3xfeqAYr2LPZJ4W7U4FUryYFMixHhleRf
	r7Nh+Xar0QKG3CuuygUVYfX/FFu3FBNgcOIdru2uV9Psnq+TBSV6i2bRZLBcOEqI=
X-Received: by 2002:a5d:4585:: with SMTP id p5mr5043029wrq.178.1551915145334;
        Wed, 06 Mar 2019 15:32:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqwgubHwSB3+pqKIyoA2zL4cxRiQy9p0ngRUx+sRElYNUCb+1dks8gYF1ZNuZbU7zcFwZSO+
X-Received: by 2002:a5d:4585:: with SMTP id p5mr5043009wrq.178.1551915144558;
        Wed, 06 Mar 2019 15:32:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551915144; cv=none;
        d=google.com; s=arc-20160816;
        b=k7B54WnM+H7XhJvgW2ASyTJh9A04UnEIRwbiKQiaYqUMWWkDKk8+00iLtHH+Hta8SS
         Mz203ekIy7CSHymKHfmHpI0PRpx0wQvn16d+A2JEiDFxUSCg/X/P7SbSfuuo5dQyRJET
         KIt9JtfKbzq4TILqeQpS59TuHTUq+sNJy5VrvCkxiKXb+2pqiTsq08Fiz0Iu+nYlBcXx
         GgyDzA9/wSxWGDY0FboT4HZ+EeYHSnuT2oC0Dy/PKReT1xlTpBXOQmbhD2TapSXWLPm+
         MrIJwZt53Zd9GYy1i5FtKnuhFXxEc2J57oRYK3ZIHMFs/mQRJtW2Hse6s5T01rcdjrzS
         hqgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iEJdLLdI0p3kQ1WMlPlDYN0voWnGZNKexDZTymL7TBA=;
        b=citkfJFWEx5Jm+kJRo+7oIng7ME+fD0kGtR3xWdbuf9v+a9uln6BoUVLuBW4c8EV4C
         TPuiu8bQvM4aGtGP3tW/QtcXxKq9pWM6YwNHqvIuRkcjSMMKy6hnV2uJbnpszCZbP0OV
         VJqRjxLkSO4UX5Mct1IAyPR1inetf5gOM/kvjr85ctq1fdythNxZOVYhWjTUlMbrpptn
         cazPFtzksluF72XqSQSJht30NB+5KxzhaAaCkzBvFJtYEcjul5ia5jU9mEsJ7u837aM8
         T3Q/CfnDz3HnfZ7GUEfng/QXbZO8ZG5xeNIDatIFH4A5Brbum/l1oHEtB+CmOANlHYGb
         D1Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id v13si1885236wri.42.2019.03.06.15.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:32:24 -0800 (PST)
Received-SPF: pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) client-ip=2001:41d0:1:7a93::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: by nautica.notk.org (Postfix, from userid 1001)
	id 0F7D5C009; Thu,  7 Mar 2019 00:32:24 +0100 (CET)
Date: Thu, 7 Mar 2019 00:32:09 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <jikos@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Cyril Hrubis <chrubis@suse.cz>, Daniel Gruss <daniel@gruss.cc>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
Message-ID: <20190306233209.GA7753@nautica>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
 <20190306143547.c686225447822beaf3b6e139@linux-foundation.org>
 <nycvar.YFH.7.76.1903062342020.19912@cbobk.fhfr.pm>
 <20190306152337.e06cbc530fbfbcfcfe0dc37c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190306152337.e06cbc530fbfbcfcfe0dc37c@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Wed, Mar 06, 2019:
> On Wed, 6 Mar 2019 23:48:03 +0100 (CET) Jiri Kosina <jikos@kernel.org> wrote:
> 
> > 3/3 is actually waiting for your decision, see
> > 
> > 	https://lore.kernel.org/lkml/20190212063643.GL15609@dhcp22.suse.cz/
> 
> I pity anyone who tried to understand this code by reading this code. 
> Can we please get some careful commentary in there explaining what is
> going on, and why things are thus?
> 
> I guess the [3/3] change makes sense, although it's unclear whether
> anyone really needs it?  5.0 was released with 574823bfab8 ("Change
> mincore() to count "mapped" pages rather than "cached" pages") so we'll
> have a release cycle to somewhat determine how much impact 574823bfab8
> has on users.  How about I queue up [3/3] and we reevaluate its
> desirability in a couple of months?

FWIW,

574823bfab8 has been reverted in 30bac164aca750, included in 5.0-rc4, so
the controversial change has only been there from 5.0-rc1 to 5.0-rc3

-- 
Dominique

