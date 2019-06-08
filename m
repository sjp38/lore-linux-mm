Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4303C2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 652E4204FD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="RzikS2kk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 652E4204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED6616B0273; Fri,  7 Jun 2019 21:47:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E87056B0275; Fri,  7 Jun 2019 21:47:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4E546B0276; Fri,  7 Jun 2019 21:47:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B17EB6B0273
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:47:22 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id o4so3163289qko.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nc6xGH604Ibjz1J23Rb+p/HSbXggztW0x+56PG9xNfU=;
        b=EIn4g7LyOPb475VLqVhBz1b0uKQei9avpK2JozWU1HlMo5jfbnrIcLul7Qs5fQsJkl
         Xi7FG57wv1CEdRcu30MB3SZg1qt8QpeBLC9DdeONZ7n3I3XuhICvenAmB8akXzCK5pJG
         PKW4Wi87rXNsLvbItcx7ceD00R0hxga3WuxUA+2m3RGiR9qbIJcoFOFaZMK5+OYrKeaK
         yIgkBvrqo2m3v/mUPYZaMtRQk5Y58ZcbCF4KU95xNk5lxIMP58eFWq9xDuLGNFf+Jb7T
         h2eugJSWiRWwWMsHBDxrM3SOabEXod6xPoL2t9FZY5HAmIlGp2LseYz6oNbQedj/7h44
         DmMg==
X-Gm-Message-State: APjAAAVHkHOGerCZaAtFKxJ83ks2E8bRXvKc31Cv4zvFYTBilfbrloW9
	ef9gIF5KB9qdW/TDhcUf45wcQNhJ/SCSSgJ8sa8qz9m4WXBrO3hw+vB5Rac7pH1/t8c4GzMfmBY
	6yOWdyrCWeI7KtVc9761HkF9yoYb6NppJHZj7RnEuRscLeSWAuNn5PaOUrwibSLGq+w==
X-Received: by 2002:ac8:2998:: with SMTP id 24mr47197656qts.31.1559958442472;
        Fri, 07 Jun 2019 18:47:22 -0700 (PDT)
X-Received: by 2002:ac8:2998:: with SMTP id 24mr47197634qts.31.1559958441766;
        Fri, 07 Jun 2019 18:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559958441; cv=none;
        d=google.com; s=arc-20160816;
        b=oFdsii+To+kNiVqjkVoblRDx0wIHmfXw4lmSJTKxuQS1gOV1/02NmE61c7NH7AAoaA
         A+2Aw9zty28aRLZj6C7lxR+NdrMTXCdeBASyAnE4yXLTBXHph11r607sM1smTR+llSPu
         VWRQN3Tac4mBP7ft0Z58N6dMObaMdB9ZW9Va5t0+4X3jgV1oveMAeZLtXEN071FoXiB2
         hs5dv6udJyQ/65hHo9Rm3iDN+/qbzG4DS/cAqFlxMykXIvf1KyO9+wLGt7+xmGnbRnYK
         G2rUTKgS29LF76eGcGKPh9kX0tKU+cM8R+qvVob0UmTZcqgVQ+Z5AL518C0MMailc9mJ
         QaOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nc6xGH604Ibjz1J23Rb+p/HSbXggztW0x+56PG9xNfU=;
        b=T6geM/HwmtH0WYJ32rF/aHhTVwTF86zD70COWiJCPG3BQrCFkC2O468OQF0FFJgFPb
         jnEXC0P34WVMnOA5VuVQF3SaEnrr534iytoKagqsI984vE3Ly/QAb7HABRYtFxYf8+wr
         1tqHM/VQvDQsYQEUODwycEXYM9ap+9ifyOIiAaNFNCkvwZF2PnWuVLVa8l3UzLRy7BdI
         vVrSUw999s5lE1sBnK7/T5WMYrEk993vJpRYcn5LxGvJOpxnWrIPE5JT12sB7S9ER0wC
         VOMD5cH/pLXmE4jRuTT4BJ1WPrYIIf/iqdRWbcrRly8y+VgNsvFs+YqQEHHJcVwaV7LP
         yipw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=RzikS2kk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor2092928qkj.126.2019.06.07.18.47.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 18:47:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=RzikS2kk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nc6xGH604Ibjz1J23Rb+p/HSbXggztW0x+56PG9xNfU=;
        b=RzikS2kkWB0yrELIxgOKLXI7n4K6BJfDButHAVBC/ZMtnKj9yRR01Gnk1MX5Wvtry3
         kC7LOlMabScS8+6SgA690KRqkMx4YF/wk5KRtrM8TUpQIPevIFuD9RLh756wG5jzrO0u
         bszQkMJEE+oGUuSRlcoJcg81LGTFNkoJQzy6/hRMAA2ruxbSXL9D1pPwzRGFl89qiHD8
         bFLVrpGj4wTlH/KA7c/LZKJAdoc5Ll+42EURexdS0k7qha7cppex+m6A9m9qANDBZwGK
         ZC2QbDqv7tCrDTHZw0yqwsuUkrQHcVWL95VP2Zxvnz/oWzhVXifsSAXOWXXRMR0JbrBC
         I82w==
X-Google-Smtp-Source: APXvYqzJ0Y9PkmyZQUNKepOagJid3O/yJSUEccWesudwHooEMgZ4TRfl4qAnoz7gxWh5y3LkbErzsw==
X-Received: by 2002:a05:620a:1285:: with SMTP id w5mr37337035qki.302.1559958441410;
        Fri, 07 Jun 2019 18:47:21 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m4sm1851701qka.70.2019.06.07.18.47.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 18:47:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZQS0-0002Fo-D2; Fri, 07 Jun 2019 22:47:20 -0300
Date: Fri, 7 Jun 2019 22:47:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190608014720.GC7844@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
 <20190607191302.GR14802@ziepe.ca>
 <e17aa8c5-790c-d977-2eb8-c18cdaa4cbb3@nvidia.com>
 <20190607204427.GU14802@ziepe.ca>
 <ba55e382-c982-8e50-4ee7-7f05c9f7fafa@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ba55e382-c982-8e50-4ee7-7f05c9f7fafa@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 03:13:00PM -0700, Ralph Campbell wrote:
> > Do you see a reason why the find_vma() ever needs to be before the
> > 'again' in my above example? range.vma does not need to be set for
> > range_register.
> 
> Yes, for the GPU case, there can be many faults in an event queue
> and the goal is to try to handle more than one page at a time.
> The vma is needed to limit the amount of coalescing and checking
> for pages that could be speculatively migrated or mapped.

I'd need to see an algorithm sketch to see what you are thinking..

But, I guess a driver would have figure out a list of what virtual
pages it wants to fault under the mmap sem (maybe use find_vam, etc),
then drop mmap_sem, and start processing those pages for mirroring
under the hmm side.

ie they are two seperate unrelated tasks.

I looked at the hmm.rst again, and that reference algorithm is already
showing that that upon retry the mmap_sem is released:

      take_lock(driver->update);
      if (!range.valid) {
          release_lock(driver->update);
          up_read(&mm->mmap_sem);
          goto again;

So a driver cannot assume that any VMA related work done under the
mmap before the hmm 'critical section' can carry into the hmm critical
section as the lock can be released upon retry and invalidate all that
data..

Forcing the hmm_range_start_and_lock() to acquire the mmap_sem is a
rough way to force the driver author to realize there are two locking
domains and lock protected information cannot cross between.

> OK, I understand.
> If you come up with a set of changes, I can try testing them.

Thanks, I make a sketch of the patch, I have to get back to it after
this series is done.

Jason

