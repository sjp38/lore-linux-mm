Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 557D0C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14413242F2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="J5/5LwU9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14413242F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8948B6B026E; Wed, 29 May 2019 19:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 845E46B026F; Wed, 29 May 2019 19:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7346F6B0270; Wed, 29 May 2019 19:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0D76B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 19:04:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 61so2561669plr.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 16:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ST294/s4ZqxE7n81JKEoI6VI02qNXiBuMg9fNKsbBkU=;
        b=gTiMOjcBNdTlori7CRrIBxcLwFg9z7t597wURpMhKPfMKPPGL9vKwJzKNF4KjMx/Hx
         ikDnLGIxah4lDNfDZ1jLQpRJhhSjTdYg2xu5Lqr0dtymakDbQxERWkFHXdwqcDI6DCKP
         uZupeC7CK4bzuVe6ID5zVf+Brtaj4jP6zpIHnSw7kg4GnAFiFK5I5O0tjn740VQ3ZctD
         KMP9+VybrXDcZ08BitKjz7QCr1cikNi5m3UDx7JUhKiogJOZ+S+GnJ3iqm+W6pLXFNFG
         uhIF3bssgf4s/j6yumLqMqK9IvScNCq3VL6mCe1vWfhgWjzoTaYyysHmEEJr33lK99Qq
         Cccg==
X-Gm-Message-State: APjAAAV8Nrp0xm25f4zD9qmU+Ov5p47je6iXouRHqdT49H+H+MhIOFPW
	Hm08z19cNawDjmjjy7IoDrYrr0Y6O0FeGooELpJ+RxnJRXsL0UL1WCw4jvptrUjGZ0Ie6xAM770
	tpGu/GETm72eQ6V3pwOX4n6eQzs6elzu/N22yDizZ41uszFwQ/IrLpyI8Qn3SwvCDYw==
X-Received: by 2002:a17:902:b10f:: with SMTP id q15mr493666plr.257.1559171065804;
        Wed, 29 May 2019 16:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz29wATq4FZyjBGuNUIGi7FVfidfFl5K1gG788Wk4dMYzOaAvCksSJDkDYRAIzn+Axjx+93
X-Received: by 2002:a17:902:b10f:: with SMTP id q15mr493580plr.257.1559171065019;
        Wed, 29 May 2019 16:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559171065; cv=none;
        d=google.com; s=arc-20160816;
        b=MJiNbvMGgQR85uGFDYQikfW7qaXxs8bkG1GAVL2Fr5hi3fzn35hoOQj3b0qjaABnfX
         pLFyOCs/SSSVxYS5h9mLIGX2J2jNA231mZ06zQyTKZhNG6Xp3qYIiuNsP6D1q40dMA3E
         1ZkjE3rSJs9ib4lrQr666XzUaSvFa74z18ejIwddkQwfZeLsH3xsfhhmKW0D/bA7r+3o
         rIf2s4sp+lpoJQOnw4KQEKV8ZzySIy0EJG3uF91pNOIfRHMGDa0/STlQJcQ0FoYt4NQ2
         B0HHP+MBrGDwNSq2bS9AufCfS5WqistWHwg+6Bs28Nm9mPz7ibbPZ+cvUu0T+TH4LoHW
         NvVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ST294/s4ZqxE7n81JKEoI6VI02qNXiBuMg9fNKsbBkU=;
        b=e/m5n4DJ5Z4lrRpmSf5K7x1xdXpkUzV6dr6h6Gm54VLLYTpbJKIdudvQ77EsjXkq2W
         mFIy3XSUid6H5heYy+IxFTR9G4orSa/+Hs+fpMJ+uQZhTcqeLI5omHKdQ4ynS6Xm6x99
         gBQSranR8JbJSPApSi5fbomeJkarQuoUMSfFlF3qqNpJIQw9bVShBNXeJDhCMIk6/JHm
         K8zfpxNJXyGiLUiQcaYNwN9cYT02cvbkbuIoxwiUBSjQf0+/HkFQhPjFa6vajw8bRysN
         hMPe6PdNCGuP0Ovgwnx585OfGAWJ/GGhxzJFHVAdxmEIMohdEy19GS3zOvl4asB5Ffvo
         tf0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="J5/5LwU9";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o4si1254774plb.69.2019.05.29.16.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 16:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="J5/5LwU9";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6BC1F242F0;
	Wed, 29 May 2019 23:04:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559171064;
	bh=oBDqryjJwbf+eKGfsPNDnSrh2SFmu1LG/RnDrzCsBNE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=J5/5LwU9Up5uDXPcIuummGAbanpUTGeyzRcshbHohG+Sgag84z5nbIdqSpbcvlz76
	 ID2XyLeVDdEJ0KDcKsz7+DhjmPjsJZUNJbZGftEL9A8/02dI7mtqkjTsB1AD5fPh7G
	 9JMN1wxm3cSAfCCQXjRkO6sMOKqgOfwkqWlzLcv4=
Date: Wed, 29 May 2019 16:04:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gabriele
 balducci <balducci@units.it>
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-Id: <20190529160423.57c5a79115f350c3ebf025f9@linux-foundation.org>
In-Reply-To: <bug-203715-27@https.bugzilla.kernel.org/>
References: <bug-203715-27@https.bugzilla.kernel.org/>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Mel, we may have a regression from e332f741a8dd1 ("mm, compaction: be
selective about what pageblocks to clear skip hints").  The crash sure
looks like the one which 60fce36afa9c77c7 ("mm/compaction.c: correct
zone boundary handling when isolating pages from a pageblock") fixed,
but Gabriele can reproduce it with 5.1.5.  I've confirmed that 5.1.5
has 60fce36afa9c77c7.

Thanks.

On Mon, 27 May 2019 10:12:30 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=203715
> 
>             Bug ID: 203715
>            Summary: BUG: unable to handle kernel NULL pointer dereference
>                     under stress (possibly related to
>                     https://lkml.org/lkml/2019/5/24/292 ?)
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 5.1+
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: balducci@units.it
>         Regression: No
> 
> Created attachment 282949
>   --> https://bugzilla.kernel.org/attachment.cgi?id=282949&action=edit
> crash log n.1
> 
> hello
> 
> since 5.1 I'm getting machine freezes like:
> 
>     May  7 18:00:10 dschgrazlin3 kernel: BUG: unable to handle kernel NULL
> pointer dereference at 0000000000000000
>     May  7 18:00:10 dschgrazlin3 kernel: #PF error: [normal kernel read fault]
>     May  7 18:00:10 dschgrazlin3 kernel: PGD 0 P4D 0 
>     May  7 18:00:10 dschgrazlin3 kernel: Oops: 0000 [#1] SMP
>     May  7 18:00:10 dschgrazlin3 kernel: CPU: 3 PID: 44 Comm: kswapd0 Not
> tainted 5.1.0 #1
>     May  7 18:00:10 dschgrazlin3 kernel: Hardware name: System manufacturer
> System Product Name/F2A85-M PRO, BIOS 5104 09/14/2012
>     May  7 18:00:10 dschgrazlin3 kernel: RIP:
> 0010:__reset_isolation_pfn+0x2cb/0x410
>     [...]
>     May  7 18:00:10 dschgrazlin3 kernel: Call Trace:
>     May  7 18:00:10 dschgrazlin3 kernel:  __reset_isolation_suitable+0x95/0x110
>     May  7 18:00:10 dschgrazlin3 kernel:  ? __wake_up_common_lock+0xd0/0xd0
>     May  7 18:00:10 dschgrazlin3 kernel:  reset_isolation_suitable+0x34/0x40
>     May  7 18:00:10 dschgrazlin3 kernel:  kswapd+0xad/0x2c0
>     May  7 18:00:10 dschgrazlin3 kernel:  ? __wake_up_common_lock+0xd0/0xd0
>     May  7 18:00:10 dschgrazlin3 kernel:  ? balance_pgdat+0x440/0x440
>     May  7 18:00:10 dschgrazlin3 kernel:  kthread+0xff/0x120
>     May  7 18:00:10 dschgrazlin3 kernel:  ?
> __kthread_create_on_node+0x1b0/0x1b0
>     May  7 18:00:10 dschgrazlin3 kernel:  ret_from_fork+0x1f/0x30
>     May  7 18:00:10 dschgrazlin3 kernel: CR2: 0000000000000000
>     May  7 18:00:10 dschgrazlin3 kernel: ---[ end trace 075fb7a28df7d1d4 ]---
>     May  7 18:00:10 dschgrazlin3 kernel: RIP:
> 0010:__reset_isolation_pfn+0x2cb/0x410
>     [...]
> 
> (complete logs attached)
> 
> I started having this during firefox build, but experienced it during
> other build processes (mesa, gcc). The problem always appears under
> heavy load of the machine.
> 
> Unfortunately, the problem cannot be triggered with probability=1,
> although firefox build triggers the machine freeze almost always (at
> random points of the build, though)
> 
> I experience the problem on two twin boxes, which makes me exclude HW
> issues.
> 
> Absolutely no problems when running kernels <5.1 (<=5.0.15)
> 
> In some cases, I got the kernel screams without complete machine freeze,
> but with heavily reduced functionality of the whole system (eg ls
> command hanging)
> 
> Due to the issue not being always reproducible, bisection isn't 100%
> reliable; however the first bad commit seems to be
> e332f741a8dd1ec9a6dc8aa997296ecbfe64323e
> 
> I'll be happy to provide any other file/information which might be
> useful
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

