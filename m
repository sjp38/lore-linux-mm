Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ABC2C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:19:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3DE320881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:19:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0KPtgXBT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3DE320881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 752B66B0006; Tue, 14 May 2019 17:19:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DCEC6B0007; Tue, 14 May 2019 17:19:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57E146B0008; Tue, 14 May 2019 17:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD5B6B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:19:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i123so151077pfb.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:19:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gd/pnIADB9mnwVxFskwGr4PQpavxFmsa/Jk1ovMRRKE=;
        b=OkGXZAfqFCNAIZQ+58bVMYVXvAHznx/R+jYf5ThdmUM9ZYJZcWjc8h0tK/ZReh3lGr
         cCcg400MzqTZzF27lKp02dkwVclbWVtrnwjio97Rc8A9Kk9/YN71wRjhYgWrNIIWiGmi
         7sylwDIor+9kv+/DhCdQFJIYyBTc91ToFaJpq7zSSUPqPG7kK//VWw/H7KvZmfyRu/Te
         tJQ6h13ziI4qIUcsRMKvaLATSte0OY5gUwYms4iHgJGQIusLQGuN3/h6JqSP359wYxUp
         94zQ/OBao6SqfnEoK/9IbMGMOUwrIC8VjvPTYowb2LBn3fdlkYzSyMXuRuQXiURtYOZD
         NJpw==
X-Gm-Message-State: APjAAAV1UvRED03L5NXswbplmdZsyDKXDxqb9lEj29lqgjhL8LTsUD2D
	C5Vxx0jW4w0nQmjwL/ctfmBKs4LEmhLABfrjDFDXWg7kKRtlnYHEfZFBY1EOA027WCf/OLL8d7o
	yE7LPKxOMEu61hkxxC95tUE7ug6sNB1Bu2daXWmIYDsE9gn3Le8/T9ExWJeHtOeI+mA==
X-Received: by 2002:a62:5ec2:: with SMTP id s185mr44327589pfb.16.1557868788672;
        Tue, 14 May 2019 14:19:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDY5ge+xnMBIwp0epLk0njF7M20jL3TbAd6GeXX9eXr5r0zvsvr2Scz6gHTBQLjloA75JL
X-Received: by 2002:a62:5ec2:: with SMTP id s185mr44327226pfb.16.1557868783737;
        Tue, 14 May 2019 14:19:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557868783; cv=none;
        d=google.com; s=arc-20160816;
        b=jya9d3AVpXWrA8/YygPnF9bOBJ6jqYhNuSxjNrqdyKgyQRCsXe7IklNCfrtJOhBNJX
         Z3Re7wGOHxQ+utCwI3rEWIzXu0U8nsEhQi57bwj0wYrVVyPNYAI2W53czyNa72GQebda
         vCP5uyj9/ZwJssu90ftc4dQZjQxRl/Ew3MBJ1C0Sq36454J+5MuwF2CPpAvIe0erAhtr
         vDFBHOoXKjBGGPLeZ0YAk4IWUyyyFJ/zAyrpdX0n6g2DP7dB9pk1vlk8yGG/+bddILkD
         fx+eESUCcWNoBFdK/8YiL7bNKz7DUMY25roswaTi5LVK3Zz8gHXTmYFL6Kn6xFixLOt8
         JS+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gd/pnIADB9mnwVxFskwGr4PQpavxFmsa/Jk1ovMRRKE=;
        b=bbrJys6hJM1BgzS0STrfsiGpGs6d9+b9SAD6+XA/e62E3h24uwpq86mqjAxM3ItolE
         C9IpMRXcax9r46Rurc8VUtgV8atgWCrIzeiFORhp7TOmsu+27nk48VpMv6Bck5FYSFIc
         2R8DYQoBFW5+MhPgg81cw7j3Fmo0bYwSCdwc41W0pflynw5fgho1O1efPytYwNBJVq5J
         Wb17J9tTPrbEs8t1fHY/v7CvNjNviklcM2vf0Vk59/Q9l+YU3LDyAJJoNy/U91lCMdLX
         OQve9L3Z9EFR2e2U9x/SoLax5xJM1927JKIKof1kMwipxlfTfuQR/99cT911Btgjk2JQ
         +NtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0KPtgXBT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a36si20719689pgb.165.2019.05.14.14.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:19:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0KPtgXBT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0503720873;
	Tue, 14 May 2019 21:19:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557868783;
	bh=gd/pnIADB9mnwVxFskwGr4PQpavxFmsa/Jk1ovMRRKE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=0KPtgXBTjx+yxCOJRLdK3ANmNHcVOXoTW0PMbaSNhVwIY58b/mYVCuS1E3gE/DzYK
	 G/uVC89drvDek5hvTDXKgdC8b/+bMQwJTArsj2R3VHtu0RU3qPgqE8XEtV/mXtRfve
	 7EpXicwvGUWjn+Y7wQr18No7iGnqvlNpa0DLoPCc=
Date: Tue, 14 May 2019 14:19:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Message-Id: <20190514141942.23271725e5d1b8477a44f102@linux-foundation.org>
In-Reply-To: <20190406183508.25273-2-urezki@gmail.com>
References: <20190406183508.25273-1-urezki@gmail.com>
	<20190406183508.25273-2-urezki@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

An earlier version of this patch was accused of crashing the kernel:

https://lists.01.org/pipermail/lkp/2019-April/010004.html

does the v4 series address this?

