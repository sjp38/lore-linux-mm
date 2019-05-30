Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F8E9C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59E2A2591B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:55:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WKcka6UV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59E2A2591B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA0CD6B0010; Thu, 30 May 2019 08:55:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D76FE6B026B; Thu, 30 May 2019 08:55:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8CC06B026C; Thu, 30 May 2019 08:55:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A75556B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:55:45 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so2286855iol.6
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZLW1xk6MLnaOhKxjAOhSGRAO81reaAV4lGbib7H9s5k=;
        b=NV/4u3aDz2BDcJFjJzjMa0rYTe/in2tAMkgYy+lGsMQQgAgllUkZaBcVLkggYUWMJV
         dTZqNjTkIf6g6/C/bamynoWLQGl+2iRDPmQxD+KHiqm9dmL+zRImkb3oV4MYRTYfSopH
         JIGTNCIl135ATlDrKe2Wo+1GUaZz9/AZdyPtsaAToSnwIH2z83GWcU6Niv9sPEcXtau0
         Ebb4nDHkXqnvGXeGpJDIFbVaL3lWiFBawPaqabulcBIyAdwdZb2WrSgstu2Df0C6NHhA
         UgwS8jSNrbOCH9cgRrKA2R5twAeENBDGvHC8oh8X7dIejQR+C9vHsxf1eyXhH7Lmzjjc
         hL6w==
X-Gm-Message-State: APjAAAW2JvSMHn9SInROomjp7J2IFAqNpPh44cd+3Gj7VZLwNUhzfjDP
	pJRl5epbYtpFd/2Ow3+gogym3sQqyOhwCoOtMTUc8xHeqFJ6tAir/+0cjLUUP3pCBZ1mFsquTzo
	z+4cTLfgpwK+valwdYXMMfc5Mcz0fRAG8WR8vdfgQXNG3ZBmCiy2TvKJptKCUPBrwOw==
X-Received: by 2002:a02:c544:: with SMTP id g4mr267063jaj.45.1559220945433;
        Thu, 30 May 2019 05:55:45 -0700 (PDT)
X-Received: by 2002:a02:c544:: with SMTP id g4mr267017jaj.45.1559220944551;
        Thu, 30 May 2019 05:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559220944; cv=none;
        d=google.com; s=arc-20160816;
        b=NBHXdKhXeMf+ncI5lpvbsX0J8GsZ/zyGn98OwZdgek7Efa/2sfkBGc2NSZc9D/ry8T
         Vb8TdQ+QHDHjVOLnKLQ9x+QnfshwA3mSem8ZZ7QNVWuCX+qRgOwj+hJFiAHHkkJTh1Kr
         E2A8pNvGxHi8gndEaILQ+mqbhPFqFO+y4iWtFN4FEkzNAeYWIXLF9c6129xIVJ7dZv1G
         pDc4OvlaXhjA75G0z6I2wv0dIRGiunQtzEIaKXwkEqSZmaKDoDAsqg62oCH8GeChseS2
         0U2oa2qnaUoljoUwA8RxUIlD2PZuaK+pt/HfcMZG/2jY858b1Hp2qW9yn+8Tmu5ue8nf
         KtAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZLW1xk6MLnaOhKxjAOhSGRAO81reaAV4lGbib7H9s5k=;
        b=qr60n97mbh/hL6hNStYb1bbxWSPNaeiUWVZu4MZlWOC31SXqu+HfUR0Cm8b7f75bBE
         NMRrCfkjlAV+Ckww/4uTY7KztiJ817yiu0ajxDVHmCiSv59A3O5RS0NMHJJ2hXAazVvN
         YfKfT9K0ZphsbLtHgthB+YmPhH0zIXwzJc+HQSiFlcjG25eWqJCbfhJg+ymo8Pg5lX3a
         Vvs/WK1ZqCcieSH+3AbTaPck8c8TtGp9CpEdOWyF37GWdqR/0G2AcTlylAG+3kJPhJmh
         aZOQ+9rqssOpQ5s7g1YYTLm0hQkiuV7R1vYBIPRwY9e6N/hKbuA22rJe1ci6n1kStDQW
         5Ohw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WKcka6UV;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 131sor3683906ita.34.2019.05.30.05.55.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:55:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WKcka6UV;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZLW1xk6MLnaOhKxjAOhSGRAO81reaAV4lGbib7H9s5k=;
        b=WKcka6UV3NWduPvibld4d8yUqcUyByrokKY6G+iCDvd6HZ36y1aoZiTjlJu2iNaJjx
         azIsFUtD/Yyrqx1Vnz5DtMMvCyzsX9Z1jM/WgMLv02/FcvuQ/R4Kt5mgNxo/D9jrOXNp
         U8dKa6WykLy01iUkWBz/DSJ2+NBSuHEBIk31mV9/GUMPei3V5dd/aNjN3HdPtcCS8YOm
         4x3V8yqinaPyDzV+4YMzdL+wycjLOn71Hve4jnAHCn5bSC5fIFZfl74IMfIm5bxb7Rpn
         Q1aRCH7DY2StscthroSzFSR+CS59v+ozhFpU4/07BhClMyRsRAmn2/tDzTS+W+tiskTD
         1E2Q==
X-Google-Smtp-Source: APXvYqwiaONSUG5G2UwUM9H9pZgzyJ5xk3qr7gpb/QqGbbvw7tYPHcxkMWO22H5pPEWQFhhV0jfdTWi3zocd6DPaZ40=
X-Received: by 2002:a24:2e17:: with SMTP id i23mr2484976ita.100.1559220944233;
 Thu, 30 May 2019 05:55:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw> <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw> <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz> <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
 <20190528182011.GG1658@dhcp22.suse.cz>
In-Reply-To: <20190528182011.GG1658@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 30 May 2019 20:55:32 +0800
Message-ID: <CAFgQCTtD5OYuDwRx1uE7R9N+qYf5k_e=OxajpPWZWb70+QgBvg@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Barret Rhoden <brho@google.com>, Dave Hansen <dave.hansen@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>, Oscar Salvador <osalvador@suse.de>, 
	Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 2:20 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> [Sorry for a late reply]
>
> On Thu 23-05-19 11:58:45, Pingfan Liu wrote:
> > On Wed, May 22, 2019 at 7:16 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 22-05-19 15:12:16, Pingfan Liu wrote:
> [...]
> > > > But in fact, we already have for_each_node_state(nid, N_MEMORY) to
> > > > cover this purpose.
> > >
> > > I do not really think we want to spread N_MEMORY outside of the core MM.
> > > It is quite confusing IMHO.
> > > .
> > But it has already like this. Just git grep N_MEMORY.
>
> I might be wrong but I suspect a closer review would reveal that the use
> will be inconsistent or dubious so following the existing users is not
> the best approach.
>
> > > > Furthermore, changing the definition of online may
> > > > break something in the scheduler, e.g. in task_numa_migrate(), where
> > > > it calls for_each_online_node.
> > >
> > > Could you be more specific please? Why should numa balancing consider
> > > nodes without any memory?
> > >
> > As my understanding, the destination cpu can be on a memory less node.
> > BTW, there are several functions in the scheduler facing the same
> > scenario, task_numa_migrate() is an example.
>
> Even if the destination node is memoryless then any migration would fail
> because there is no memory. Anyway I still do not see how using online
> node would break anything.
>
Suppose we have nodes A, B,C, where C is memory less but has little
distance to B, comparing with the one from A to B. Then if a task is
running on A, but prefer to run on B due to memory footprint.
task_numa_migrate() allows us to migrate the task to node C. Changing
for_each_online_node will break this.

Regards,
  Pingfan

> > > > By keeping the node owning cpu as online, Michal's patch can avoid
> > > > such corner case and keep things easy. Furthermore, if needed, the
> > > > other patch can use for_each_node_state(nid, N_MEMORY) to replace
> > > > for_each_online_node is some space.
> > >
> > > Ideally no code outside of the core MM should care about what kind of
> > > memory does the node really own. The external code should only care
> > > whether the node is online and thus usable or offline and of no
> > > interest.
> >
> > Yes, but maybe it will pay great effort on it.
>
> Even if that is the case it would be preferable because the current
> situation is just not sustainable wrt maintenance cost. It is just too
> simple to break the existing logic as this particular report outlines.
> --
> Michal Hocko
> SUSE Labs

