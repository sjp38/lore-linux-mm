Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851CEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:37:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5422147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:37:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ay/7cip6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5422147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBDDD8E0003; Tue, 12 Mar 2019 10:37:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6D168E0002; Tue, 12 Mar 2019 10:37:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5BC98E0003; Tue, 12 Mar 2019 10:37:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E55B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:37:12 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b9so1129216wrw.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:37:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iRTF81XNeQwjJa5bhQu6Xf+1EuYh+2bPe7EUzUpU52g=;
        b=KdHPrSubV7InEHyW7vOT0xyLp9ShfTAhjhJf4X2nQHdvNhMv0k46k8yp8RVeeNiGTR
         torkq6w69K/uUNEsOotZluUI1Kk0mDqBN9fz1LD+sbGr8UTgSIOexCcoy1FGUoBqLVy3
         o9pm2w+untANSc8AuSLPVxsIDQtqtQU1TeMIumdr5b7owvZeYECp7LVSkeqQnpsYsnUb
         4v25Gx1+8/I0IXOKyJoz4w0RG/JON/LkeMPlgSYmNgnXD2Rqdr76d8JcuKOfXC7OLGW8
         qEp3Migo+ctrfnJZBF2tmH4XohyXkQ+wsT/WuByjKXDf/3AcGCJUNcPsWKboktP2VnND
         KbZw==
X-Gm-Message-State: APjAAAWL1AoKGxhNBopi/ZmN31WkikLXZK8YglHu2CETXQAUXK7KTR/X
	UUBumO19uA0SyZf0R+msfNkCLCZ8NuqFTAtD9EgH+MOy1UcLZevoeQ+SJk8PkKo6i8M1OrzET7W
	SdZrSmn/XFCKdEao4yuGeX92JNMUFHR3QZK4bhrBXmkTsiuApfZ/UgAW2LdSxkV6G6COJwwq3yv
	J9tb/pRJIumY5TkhPqE2+pJFJReARUWzrZ66ogyzJCLzC1pSRNwLNlgaCKtz1TABqhqGJ9oywOh
	rhdoWZa0K0iikMpa402IEEjhYbg7xBvbvM6Wd5oYpfDaD11zZEWDncINM3j0RZag22dGEhqCnJJ
	T6bOY4QR4KJnd6P6QAbZ2hI+5Wn96WIduPlUxfqfraRqw+Fr4eozMoHq/QGsP/ongsaHXpqEs/s
	0
X-Received: by 2002:a5d:45c8:: with SMTP id b8mr5566421wrs.3.1552401431941;
        Tue, 12 Mar 2019 07:37:11 -0700 (PDT)
X-Received: by 2002:a5d:45c8:: with SMTP id b8mr5566366wrs.3.1552401430983;
        Tue, 12 Mar 2019 07:37:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552401430; cv=none;
        d=google.com; s=arc-20160816;
        b=cclQEvbrwLQHRqqn3t4ew+370EceKr3nnwoVFqWeegcQNE5Jm4nFwzDBHSDgDBMm0u
         9r/pGbzgd8x4bW+AYeK+B147cztcG0DBbuRZ1seb9RicZCYZpsFH3SzereTdCrlCJE9e
         4o4nXLtUoPErczlijA6HvgEKsrM/Nh0p0A96bNJHPiERYf5F17la6Tzuyop1nRDfOiwd
         qB6ZYeYVQ7C7hFxD0RP+T5MqPr//7wojmAguV5GkBQwTUg/s5/OruH7CshnG0RUStpco
         BTRSmtnaCgiawlicT5Axl01EhVCISOBaIXXwNt5w+kBGWVemsToIS+z4YoOWDfatM+NV
         mQVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iRTF81XNeQwjJa5bhQu6Xf+1EuYh+2bPe7EUzUpU52g=;
        b=dmRoO0fxW4SB8L4IP4NCS2qWPZrod7bl0b5sa4krcJbX/Hx32bWgHTk+ycle7hQaNH
         us6Qhh3OAxex7OU5Mhvm0zSM8zHTeWHHZIV+ccH9Qhu8m+LvyzIzdNLhpuUaoiLYsP2Q
         dCE3nDk9Jk9l0YkC9PEJnfPB9rm2whL2tPfAHxwd27N7SXEO/ZsJ/uWlHg9pS9mV4jR5
         q0eLdX+SK58j0d4fiMVNbREVMTN8J0CjVCSBdv2HXZYNB5qXh8lGrdAtkTPqpujZD9sw
         mjyuMOLM9GLIjLOfWP4Kvegjy23+R0R49+MfsG8eYgLOw8w3z8hDSdAScOfwfcUn7BvL
         p4UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ay/7cip6";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor6049204wrq.49.2019.03.12.07.37.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 07:37:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ay/7cip6";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iRTF81XNeQwjJa5bhQu6Xf+1EuYh+2bPe7EUzUpU52g=;
        b=ay/7cip6wu0tI10WzvwNE1MQAcjNhmixLZczxHyaG4Qkg8wYfW/JogftocehntIDSj
         5Nm/JJP8ToZSt/XDPlYpoKnUhKdQ1n+dgSgTwQj0/x/q00TtdQWBtcUtT6aQsMzL9eqC
         Eg1mR97fXDxSdWAQQ7FCiaO+Eg/+tiyrdClDdShzvVbTlyNwQLnA5Ko97ineMWhykWGZ
         TzuYE0yAB/K/v8t7Yaog6VeB5o4taXmzw1DOR44DsgcLuvz4OnmXa8zgEzq544B0B/ww
         oTIr01rd8och48LGaqWz+QImRZrRRQ1IauwVECxswlnjwuaKQNaUohZJzW2zNVqg8PKX
         eYQw==
X-Google-Smtp-Source: APXvYqxxDHcCV4tu5+bbr5nTTs4Fjpw4uzgDe4ZydUl+ewLp7rm7wgfT68Q7s24XlcwrVqOLXHNgARRYtsPNzWpe/iA=
X-Received: by 2002:a5d:40c5:: with SMTP id b5mr24653747wrq.107.1552401430345;
 Tue, 12 Mar 2019 07:37:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
In-Reply-To: <20190312080532.GE5721@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 12 Mar 2019 07:36:58 -0700
Message-ID: <CAJuCfpFToMiU8pyjA5QDduG0V8-UZSq1EesstFRUC6_YvbDDQA@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Michal Hocko <mhocko@kernel.org>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 1:05 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 11-03-19 15:15:35, Suren Baghdasaryan wrote:
> > On Mon, Mar 11, 2019 at 1:46 PM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> > >
> > > On Mon, Mar 11, 2019 at 01:10:36PM -0700, Suren Baghdasaryan wrote:
> > > > The idea seems interesting although I need to think about this a bit
> > > > more. Killing processes based on failed page allocation might backfire
> > > > during transient spikes in memory usage.
> > >
> > > This issue could be alleviated if tasks could be killed and have their pages
> > > reaped faster. Currently, Linux takes a _very_ long time to free a task's memory
> > > after an initial privileged SIGKILL is sent to a task, even with the task's
> > > priority being set to the highest possible (so unwanted scheduler preemption
> > > starving dying tasks of CPU time is not the issue at play here). I've
> > > frequently measured the difference in time between when a SIGKILL is sent for a
> > > task and when free_task() is called for that task to be hundreds of
> > > milliseconds, which is incredibly long. AFAIK, this is a problem that LMKD
> > > suffers from as well, and perhaps any OOM killer implementation in Linux, since
> > > you cannot evaluate effect you've had on memory pressure by killing a process
> > > for at least several tens of milliseconds.
> >
> > Yeah, killing speed is a well-known problem which we are considering
> > in LMKD. For example the recent LMKD change to assign process being
> > killed to a cpuset cgroup containing big cores cuts the kill time
> > considerably. This is not ideal and we are thinking about better ways
> > to expedite the cleanup process.
>
> If you design is relies on the speed of killing then it is fundamentally
> flawed AFAICT. You cannot assume anything about how quickly a task dies.
> It might be blocked in an uninterruptible sleep or performin an
> operation which takes some time. Sure, oom_reaper might help here but
> still.

That's what I was considering. This is not a silver bullet but
increased speed would not hurt.

> The only way to control the OOM behavior pro-actively is to throttle
> allocation speed. We have memcg high limit for that purpose. Along with
> PSI, I can imagine a reasonably working user space early oom
> notifications and reasonable acting upon that.

That makes sense and we are working in this direction.

> --
> Michal Hocko
> SUSE Labs

Thanks,
Suren.

