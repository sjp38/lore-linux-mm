Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49064C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06CF221901
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:24:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="W75jKD/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CF221901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900D46B0003; Tue,  2 Jul 2019 18:24:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B12D8E0003; Tue,  2 Jul 2019 18:24:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A0D88E0001; Tue,  2 Jul 2019 18:24:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 412636B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:24:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id p14so177245plq.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:24:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7oMrnJGlcjkfiIrlAgqhI4UBNyxzGYdqpTHy9NfcQFQ=;
        b=eKR41csq0Mo+W2+7t+fOh6g4a5QHK7ZYA55pwBWrknC3FdISEYiVx9Z9UBIuyhnqws
         Xo9KHUidsFwVufcnJj6nVUJOhmBqHjoMjfXAdekEeX9LXstP1lQ4kRIx4oNVJjI0w9ko
         /IVJk9boRVflBbtetn5VIgotRupEmdYT0+Fs4T2qcaZTyj7m1EAhO0fGgMUSneFU7fK3
         sBMSxRTVELibykmyNeIpdDmgH8HRhS3GcyNyYk1cZ3Ks2Di6sBpRHhp7ZUS8uX1A9Gn7
         S1xIcQYtvGhEj3SiFab8Ccyii9144wRRRvEmD4mg+sBaPs50yNEP3wbBH7O5HO1JyzkA
         GZmQ==
X-Gm-Message-State: APjAAAXax0SkBMyEZXs2Gvz7yTw8q6tNRxMDZckq+WM8BHH0EtGgY/AQ
	V5+A8XkcoUCpHInWowz+1/w8oOQ8mz4dxm6NaTaWcj7u1M/tA+Xfv+aoyzd00hQjTBWG9tFKq6A
	/VZ/Gh9zK6pklRJGTHu7e/hTuPXJY0CKfbZnxbhM/QYGw6qxoiEmMYKWWUImud5kPgg==
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr8205723pje.121.1562106250880;
        Tue, 02 Jul 2019 15:24:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhYfGa3BiPhSiep0FYdlWaezfX6cXa3C/Anqsc7Db2VPhhq33PejA4zev+cIFZ6cH+JW2a
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr8205682pje.121.1562106250273;
        Tue, 02 Jul 2019 15:24:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562106250; cv=none;
        d=google.com; s=arc-20160816;
        b=s0IZ9G5qeBgasbGpdg28tL+bc9HdCLzyJQgAZPbrfR76q5r160fmazcSa1XLiWcKlx
         AWbu5lf219Az8UDxqbGYWNlpCCWHELZpb/QU+JVAstb0ugrwqADDKHWo4I2HYr6lRMS8
         Wh2szL+oExN2cR+Rydqg2l0Y3MYkfAK/ZmjBsG5HGtNEA3UoXtDqkW6NLA/UM+Sy3DIk
         lPA+veccN7vkflTVEorcbmXeYPhu/Eko9MVJR/zY8rcE3uqfst2Gwug3JsCEqhG49Lq1
         QxXhBti4pkRZvBJE8jyjxFzVBlRu+WHEE5OfPcJ8SZJMH95Q5kgBwa2QMNBjaX8+45YM
         FLNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7oMrnJGlcjkfiIrlAgqhI4UBNyxzGYdqpTHy9NfcQFQ=;
        b=G7Bf5yQRI+7TzXiftxvMtYLA2ipxjDy8tA8wXJwVegIUDTdT0UOPs+Ia73Yiukx6pN
         vlTBV/PTeF966dk+3HuG7PpbzRSl6nRTcZKlFs8/4o20uVgS+XrunjTDGX1ZdNp3VWy+
         s42XYvGCDGNZ5tEPrfvOmZlexdDJOdl+e7L/Eitz8e0En+sUEwoUOzDZ4wBzM+sqJ80V
         U0kSg0sT6pC+odEtL2Me9pSkZ/M5jP8TYjpEhjhgfKkNzP0+xDOI04lON7Qs9BNDYqmC
         dlYPKyvCcYjRnyVqXxVKkFuhwI64V05TN/JGStgQaKQ12LSSWefKUb8J9TErrWa9vfT2
         CXiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="W75jKD/r";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c11si81263pgk.383.2019.07.02.15.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:24:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="W75jKD/r";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9E41A218E0;
	Tue,  2 Jul 2019 22:24:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562106249;
	bh=paq3rBGRhLW2Qpm44+MevTEqQRAXrHYmPUYx69zxz/M=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=W75jKD/rNzq2PuPQpltd8H0MgbE9WV7KUI0OFTUGJiv4fPwyzhUtfkvdxeVlqOkFL
	 4b4xWxBzPXNyswEVKmLNwRI3tbXoIQnWMp3m/zqn80P3dgemCD1FV6iQddz/Pfn4vq
	 yEgltIRFEizLLcYCPK78BUk8j0MPX6sFGN8Y+qYk=
Date: Tue, 2 Jul 2019 15:24:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Henry Burns <henryburns@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, Vitaly Wool <vitalywool@gmail.com>,
 Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>,
 Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before
 __SetPageMovable()
Message-Id: <20190702152409.21c6c3787d125d61fb47840a@linux-foundation.org>
In-Reply-To: <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
References: <20190702005122.41036-1-henryburns@google.com>
	<CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
	<CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
	<20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org>
	<CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jul 2019 15:17:47 -0700 Henry Burns <henryburns@google.com> wrote:

> > > > > +       if (can_sleep) {
> > > > > +               lock_page(page);
> > > > > +               __SetPageMovable(page, pool->inode->i_mapping);
> > > > > +               unlock_page(page);
> > > > > +       } else {
> > > > > +               if (!WARN_ON(!trylock_page(page))) {
> > > > > +                       __SetPageMovable(page, pool->inode->i_mapping);
> > > > > +                       unlock_page(page);
> > > > > +               } else {
> > > > > +                       pr_err("Newly allocated z3fold page is locked\n");
> > > > > +                       WARN_ON(1);

The WARN_ON will have already warned in this case.

But the whole idea of warning in this case may be undesirable.  We KNOW
that the warning will sometimes trigger (yes?).  So what's the point in
scaring users?

Also, pr_err(...)+WARN_ON(1) can basically be replaced with WARN(1, ...)?

> > > > > +               }
> > > > > +       }

