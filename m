Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEFB2C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64EF920717
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:17:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JvnVuQ4D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64EF920717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE69B6B0010; Mon,  3 Jun 2019 00:17:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96D06B0269; Mon,  3 Jun 2019 00:17:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86A86B026A; Mon,  3 Jun 2019 00:17:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7FFE6B0010
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:17:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z15so5736423ioz.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:17:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=peq2xV3j8zNOQJyA2LbX3LqEkuEYYsXuOFqRHr6IOqU=;
        b=gNhEmrJ6fm9LZxq+JLiqN5Ae3JiXXY94Y3W6nczKgpYiTasshqhYkcFC8DIMDolIoO
         66VjLRS21y7c7cpVU4gSGImrGT33HhelAhBcYBRgdMo8laaqb4IzGSijp2SuTUZBU2aN
         FDOpH8F7/VylGZW1leEbc4Dfv4DpV2lRc6a2FEQdqZKnUy2EmzjDekcBZMOy1+7Sc1M6
         VslHUGhQpDJSQFI4q8TSWKqW0ofvE72AaS/rCmrWUs2bbriYBLOjUjnG1uzCfnWE6eu1
         8ykqETUPoAUfji1sE9md3RGo1dMTLRnLq+4Drmbk1M/nljw2xM3kWlX1D6qF4CNyrC3w
         pDcQ==
X-Gm-Message-State: APjAAAUkLbnF6OQkgGjh44syxFOltA4JLqDZoaF29dje1fQhHCv0D0Vp
	XSjtkBRNxOWwDy74Q6Jbs6dr8Yn/i2VuCyXQvoDzAilkcsDjKPqp6qQBLziBEKrJJrdy/XQcuoZ
	3DQTlKszD0YCi2j6ichf4BtQfMnI4mDCEJYNp20ANBCa5SjCcjkx9OAszhQVSPDu64A==
X-Received: by 2002:a02:938f:: with SMTP id z15mr15348821jah.108.1559535445482;
        Sun, 02 Jun 2019 21:17:25 -0700 (PDT)
X-Received: by 2002:a02:938f:: with SMTP id z15mr15348789jah.108.1559535444713;
        Sun, 02 Jun 2019 21:17:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559535444; cv=none;
        d=google.com; s=arc-20160816;
        b=BM6vYZV+5sCh41HkEkKo73UoKHJUf/cnpurvuFL9VluLSmaebpeH5QCT+Qr/BgrUhh
         pho9J4XEZpa61IJ4vqfbTGrZic6XLlWZyk9OoMABUc+3Wtmi1zTI3pKnoBlV55fg99nb
         /FclB21l+80NSW/nkhA5Hbkk+ar2wqbpG7jiSp1iUsg0d2YJJVc0wdauC9tcyWfDkMy2
         cwAOS4ru9B1He2S16rP6/VBLLdiz62BHW8JgxxNdBcurftzBrrBpEFDI1LHHIDvdnDhj
         8uFDhaYsqV9Y8Fnr++zA3o27kUYd8J01MKz1OV0npAaqPth5+Q0rBOIJKAiQTBS55MSJ
         LeDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=peq2xV3j8zNOQJyA2LbX3LqEkuEYYsXuOFqRHr6IOqU=;
        b=SY5gBySqUMdqlXoXlPkCKwGU7/pBCDZ5pqUXrmWmx2w/TqsFmOIhG9NiLRt+rzMecI
         Cz9Skk5+mq2kPuur7dVMgtGR9vSzXaT6kIeEX8AjBkgNrXzXxX0o97PqAFMSXowrIX0h
         731Ng52hgjIKvKHejzkXnPiYBpr7Emi/Y8G3v7OiPhxp1lmddxS18EeySZNB4azmQOdT
         AtBgeFMuzgCrG2gX8B9VN9NgNrbO0saXUgWsHQGQYLnGG4HjsTVMqdzXKg6kGpabsrvw
         cx3TtfTUzkb+0Fy0JsJ/IctyY4hWMLcmu+udxYuexvY4VpwhV2CJXpl4fDo/0YYKpd3c
         RA1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JvnVuQ4D;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h71sor809822itb.15.2019.06.02.21.17.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 21:17:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JvnVuQ4D;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=peq2xV3j8zNOQJyA2LbX3LqEkuEYYsXuOFqRHr6IOqU=;
        b=JvnVuQ4DFdCbGb+8Zkv/5rIcwPRGyExzreijPgFZCDf13bLjpWA1pBc9IWKBym8Zq3
         Dci1cuZ6qApdvxMotCr/3WT1QMVvIwyzODuiB7N8fS74ianiMACqbup4doeNor1vXaW9
         K8qsNwrK3e6YPdAJqj906ywET3GPFb0BNLXfufIsz+30ofscGa/T135AsetxqGKwgwIZ
         6xZtbejKj08KOQpeoF3xUvEWXVcP7BUCI4ldDIipUBq6FvopxgB4ToFqrxl5SNgUm7TJ
         YoSAEM6WIJiPz7kGg5b+r9mz0kmSfIrv1xrpSDSRH1T9n2mfdZNXFN32wE/DMYTzYVdr
         k6jA==
X-Google-Smtp-Source: APXvYqzDOjcNERX9CF10zqE2yCDGi7bcANmriTIIlUc06WqLqaxg59EX82ZHvw1lnZvxd2+smyAh3WoWcHvrCLG+onA=
X-Received: by 2002:a24:7cd8:: with SMTP id a207mr6545545itd.68.1559535444067;
 Sun, 02 Jun 2019 21:17:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190513124112.GH24036@dhcp22.suse.cz> <1557755039.6132.23.camel@lca.pw>
 <20190513140448.GJ24036@dhcp22.suse.cz> <1557760846.6132.25.camel@lca.pw>
 <20190513153143.GK24036@dhcp22.suse.cz> <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
 <20190522111655.GA4374@dhcp22.suse.cz> <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
 <20190528182011.GG1658@dhcp22.suse.cz> <CAFgQCTtD5OYuDwRx1uE7R9N+qYf5k_e=OxajpPWZWb70+QgBvg@mail.gmail.com>
 <20190531090307.GL6896@dhcp22.suse.cz>
In-Reply-To: <20190531090307.GL6896@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 3 Jun 2019 12:17:12 +0800
Message-ID: <CAFgQCTv0oef9AX14FAzjB-WsdsNB+vBmjsRoRPKOGP9JfzJhLA@mail.gmail.com>
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

On Fri, May 31, 2019 at 5:03 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 30-05-19 20:55:32, Pingfan Liu wrote:
> > On Wed, May 29, 2019 at 2:20 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > [Sorry for a late reply]
> > >
> > > On Thu 23-05-19 11:58:45, Pingfan Liu wrote:
> > > > On Wed, May 22, 2019 at 7:16 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Wed 22-05-19 15:12:16, Pingfan Liu wrote:
> > > [...]
> > > > > > But in fact, we already have for_each_node_state(nid, N_MEMORY) to
> > > > > > cover this purpose.
> > > > >
> > > > > I do not really think we want to spread N_MEMORY outside of the core MM.
> > > > > It is quite confusing IMHO.
> > > > > .
> > > > But it has already like this. Just git grep N_MEMORY.
> > >
> > > I might be wrong but I suspect a closer review would reveal that the use
> > > will be inconsistent or dubious so following the existing users is not
> > > the best approach.
> > >
> > > > > > Furthermore, changing the definition of online may
> > > > > > break something in the scheduler, e.g. in task_numa_migrate(), where
> > > > > > it calls for_each_online_node.
> > > > >
> > > > > Could you be more specific please? Why should numa balancing consider
> > > > > nodes without any memory?
> > > > >
> > > > As my understanding, the destination cpu can be on a memory less node.
> > > > BTW, there are several functions in the scheduler facing the same
> > > > scenario, task_numa_migrate() is an example.
> > >
> > > Even if the destination node is memoryless then any migration would fail
> > > because there is no memory. Anyway I still do not see how using online
> > > node would break anything.
> > >
> > Suppose we have nodes A, B,C, where C is memory less but has little
> > distance to B, comparing with the one from A to B. Then if a task is
> > running on A, but prefer to run on B due to memory footprint.
> > task_numa_migrate() allows us to migrate the task to node C. Changing
> > for_each_online_node will break this.
>
> That would require the task to have preferred node to be C no? Or do I
> missunderstand the task migration logic?
I think in task_numa_migrate(), the migration logic should looks like:
  env.dst_nid = p->numa_preferred_nid; //Here dst nid is B
But later in
  if (env.best_cpu == -1 || (p->numa_group &&
p->numa_group->active_nodes > 1)) {
    for_each_online_node(nid) {
[...]
       task_numa_find_cpu(&env, taskimp, groupimp); // Here is a
chance to change p->numa_preferred_nid

There are serveral other broken by changing for_each_online_node(),
-1. show_numa_stats()
-2. init_numa_topology_type(), where sched_numa_topology_type may be
mistaken evaluated.
-3. ... can check call to for_each_online_node() one by one in scheduler.

That is my understanding of the code.

Thanks,
  Pingfan

