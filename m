Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7D24C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:15:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BF4D20657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 22:15:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="STIu7ueW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BF4D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08A608E0003; Mon, 11 Mar 2019 18:15:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 010728E0002; Mon, 11 Mar 2019 18:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF2E58E0003; Mon, 11 Mar 2019 18:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86C918E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:15:48 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v8so165048wrt.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GnI0fUcdzJqZU/DTruBcUGekoe8aZHTHc7dj/1D9pDo=;
        b=rraddH2Z8chbMKVpDsmYR2/GHjFgm8f4SVASf+ohvt87qkmyrhb/Q8H0yPqdOY/d0+
         sizAr5FAaHKiE02VUcAH4/qGptI3mlHN/pZ1EwDS3GtQJ+1xSsZ3tbReLNnqgHQufDNc
         3PBcKRsxXBA2Q/Gct+GMiHkJm8RkEyJjs6VnJxmdrvx4c1aXxIjvw7iscGwwwO0ZS7vt
         pOa+2ugpTefnjdS/LIXg2Eh05r/Pt8v81LCn6tgv0LvYqS1v7QlKxkBhjJXd9DBDhX5q
         gof7z/Ro2GObnlno487gyLxJyD0wb+psvd5qPJftAYOkHigANLSwoDcxJAPGUs8+Qewv
         Dghg==
X-Gm-Message-State: APjAAAWdeL3LL+8JuRuRgh9prOgJXSgdeeIDHjj7/8A+pSslK5i3MuyJ
	M38IUu9spomQYvF0e5jogqZ/n4z0m0lkTsfM0HjtfeIvTOr8jAJed97SFgZ0b8gOYfZqEDZArBk
	c5TGYqE8WXyA2AIdd8tK/R2Jg6VsRfEMD1p1KSKNxNjC2zl15gtxKy+mobFEI3RdDDE7R7GVNJo
	GaKW4gYO3fKizSSpY+4AflQUVT0i5zH/OJHb5k3swNIBcHGAZ+JFsg92p315Axs68uDdJBIBANx
	AmFn0ilsBczIBbo4icAOZmUFGfTxwmFQud4I3mU/pv+JVVRC04dnIf+982M9fhLlKhsi4smQ+29
	vBXFRKDRvtbICPtJgNhYbw5oGGyFec3lGA7Hy8SvQhuY05qZKsUVrb4lW34QZsFiwRex3d8wuXS
	c
X-Received: by 2002:adf:e988:: with SMTP id h8mr7450130wrm.260.1552342548134;
        Mon, 11 Mar 2019 15:15:48 -0700 (PDT)
X-Received: by 2002:adf:e988:: with SMTP id h8mr7450100wrm.260.1552342547290;
        Mon, 11 Mar 2019 15:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552342547; cv=none;
        d=google.com; s=arc-20160816;
        b=U+pwo5Ctkh6snVUwH0QVfqdRCeS34bHe7y7zJsM+f5mImaE/ZY2HixI/wZrtV5fayW
         2v5JFRJsd2E0DM4wp2WJCxjlAuVl8l57Z7kUhPgmviGCyIPv3roqC3hWC6DbgUoa8mIc
         KuquXzm3dOYMSVj00ygIOVLsbANh06teKKcchFjsyjPVkwR6mEd9FISumyt5K9TV/K9k
         i+Ua0/HygSgxamQM37Z9MQFMvpO/jzRYBPmN1i8k47Kd/LfjgRqqiL1MAgqq0iM2vOeH
         /TpQYErJjD1EskBSTNoTKWAxqs7KHNAMDwRJvGbwcYZg12wafarY5uX9YECTEf5l2Tt+
         bXSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GnI0fUcdzJqZU/DTruBcUGekoe8aZHTHc7dj/1D9pDo=;
        b=BIBjhvgQJKvUZREFeaoy6aptSUHXt1T6M+VBkyafahzVZD+0MCRMn22QTRcqMeHuv+
         aUDm8oegQf2IwrEYYw761PyrtYExSH9WtAcI88225WRP712mwtr5vrhbB0wdyBIj3G2H
         /UmrQ2474BxoSFTQsZhDzcWW6M1jipHQYXhkHBFe+z+xq9Wvg51/C8nNun83/nqzDb9K
         Mw2u83he5IMt80loUSfb/2/kF7Fc8LLYN/aD/Y2M16/BKyx4ZggFAI2GJcoJ8ZAp9OE/
         ZWyp8px3koHbtvTMKOj5geofi7q4u/QnYGCyhEgFJRiRZXKLoCrE5TcYZ5AygIOpVp14
         eVlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=STIu7ueW;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor4537562wrx.37.2019.03.11.15.15.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 15:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=STIu7ueW;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GnI0fUcdzJqZU/DTruBcUGekoe8aZHTHc7dj/1D9pDo=;
        b=STIu7ueW7L5p2TzqtAmcSxV3KguqBPhLN6KQwuyu1G/VOQH2p4moWrluTFiiebcZm1
         2ophhi5lSUP4fDVmfI0KcWubjRj4LCAlzmeJpYEmsP8nYT5i/q68XwmRJFtefA3K0hda
         59PwzZAiKgBJhKbu6DUDWiNTBR5KSaJ3JNjZLRz3uD2vNTvh2EwFVcQW1x/KYks26Me8
         QAYi7AzGhCn/NCSVOfTrKslxmO1dYD4CN+rMR2EYg6sLjWKTb/33PHxfLgv3BOunhxmf
         RnTqLJ618Y737n7uyVNi0p/Js7fLX03g6gLEgh7tXJqfFwPDOUwY9NPzq6Qblqg0aLsj
         vSOA==
X-Google-Smtp-Source: APXvYqzBPV7OZeaIUoX8OaAcEt5nnkBCXbML20FxMXjDLjGWNCMW1qTFcwXaA28SNy5pChjGUFMWmTrpLR8E9AbMQ+M=
X-Received: by 2002:adf:f80c:: with SMTP id s12mr19405040wrp.150.1552342546588;
 Mon, 11 Mar 2019 15:15:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com> <20190311204626.GA3119@sultan-box.localdomain>
In-Reply-To: <20190311204626.GA3119@sultan-box.localdomain>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 11 Mar 2019 15:15:35 -0700
Message-ID: <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 1:46 PM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
>
> On Mon, Mar 11, 2019 at 01:10:36PM -0700, Suren Baghdasaryan wrote:
> > The idea seems interesting although I need to think about this a bit
> > more. Killing processes based on failed page allocation might backfire
> > during transient spikes in memory usage.
>
> This issue could be alleviated if tasks could be killed and have their pages
> reaped faster. Currently, Linux takes a _very_ long time to free a task's memory
> after an initial privileged SIGKILL is sent to a task, even with the task's
> priority being set to the highest possible (so unwanted scheduler preemption
> starving dying tasks of CPU time is not the issue at play here). I've
> frequently measured the difference in time between when a SIGKILL is sent for a
> task and when free_task() is called for that task to be hundreds of
> milliseconds, which is incredibly long. AFAIK, this is a problem that LMKD
> suffers from as well, and perhaps any OOM killer implementation in Linux, since
> you cannot evaluate effect you've had on memory pressure by killing a process
> for at least several tens of milliseconds.

Yeah, killing speed is a well-known problem which we are considering
in LMKD. For example the recent LMKD change to assign process being
killed to a cpuset cgroup containing big cores cuts the kill time
considerably. This is not ideal and we are thinking about better ways
to expedite the cleanup process.

> > AFAIKT the biggest issue with using this approach in userspace is that
> > it's not practically implementable without heavy in-kernel support.
> > How to implement such interaction between kernel and userspace would
> > be an interesting discussion which I would be happy to participate in.
>
> You could signal a lightweight userspace process that has maximum scheduler
> priority and have it kill the tasks it'd like.

This what LMKD currently is - a userspace RT process.
My point was that this page allocation queue that you implemented
can't be implemented in userspace, at least not without extensive
communication with kernel.

> Thanks,
> Sultan

Thanks,
Suren.

