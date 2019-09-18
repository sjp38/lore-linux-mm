Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D58CC4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 15:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7057207FC
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 15:58:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l0A2z1TL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7057207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FF936B02D0; Wed, 18 Sep 2019 11:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688E96B02D2; Wed, 18 Sep 2019 11:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52A156B02D3; Wed, 18 Sep 2019 11:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7BF6B02D0
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 11:58:29 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B4070181AC9B6
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 15:58:28 +0000 (UTC)
X-FDA: 75948498696.04.birds63_2cda7f172695a
X-HE-Tag: birds63_2cda7f172695a
X-Filterd-Recvd-Size: 4154
Received: from mail-pg1-f179.google.com (mail-pg1-f179.google.com [209.85.215.179])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 15:58:28 +0000 (UTC)
Received: by mail-pg1-f179.google.com with SMTP id 4so69020pgm.12
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:58:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kuawgKYd1ZO4hmm7LLtvr0pa9no04t6i2+r3+Gwk4x4=;
        b=l0A2z1TLXgxmmedq5++QkoO8DwxSNyr+T1b6Mzqo0NATMUz3eiscRJLFqMoH5KhzsJ
         u9dyUkO3k2ighuZYzJxywBe/eWWl+32r/Y/l+o07U5SrYgIhkRDUpBWizrmYf44rKcfW
         frSb0JL/ygJ++bYP1sXMh+kpZRLdaeaqOrdI/M65JpZNmgd9wbmzHPmBIC0V679HJwXz
         zZL+y8vQ7/5QoUQ2EDFCOE62C2B+/gjgcUkTmQf3ZgRU5FPX+w/SU4hPNN6uVQoPWNaW
         gtI/dqGgHOiAXMdvt69Mabmhz8JVgNf/eLcM/b6HFkLdmo2+vmk9W/ZG8OCgkoLXgZhR
         n9XA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=kuawgKYd1ZO4hmm7LLtvr0pa9no04t6i2+r3+Gwk4x4=;
        b=i82MiGMM5ybjBORLOs223LZRU7UvDs1Xh6Uwk/pKg346n3hiMNkG/Y02zFEkFiqJco
         a0kij3qhLR0LVxxwWo2SxyjOjo5K74JB7swGjH7AgLLQQ4VMDLdTusHIZ4oQXd/lXeyT
         uO5plPvCKOqfl+0Fi80uPxpgO86klUT7D/+YBn7qqtdDxPi9wtpWIJ6pzSK4dy1I+ux0
         +ms29u1aCQiCgpgwcMbr/orUmFKhyeDm9RCKzw7SOhVIH3hTs4AKBHPBYC3fFk1dpDsf
         IZMypY3DThqmuQmrTVGaIwdKmwT3l8aWYUb66bbPi6JgRwWdVJnUcS63tZt/jAREfBou
         9wdw==
X-Gm-Message-State: APjAAAUaZKGVcJpbqe9Qc8sjpxS+vj3xDVbRTn/87kiHpuAcDnhtombo
	+ZxXgbGacdrEUoR5cjtrY48=
X-Google-Smtp-Source: APXvYqwl+D35M1mGQ5CVkx5D9cM30xhSLxrYJ8pZoQLGMu0DhVC153jK58vKQJWknJASA2CRgx/Sjw==
X-Received: by 2002:a17:90a:c24e:: with SMTP id d14mr4793076pjx.0.1568822306830;
        Wed, 18 Sep 2019 08:58:26 -0700 (PDT)
Received: from localhost ([121.137.63.184])
        by smtp.gmail.com with ESMTPSA id m24sm5190036pgj.71.2019.09.18.08.58.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Sep 2019 08:58:25 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
X-Google-Original-From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Thu, 19 Sep 2019 00:58:23 +0900
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Steven Rostedt <rostedt@goodmis.org>,
	Petr Mladek <pmladek@suse.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Peter Zijlstra <peterz@infradead.org>,
	Waiman Long <longman@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: printk() + memory offline deadlock (WAS Re: page_alloc.shuffle=1
 + CONFIG_PROVE_LOCKING=y = arm64 hang)
Message-ID: <20190918155823.GB158834@tigerII.localdomain>
References: <1566509603.5576.10.camel@lca.pw>
 <1567717680.5576.104.camel@lca.pw>
 <1568128954.5576.129.camel@lca.pw>
 <20190911011008.GA4420@jagdpanzerIV>
 <1568289941.5576.140.camel@lca.pw>
 <20190916104239.124fc2e5@gandalf.local.home>
 <1568817579.5576.172.camel@lca.pw>
 <20190918155059.GA158834@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918155059.GA158834@tigerII.localdomain>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A correction:

On (09/19/19 00:51), Sergey Senozhatsky wrote:
[..]
>
> zone->lock --> console_sem->lock
> 
> So then we have
> 
> 	zone->lock --> console_sem->lock --> pi_lock --> rq->lock
> 
>   vs. the reverse chain
> 
> 	rq->lock --> console_sem->lock

                     ^^^ zone->lock

	-ss

