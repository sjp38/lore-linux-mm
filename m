Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7898DC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 355CD2083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:45:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 355CD2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6DFC8E0014; Tue, 12 Feb 2019 02:45:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B405F8E0012; Tue, 12 Feb 2019 02:45:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2FF88E0014; Tue, 12 Feb 2019 02:45:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9028E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:45:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so557282edh.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:45:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pyYS9Aj8XiNDxjCevuLI2UqSc9KiD8WTOlGk9cD6zqw=;
        b=ZYvpIMJXENAiE5LE95r29R35PhsFi4wVvcL1OD+rN0xkM6UOeIhkr98l6oRzYIIo54
         xLcgwtMmw4ZYXyTvqt4YnJmv6NnkqVcWf+OpBA/V9r9ekd1Etm18SeMEvOgiW4ykGYTx
         +wxUdXrM7sb694g8VeECzHwauIUftk6IpyCYI4fOp3NCbQRbq0WkhNHNXIDkcJHVPA5u
         rYSfvErHFuASaTfsCHKOK9OkI36R5hHr+JmF+jNnHEJ9QyQjqjgHycAL/Vw52YXROqyG
         AvH7/LmQwxo+RBsAT0IeROT2JFqilpZHNz2LXaDNn1i5iLGyWF3ym9gavtrLl2ZR3eFY
         GSSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuZNAJH58GltFjTx2uhNRmJKsyJmPOb2186hDiP954U8ftggAgT1
	Sui2Qm9APZtpcxSIUv2YK2EELFXwTCw7CXImLBvHfdKm7WJRwjHBsVoqVnMg1RwCUtz8aB3Mqgr
	FrLTA8Ol8Rg+jevloHEnMQTsNvS2zqPgEaFAFIyNEno1c4FYC80nCxZ2bZvq18qLbqQ==
X-Received: by 2002:a50:b1db:: with SMTP id n27mr1953557edd.65.1549957539860;
        Mon, 11 Feb 2019 23:45:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYefT/11APIunE7HPaH/xdegKHpOkj8zmOvYVpJkyTdEo8V3reHm9/k7UymZB5auBNe1wmi
X-Received: by 2002:a50:b1db:: with SMTP id n27mr1953506edd.65.1549957538975;
        Mon, 11 Feb 2019 23:45:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549957538; cv=none;
        d=google.com; s=arc-20160816;
        b=aPtjVK8bSWrDipw5CFNS3AbWFEmv1AncFBqxl3B0LQTnUNAM286U4SG5GMUHM5re4K
         fLNUMKMx2askvvMPPN2ddrKjVDQIkn30J8hb33mw4myipBXlILR8LUW8F8l0cGkiR4+h
         OUS1EGIOQspWWOlsyejuNEaJ6hAc7qEsxP6qJjHybqqxnm327AyQtg6sPgG7uO/ev4lN
         wvcFZ4sUamFYCrd+P4iM7ldrGlV6JUs1dvgucYWLB5QfCfY2FsaAF+FnQLTlCzWe2tji
         JlUmk6Qof4ynbcHnfDyFXyIA0It/IpRT2DRXBkXKUU6QA8KyZXSs7F5qDgE6s4f+U2gG
         LewA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pyYS9Aj8XiNDxjCevuLI2UqSc9KiD8WTOlGk9cD6zqw=;
        b=nF4yU9KPD2hdFpaatXO/1UpSunzq/Z69m+DP3gzBwj8IwaVVUmF+FrpSSW6TEXky1m
         EIqdw+YDYZHtNJ5Hkg9unzj+YAbKes/iKvO8oNfBSvUzmT1R2TeyIQvKGO28J+g3vCC6
         2xavejwqCBzb9YRT7ribaJ9KlmAvKo5pEmjed9HV5EGyMhzrz9bFc2akU8i5Qr4ntkxv
         lNi4U0UM+nSMBmM6Q43NRHKObFSGq47uZ3ltUqT5w4nLJ1zPN3u8vIxe8Yii5a3blhrQ
         0N+s67AmDGbArWIzXQxsyoRs4ab+5dmBnMB63Teq+zyQS7W0X+6YWE+820QpN7i2x7oU
         H1gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10si1994956ejr.79.2019.02.11.23.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 23:45:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A2635AE9D;
	Tue, 12 Feb 2019 07:45:37 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 3C5711E09A8; Tue, 12 Feb 2019 08:45:35 +0100 (CET)
Date: Tue, 12 Feb 2019 08:45:35 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Linux Upstream <linux.upstream@oneplus.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Chintan Pandya <chintan.pandya@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 1/2] page-flags: Make page lock operation atomic
Message-ID: <20190212074535.GN19029@quack2.suse.cz>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-2-chintan.pandya@oneplus.com>
 <20190211134607.GA32511@hirez.programming.kicks-ass.net>
 <364c7595-14f5-7160-d076-35a14c90375a@oneplus.com>
 <20190211174846.GM19029@quack2.suse.cz>
 <20190211175653.GE12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211175653.GE12668@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 09:56:53, Matthew Wilcox wrote:
> On Mon, Feb 11, 2019 at 06:48:46PM +0100, Jan Kara wrote:
> > On Mon 11-02-19 13:59:24, Linux Upstream wrote:
> > > > 
> > > >> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
> > > > 
> > > > NAK.
> > > > 
> > > > This is bound to regress some stuff. Now agreed that using non-atomic
> > > > ops is tricky, but many are in places where we 'know' there can't be
> > > > concurrency.
> > > > 
> > > > If you can show any single one is wrong, we can fix that one, but we're
> > > > not going to blanket remove all this just because.
> > > 
> > > Not quite familiar with below stack but from crash dump, found that this
> > > was another stack running on some other CPU at the same time which also
> > > updates page cache lru and manipulate locks.
> > > 
> > > [84415.344577] [20190123_21:27:50.786264]@1 preempt_count_add+0xdc/0x184
> > > [84415.344588] [20190123_21:27:50.786276]@1 workingset_refault+0xdc/0x268
> > > [84415.344600] [20190123_21:27:50.786288]@1 add_to_page_cache_lru+0x84/0x11c
> > > [84415.344612] [20190123_21:27:50.786301]@1 ext4_mpage_readpages+0x178/0x714
> > > [84415.344625] [20190123_21:27:50.786313]@1 ext4_readpages+0x50/0x60
> > > [84415.344636] [20190123_21:27:50.786324]@1 
> > > __do_page_cache_readahead+0x16c/0x280
> > > [84415.344646] [20190123_21:27:50.786334]@1 filemap_fault+0x41c/0x588
> > > [84415.344655] [20190123_21:27:50.786343]@1 ext4_filemap_fault+0x34/0x50
> > > [84415.344664] [20190123_21:27:50.786353]@1 __do_fault+0x28/0x88
> > > 
> > > Not entirely sure if it's racing with the crashing stack or it's simply
> > > overrides the the bit set by case 2 (mentioned in 0/2).
> > 
> > So this is interesting. Looking at __add_to_page_cache_locked() nothing
> > seems to prevent __SetPageLocked(page) in add_to_page_cache_lru() to get
> > reordered into __add_to_page_cache_locked() after page is actually added to
> > the xarray. So that one particular instance might benefit from atomic
> > SetPageLocked or a barrier somewhere between __SetPageLocked() and the
> > actual addition of entry into the xarray.
> 
> There's a write barrier when you add something to the XArray, by virtue
> of the call to rcu_assign_pointer().

OK, I've missed rcu_assign_pointer(). Thanks for correction... but...
rcu_assign_pointer() is __smp_store_release(&p, v) and that on x86 seems to
be:

        barrier();                                                      \
        WRITE_ONCE(*p, v);                                              \

which seems to provide a compiler barrier but not an SMP barrier? So is x86
store ordering strong enough to make writes appear in the right order? So far
I didn't think so... What am I missing?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

