Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 370AEC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 11:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9E932133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 11:03:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mre2L5rx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9E932133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A7BA6B0006; Mon,  1 Apr 2019 07:03:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8572A6B0008; Mon,  1 Apr 2019 07:03:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76FD16B000A; Mon,  1 Apr 2019 07:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 158FF6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 07:03:57 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id p82so2228079ljp.6
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 04:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YiCiS1Zhnbd3fQPNfsi5vJTpnrNw+zSlVcGSn/ESGsI=;
        b=HvH7z3wn2yphfq+YX3f4rHcWYoptdFFAISJR1RVzKaOlj81UGyusANbFFkPs5GL27Y
         tJ9ZXVMJNlBieXdtOIKS/wT20K8B8jMY2wZBLchB0zd8CU98yE9rMe06zJAgRpCtGKRD
         zn2jilLXmO665eO52BKa27JSvXwk5MmIYLn3VeaxWirVWWBRtXNeFxIKCEJhuTppD/PV
         tf86nDfKOnFDWulEzkG+SCsZVK+5MZjZzyZsWNJucfW7rwo1LzAOAliifhBCZ4edRhdm
         1OvO/L2JOW/TaeFCxGQcPJX1rKItrlHLULpv21lirQJWBa3lAr8biAYKN7YGTdciTsEk
         ZZhQ==
X-Gm-Message-State: APjAAAUYi4CkKRjbHxwUrsDvSf6mxJw9dCego4oiUG3WwZOHTT6Hh7qS
	c6m2iZtpvQsNHlNEkWzFpFOf4v8l0RWrJlBtxOyAIbVNaLvQ37Dc/PgzNdmeqXhBOIchypTbUM1
	lMZcOGc6kajr5fluEGe0r2K1NLrhkZF3K/Gwbicy93855X6ofWh1XDy55lcf0EEcMSg==
X-Received: by 2002:a19:a40b:: with SMTP id q11mr32405837lfc.33.1554116636229;
        Mon, 01 Apr 2019 04:03:56 -0700 (PDT)
X-Received: by 2002:a19:a40b:: with SMTP id q11mr32405797lfc.33.1554116635299;
        Mon, 01 Apr 2019 04:03:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554116635; cv=none;
        d=google.com; s=arc-20160816;
        b=peWN5xFtNvwkA0dRzSVQxR9JOixkSpX3c/pqLRLwDV8StRfhlGdhqJpH+W+U+H/hAe
         vVIzFEC7pYDRYUMej+6OEp5IsBxjV2X5fmk0nNjU4GyouF6QcWjK4DEYwNkYS2oKIqjo
         muT5eIfqAmD27bQIU13wELZn+CDGZGoP3+TZrzOadVxSPCjkCHwFvQ5RqmKZPgk/K/7v
         N6A4XzXe/PfUb+u/kzEnbIqGNics71dkEG/f2Pi/OcajTYHv/42N2Iuxt6RjikouYWIq
         zwo09XXVfyt/ZflrVMPR02p5XiadRnf9juQa3yfcs6HOlxB+613gtalHyDZWs27n5/ZF
         5CWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=YiCiS1Zhnbd3fQPNfsi5vJTpnrNw+zSlVcGSn/ESGsI=;
        b=DvqpOYUEJvvb16yq2BksD7X1+kWp5oMNTFInaOgv1k67IJQEz1AQQkIg7sdc6522ih
         MdmnTdNcgg+J0frTgB6v8UF4MlAeHeosIA9IoaeWAoWNN2A3OCjsOkDnO55znO56TTEl
         16yhLNCd8Tx20xx0lMhSZo0IIb91iGVk3xpC71Csmgx86d7s1XjE2SJmGkkhPgIwssiY
         Z6SM6Li9QrBOjziFP7fEOzd6TS3cYjAa0GmbnELsxBPp5DDxQpvJnEICsYKCWcbjRp4O
         wrCymkIFC9Xtr9VlNlweOp3vXfC5kf6aZX1V2udi983iIwmHGNyH10e04t1FTh58uvjE
         SRXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mre2L5rx;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor5146201ljg.8.2019.04.01.04.03.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 04:03:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mre2L5rx;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YiCiS1Zhnbd3fQPNfsi5vJTpnrNw+zSlVcGSn/ESGsI=;
        b=mre2L5rxLZz9BI69ewP/lJ+Cmz8RPbAJDgXxv5x964fEb/LWlH16VYXblgie+iMRf+
         lHBL+6e6AcBNQxg1PiH8xJduAztSln6xOZgEeMDmvlcYv0Pvn5r+Oe+vPTNhIvj8b3+y
         ralhDrCyq7Bnr6MK0PfJvrVeh+6edaXJI/9DMLltCoL04YmCETBWGki8vs/VXPSyYvAa
         HYKVUhX1pDOCzdQXLFHt+7vAH0GmxZluA/jLWl9VbTPtdeOYoEqgX3C7uVAkyvTM3xyn
         fPSWtfvOxwwd/bVIAIM4PFeuCqiFFEhO9Gaf7E4LkfRUBnFuw7yrQjdYuhjL8VrSUcN0
         Lv6w==
X-Google-Smtp-Source: APXvYqzqm+A6vWviSeMyVdsq3PTk8FVZSVOOR+xTIUZVf2V1/IpJfx46V0LxrOwPJU9Jy4R7E4pFYg==
X-Received: by 2002:a2e:96cb:: with SMTP id d11mr9047927ljj.157.1554116634897;
        Mon, 01 Apr 2019 04:03:54 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id w19sm1334465lfe.23.2019.04.01.04.03.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 04:03:54 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 1 Apr 2019 13:03:47 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 0/1] improve vmap allocation
Message-ID: <20190401110347.aby2v6tvqfvhyupf@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Andrew.

>
> It's a lot of new code. I t looks decent and I'll toss it in there for
> further testing.  Hopefully someone will be able to find the time for a
> detailed review.
> 
I have got some proposals and comments about simplifying the code a bit.
So i am about to upload the v3 for further review. I see that your commit
message includes whole details and explanation:

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/commit/?id=b6ac5ca4c512094f217a8140edeea17e6621b2ad

Should i base on and keep it in v3?

Thank you in advance!

--
Vlad Rezki

