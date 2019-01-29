Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10CC1C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:03:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B40C221848
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:03:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B40C221848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C02A8E0002; Tue, 29 Jan 2019 13:03:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26D548E0001; Tue, 29 Jan 2019 13:03:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10FB78E0002; Tue, 29 Jan 2019 13:03:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D01628E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:03:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so17481260pfr.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:03:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JU6CzKoN7h3M1TPu9BBtOvO171uZqCsIJNTvg9x4Cjo=;
        b=Lo/sBcA64bsXPIGUmrg7EEQKf9u45XSfoyqwKb/s5Cz+76PQH/MLvWasXmHQ0hdfDq
         R8IHSb6LiiVM2g41fWnYe/YLHayD/Y0B60pOWohgTnDlkk7FdHIlDFncxgicoNxbMBCG
         esIZNd8T9f49e9zihliUEzu94Px73UtPz7bV7JTou8RF5e9pR24BK368k54RfYOyd78I
         +579bqhyvEdy9dimsIEw6FwK4p66ocV1HQZO56VqtZRU+LOJB0jJOcJJlxH7jBF/ZMFc
         EIVWMMvhzrY1jHjBmgptMz4HLC0cgzg4G/viuX5yafvwJSp850bsWTA/9t8Cin8Pxhyc
         a28Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukcDJAmTAbWOzIW9VDBqK9RpJRFcRmdPawTwzACtiUgx0UbhUbyg
	rfgFII6NSeSAaKrGDBsTu63VJlCJ5PCBkgCwC7FPJfDf4pkKxVWed4e0/JS76Qs4LG9V0B+faKk
	eDbkhjb9ton9HToDSOKRurHrJcpLbkVriKhQXujeL/bN9dCsZN1tZPNPGMKrwtO5GLw==
X-Received: by 2002:a17:902:704b:: with SMTP id h11mr27129192plt.157.1548784989466;
        Tue, 29 Jan 2019 10:03:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6bsk0FFHCatwNSb/hmRevB8Zdj2woL1VyRcukB1c15g/demt8lcTSfjMrX4LzKuImOMFue
X-Received: by 2002:a17:902:704b:: with SMTP id h11mr27129159plt.157.1548784988897;
        Tue, 29 Jan 2019 10:03:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784988; cv=none;
        d=google.com; s=arc-20160816;
        b=e/ID6il94C2unndVf0D57hZHrlU9wkA2Hqg/raej0jX7NMvvu38jvWLwCjaGRaPpka
         0gxnIIy9YOA54z1JGxgMFSCPkgELEWTU95gIdFqpjRQI6vTs+FKkGbxUcZXssskoYaN/
         ZUAj0+aR5LRklkJ62GyyQLrEcMGJyJFMH7JQL+ICaFR/7eI4282y/AgZaeVDiikbAgVg
         ZP02hfC9/AkTxM7CHkunci/WoWwfg3MPq3y3Bo40sc1WJbldsJVpXtqBVaY3F8rI0nE0
         ABezRGkwx1eOsHf7Hl45/UGm6tAACtE4TQQp3hqM/vp4gS9RhS86Ox03uwyapMSJTGX+
         zMgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=JU6CzKoN7h3M1TPu9BBtOvO171uZqCsIJNTvg9x4Cjo=;
        b=owjyMI1Vqx4UgA5X6b071ZZp5S+zM+C0pCRHSlQvDniWHYU5ssRUnUKVDbqeP3ZU7W
         OQmsdAjcxF3g1lJrqee91O6vfxJmlfoRRN06A4Rq8MyDacYunEWc6pOaXSKGW5T6sv+X
         o25qb+aWVIYiMcEjPxAtsuhrUgNs/Z8ksnGq8gpeAnLSV/Lvh0QwgAacEGnjgBbiZNNM
         RKIYDwCqQHibuTLbcs0Dr8M9Y+XyK17NYOkYVicSR5Rp+sZ80boEzQAhiUBNajRi2uMF
         jwhfIP2qlU/v0lJ31y0qqDmzCzIKmUf3DwCCy2sfamQdUGw0b2hK4PbBh8vDumdLV5Fv
         bmIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g12si12423928pla.104.2019.01.29.10.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:03:08 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 30C5D317F;
	Tue, 29 Jan 2019 18:03:08 +0000 (UTC)
Date: Tue, 29 Jan 2019 10:03:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier
 <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-Id: <20190129100307.7b6d7346fbfabb9a3fd176c9@linux-foundation.org>
In-Reply-To: <20190129161754.phdr3puhp4pjrnao@pc636>
References: <20190124115648.9433-1-urezki@gmail.com>
	<20190124115648.9433-3-urezki@gmail.com>
	<20190128120429.17819bd348753c2d7ed3a7b9@linux-foundation.org>
	<20190129161754.phdr3puhp4pjrnao@pc636>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 17:17:54 +0100 Uladzislau Rezki <urezki@gmail.com> wrote:

> > > +	resched_threshold = (int) lazy_max_pages() << 1;
> > 
> > Is the typecast really needed?
> > 
> > Perhaps resched_threshold shiould have unsigned long type and perhaps
> > vmap_lazy_nr should be atomic_long_t?
> > 
> I think so. Especially that atomit_t is 32 bit integer value on both 32
> and 64 bit systems. lazy_max_pages() deals with unsigned long that is 8
> bytes on 64 bit system, thus vmap_lazy_nr should be 8 bytes on 64 bit
> as well.
> 
> Should i send it as separate patch? What is your view?

Sounds good.  When convenient, please.

