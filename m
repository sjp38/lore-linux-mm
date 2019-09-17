Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5631DC4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 00:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05ADD206A1
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 00:53:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JJiE+j6y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05ADD206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D88F6B0003; Mon, 16 Sep 2019 20:53:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6892C6B0005; Mon, 16 Sep 2019 20:53:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 576FE6B0006; Mon, 16 Sep 2019 20:53:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 305506B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:53:46 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DA03D181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:53:45 +0000 (UTC)
X-FDA: 75942590010.25.knot74_5b012cb5f8915
X-HE-Tag: knot74_5b012cb5f8915
X-Filterd-Recvd-Size: 3956
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:53:45 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id bd8so713203plb.6
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 17:53:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bb3WgUuPlwJWlYbzoUQVlukqZNU/xGNNtLsMKZAKSWI=;
        b=JJiE+j6yomdxr6HSuUweYXgimT2ZE+elZD7yXoRYTuhZwLroQjRbf33BiGhl+/ecw1
         Z9r/FP6bqd9jN8I9Hoz4Vl5u/19RTPOqvefNOGfqtSSxMUQu/8SS4r3RmlsaQDPfeJr3
         eeNzl1kYYq0UrvUDshYHOC5YpIERwW8isPEgNbuDlaM7sIIAiZa7ca16WICZguqkcGl/
         aCGcwWn2N++7fdU99NbfKxrTFr5E1tfFIjWIHLe3nrmgh3fIDbxEoE0AREy0Z1g3Z9l2
         IPsMwpB95rnV9lJn6rjxAsdKIj9/lS3sW474ujoVQWbwvmWs2VnYpceyk3kFvGYKReCm
         2gKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=bb3WgUuPlwJWlYbzoUQVlukqZNU/xGNNtLsMKZAKSWI=;
        b=lP53Zfq6If4XsYdKhxyoSOxZpKQHcPqUvmpAbDZ/BEti5Ce8I5CL9xBrniQhBEecpK
         YGZyl4jurfBAy4g4vXgIYIMGvSDjwklz3N0A7EqdVHk2oLKjzMRioDAb54JG7HIo0gXm
         MSnhhLC6pdYZNoP+b7nML6KVZb5WIruVF90G2otnKmZjC9f+vcRExON297IIAqzv61s7
         hKUuczSwDmJsbS2O8BdwJ5lxb3PR/iN3CfavsFKTS0XjWXjAH0vrwBFz72BEsdGWVSY/
         0Jppe3+2CvaDII3CDGbWKxg+El1eEl8lrt3GUzf5llbGjIX6OSOw974tTiDCf1T8unI2
         m0Qg==
X-Gm-Message-State: APjAAAUMNGJ0rd01hpIu6oAC3qSluZgiobG6t66Q/er6wGZl4zQZGZHu
	D/tUnWCqHmtQ6yTVstVG8VY=
X-Google-Smtp-Source: APXvYqxWmGkNGIvP0iApQpIgZ+XbGCgnNGJDgqVmTf07dDFscLXble+QsYvpdfkGJt5n1L26rkvQWg==
X-Received: by 2002:a17:902:166:: with SMTP id 93mr944351plb.195.1568681624214;
        Mon, 16 Sep 2019 17:53:44 -0700 (PDT)
Received: from localhost ([110.70.27.73])
        by smtp.gmail.com with ESMTPSA id bx18sm336950pjb.26.2019.09.16.17.53.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 17:53:43 -0700 (PDT)
Date: Tue, 17 Sep 2019 09:53:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Qian Cai <cai@lca.pw>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
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
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
Message-ID: <20190917005340.GA9679@jagdpanzerIV>
References: <1566509603.5576.10.camel@lca.pw>
 <1567717680.5576.104.camel@lca.pw>
 <1568128954.5576.129.camel@lca.pw>
 <20190911011008.GA4420@jagdpanzerIV>
 <1568289941.5576.140.camel@lca.pw>
 <20190916104239.124fc2e5@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190916104239.124fc2e5@gandalf.local.home>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/16/19 10:42), Steven Rostedt wrote:
[..]
> > 
> > This will also fix the hang.
> > 
> > Sergey, do you plan to submit this Ted?
> 
> Perhaps for a quick fix (and a comment that says this needs to be fixed
> properly).

I guess it would make sense, since LTS and -stable kernels won't get new
printk().

	-ss

