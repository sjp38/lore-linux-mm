Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1003C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:48:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72402218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:48:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72402218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24A528E0118; Mon, 11 Feb 2019 12:48:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F9C18E0115; Mon, 11 Feb 2019 12:48:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10F978E0118; Mon, 11 Feb 2019 12:48:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEDFE8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:48:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so10206268edq.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:48:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Woj98bsgbfFSB87xdJTDCcNJHU+2ziEKRxQaytTRy2Q=;
        b=KNhrwXiqbFFnKVnoNMmd/2TAHbW6ufmADkJlN/mi397tc2qeHQTEtMUrREfltjZAOA
         7fl7ZQFEm3kOgh5Vo/OkdDBou4pePhnho4u0RGSjNeqs7iinUOWIIPEZaOzZsiiPHiRI
         UPsjLEeMQjmGYAmm3qm3a+EzJZcHPUuhXnYg/36A80yJ83eJapwSlfv5DdKMJ8jcVqIL
         FssJtc2RBovA8S+NP0YyuicaC8zmdlsxYXidNfD26tCqC2yaoJoRHqjUbC+fZUsP7Al0
         JiFTiwu2zjiPZPB1GSoz0OewMiKOSiVLkPKu+103xtz4XECVYCWPVBrqtOyWfMoqvpz5
         2bsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuaya+q60lwMl1jFVzPbOTx8Y140l3J3TGcDc0fYATsT6SYB15v2
	kWxBSbEkPRMUU4DDLT0sHNMCszkax7Ke2LLLEswP5c4d5sw1gnn0qbKX+eknfB3JyjbLcxgH+eY
	vWsfdi/Fh8mahjv8hbJekT2HlSkN1PyHoFgzs+rm8gw5KZfHku7GxOth7Pc46lpnFEQ==
X-Received: by 2002:a17:906:1553:: with SMTP id c19mr26380814ejd.233.1549907329208;
        Mon, 11 Feb 2019 09:48:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3GScpPnylKPia5OFCCEfDf5pPKsJDPgKGAXQtVL450oajbehfHCSfhMpH+Yu41eWpzaLb
X-Received: by 2002:a17:906:1553:: with SMTP id c19mr26380768ejd.233.1549907328408;
        Mon, 11 Feb 2019 09:48:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549907328; cv=none;
        d=google.com; s=arc-20160816;
        b=Al+TrGZTWyq2oOliW4KfRj+7T8KWc201I+tTQmWB48a6X58+DoCpSRZoq7T8Fei6Dy
         mskEe/H2dvB4rjji0flzfazSopbh+4UVmNmihuha/zpIwvgHxOhJ9Y4U+u5/FvrscDb0
         ZLbSHYi/p7EPwAW729ePWZQnj7vhnCJ+KS8qVU6NvUSgDceDRQfadUm2oNO8tTxNmek9
         ZTH7HY1td05G4Ag4LgzbrqcGIdcaH+kr+J1+qzwNG34/TDW8i5F0cBK3BY+/3WvCMC6o
         tvjg5WA5wBUMAsnj2uEP9jfJXfqOSNP779OPhrSqF+zNEuMpSHtw9+o3yJ+ZVN7FuJTY
         n44Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Woj98bsgbfFSB87xdJTDCcNJHU+2ziEKRxQaytTRy2Q=;
        b=HU0PqDwa3IX2xnBnobIBxlrp/O0fMevL6TtvAy9TP1JXGNrZRM3KGsV/wRy1G1MOMi
         wse6bBupGJMyGH2a3FlHu/HIYAwdDE6l0PZoGC8iagOtGJBZerxCE8HxQ0rAXgTg0cGm
         nBlSuwS4Y/VQEFAxce5WglEL/Mvg7oVMYZwO8CbdlYEmoUof1iAwvAkh7hDf6CRFeAH1
         17kPQ+Ag18gp8+KbaHtWPohrTfWopK9Le+LSwFXiypAv/sTMN4jnMFxBFaUGPYxNQ2zM
         IQkSUe8MEfCZNWNLDzm7RjEXBxxLpZYaKisd0bWO1sBjFwz8P+AEDXu8Q+pzKGACunUP
         GcNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l89si41847edl.64.2019.02.11.09.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:48:48 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83649B11E;
	Mon, 11 Feb 2019 17:48:47 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 857B41E09A8; Mon, 11 Feb 2019 18:48:46 +0100 (CET)
Date: Mon, 11 Feb 2019 18:48:46 +0100
From: Jan Kara <jack@suse.cz>
To: Linux Upstream <linux.upstream@oneplus.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Chintan Pandya <chintan.pandya@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"jack@suse.cz" <jack@suse.cz>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 1/2] page-flags: Make page lock operation atomic
Message-ID: <20190211174846.GM19029@quack2.suse.cz>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-2-chintan.pandya@oneplus.com>
 <20190211134607.GA32511@hirez.programming.kicks-ass.net>
 <364c7595-14f5-7160-d076-35a14c90375a@oneplus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <364c7595-14f5-7160-d076-35a14c90375a@oneplus.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 13:59:24, Linux Upstream wrote:
> > 
> >> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
> > 
> > NAK.
> > 
> > This is bound to regress some stuff. Now agreed that using non-atomic
> > ops is tricky, but many are in places where we 'know' there can't be
> > concurrency.
> > 
> > If you can show any single one is wrong, we can fix that one, but we're
> > not going to blanket remove all this just because.
> 
> Not quite familiar with below stack but from crash dump, found that this
> was another stack running on some other CPU at the same time which also
> updates page cache lru and manipulate locks.
> 
> [84415.344577] [20190123_21:27:50.786264]@1 preempt_count_add+0xdc/0x184
> [84415.344588] [20190123_21:27:50.786276]@1 workingset_refault+0xdc/0x268
> [84415.344600] [20190123_21:27:50.786288]@1 add_to_page_cache_lru+0x84/0x11c
> [84415.344612] [20190123_21:27:50.786301]@1 ext4_mpage_readpages+0x178/0x714
> [84415.344625] [20190123_21:27:50.786313]@1 ext4_readpages+0x50/0x60
> [84415.344636] [20190123_21:27:50.786324]@1 
> __do_page_cache_readahead+0x16c/0x280
> [84415.344646] [20190123_21:27:50.786334]@1 filemap_fault+0x41c/0x588
> [84415.344655] [20190123_21:27:50.786343]@1 ext4_filemap_fault+0x34/0x50
> [84415.344664] [20190123_21:27:50.786353]@1 __do_fault+0x28/0x88
> 
> Not entirely sure if it's racing with the crashing stack or it's simply
> overrides the the bit set by case 2 (mentioned in 0/2).

So this is interesting. Looking at __add_to_page_cache_locked() nothing
seems to prevent __SetPageLocked(page) in add_to_page_cache_lru() to get
reordered into __add_to_page_cache_locked() after page is actually added to
the xarray. So that one particular instance might benefit from atomic
SetPageLocked or a barrier somewhere between __SetPageLocked() and the
actual addition of entry into the xarray.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

