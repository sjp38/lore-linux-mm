Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5BF7C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:43:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C70721872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:43:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C70721872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F5BA6B026B; Thu, 14 Mar 2019 23:43:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4BC6B026C; Thu, 14 Mar 2019 23:43:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A06A6B026D; Thu, 14 Mar 2019 23:43:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 540C36B026B
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 23:43:35 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id a73so3416526oih.17
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 20:43:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m1cM0hD0iaSSll7TNk9VjvZsrohSkbKY0TH6w+tjBEk=;
        b=MZNto+0KsFqQj+M9+xHUCzKmqiWhLYuZuUUuQWNZ0RkPctUKpijbiY3iATXLoJLiP6
         H2+O9DYbMYFrgmJbjzEdZPgDaCl+DO+VHBaYMw9CQtFXxbZ/TxcziP+ArRZF5Lb2n1v3
         Io0jWoOhm12f+nhP4GP8PFKPSX6o3wD06JaAZ4yFvAEbnxdmr7lzaWaaGlWjSCBNqBhv
         XVdWB30aSyY11clgJwvK7Iacg5ut4kPCTJSb9wmMsLopljvBHj98/jD1RayqA2bT9Ks8
         q4JGM4a8qByHpmFoPc3imddnAZzVst1Zp65SKkznko28kNodqX919OPzyHx58K01Wx7h
         FbRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAXRKFb05HrL/Ehw55Q7Q9jhU0EEjCTGgl8TZZJ8bnaKhkEYvaXZ
	gxc/B1EGPrPD//saklO8HwH669SGcVbLRCcgTgVgylbZjt8rflPdjt0e+Xc1NkFoOVZG7+bZW70
	FStVzUFYA0hZT2K2fNv5MJGwL77FobcvcYayJZVkYg+3sMi0O5+49huXsgwc4Q8M=
X-Received: by 2002:aca:dec1:: with SMTP id v184mr265982oig.149.1552621414888;
        Thu, 14 Mar 2019 20:43:34 -0700 (PDT)
X-Received: by 2002:aca:dec1:: with SMTP id v184mr265944oig.149.1552621413630;
        Thu, 14 Mar 2019 20:43:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552621413; cv=none;
        d=google.com; s=arc-20160816;
        b=RJk8Sos3Xu1TZVjoYf4cSJb3DlYpVsESLVMwVCVJIFm3N+GMrpwGVmp9szGcGc8ojX
         Jo9i1TiPOIFFmI/sS4Ttc0DAJ4PTFUxX1IxI0uideQlJI/VOYsMrufgTsye3iKqvo2x2
         haIc4ekE7dZyYpRz0LjJ3fygWS/4eJjGemvfgfiCmE9uxP4u59jHy5GsV6rdVN7bu2qX
         V4ES2iNXVGlRyQhlXPZVUw/NE88UwdUpK93Q2qJLjTqsbZBIHlm9SKqcHKYRJPnmq98/
         pNwmd3ct6tibp6FD7hVHrvO1Yq1c0YUjCegQXLRleYxX5Ms/RktUz6LsTK3pEcRJkNEv
         GhyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m1cM0hD0iaSSll7TNk9VjvZsrohSkbKY0TH6w+tjBEk=;
        b=JgWCP2Yl1NJaH7vA7yz4J1HQXnVNmTj2OkfjBnXksE7vixk+nx4Cv4mGE1XpR+4Tab
         cXIHQYo68/HFbW1G2G16u6yIxH0nf3SMHJJ7T2p+N3MaVikcrWTsxmrPDfg84pkltd7U
         dd4DPejVjyOcktwc0XJKzXQKbFlW9hWJm5s3wGjLUEe+obcRPIirIB0wBDah51Ir5q99
         LLhoiM/3YHUgy6MXARCKhA9Hv5Nkzeh836hpV6woUNtTb3OlxYPyWnnN70LYy1mnukbR
         DNSImmz5qoG6R6Z4gaBCZ7dkhpEzoxD9STKBTz7VE0ighHw2VvC9/YgUk34Z3/VB0w8Y
         adgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18sor517858otk.75.2019.03.14.20.43.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 20:43:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxvFJBHD9s4I0eNbzqgQHsFbu7W9iolo8f3gFUJWFxlYyIzoe68S2SHXmshZ12diLwPvICVOA==
X-Received: by 2002:a9d:64d0:: with SMTP id n16mr846588otl.268.1552621413062;
        Thu, 14 Mar 2019 20:43:33 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id i9sm336461otl.43.2019.03.14.20.43.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 20:43:32 -0700 (PDT)
Date: Thu, 14 Mar 2019 20:43:28 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315034328.GA3171@sultan-box.localdomain>
References: <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190315025448.GA3378@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315025448.GA3378@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 10:54:48PM -0400, Joel Fernandes wrote:
> I'm not sure if that makes much semantic sense for how the signal handling is
> supposed to work. Imagine a parent sends SIGKILL to its child, and then does
> a wait(2). Because the SIGKILL blocks in your idea, then the wait cannot
> execute, and because the wait cannot execute, the zombie task will not get
> reaped and so the SIGKILL senders never gets unblocked and the whole thing
> just gets locked up. No? I don't know it just feels incorrect.

Block until the victim becomes a zombie instead.

> Further, in your idea adding stuff to task_struct will simply bloat it - when
> this task can easily be handled using eBPF without making any kernel changes.
> Either by probing sched_process_free or sched_process_exit tracepoints.
> Scheduler maintainers generally frown on adding stuff to task_struct
> pointlessly there's a good reason since bloating it effects the performance
> etc, and something like this would probably never be ifdef'd out behind a
> CONFIG.

Adding something to task_struct is just the easiest way to test things for
experimentation. This can be avoided in my suggestion by passing the pointer to
a completion via the relevant functions, and then completing it at the time the
victim transitions to a zombie state. I understand it's possible to use eBPF for
this, but it seems kind of messy since this functionality is something that I
think others would want provided by the kernel (i.e., anyone using PSI to
implement their own OOM killer daemon similar to LMKD).

Thanks,
Sultan

