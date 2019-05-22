Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B19BC072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 07:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0184C21019
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 07:12:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ypw8yEs9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0184C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92C3D6B0003; Wed, 22 May 2019 03:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B57C6B0006; Wed, 22 May 2019 03:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A5416B0007; Wed, 22 May 2019 03:12:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5897C6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 03:12:30 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id j9so1233947ite.6
        for <linux-mm@kvack.org>; Wed, 22 May 2019 00:12:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8vwel+zwag9MFfHBTELr45/BZVK9Oekk4mSSY15WVJg=;
        b=Q7aZQ9afZLFpUtaBGXSJW/SXy8uh7dY2pPRmPhE+KHC2J3HNMIYMMFY4oJz/f4hiqn
         dZG7T9T8CJCknnq1sYK7iFUnDv7/ZOFinOaG1urlRjLPFxIA5BTo15/0mxLqewN/xtN+
         kVa2gJTRAjzLiLpQMo0DFfjSbk7t5k+gC3bRxkmAHs07IBH9LD6sNkyQ++/OBgON4N8E
         7PTlQhIfk1L6xNW0GaTfpd9D7Wkp0Tqy4jMmru53wH8CkjNpY0XKTMxGgMkAmej9GYF7
         cxDVe73eIdYTEg1T//vfXhBQyqZ7xdtVYV2z5wzOW8NJ+vnQjxXCZrpirCVdp9tZROqP
         jKCg==
X-Gm-Message-State: APjAAAVYqgD9wI9O4jq0wUuu+ewt5o8OtBKOBp2zc1W5QVmXx31JGIhw
	rxjjHXz3zm1sgQKfummQLSE1G/0JoqBOcMZTBOyRVXqIh0SyBBEGeUzubNOT1RjomaVapf4MnMq
	Dp6zZq9utHYzUIP0Xihs6ukof8E1wIBYIJJ94TjyDcnvrTBlvUnVBnJtImGoCRs10ag==
X-Received: by 2002:a05:660c:acd:: with SMTP id k13mr7189320itl.13.1558509150100;
        Wed, 22 May 2019 00:12:30 -0700 (PDT)
X-Received: by 2002:a05:660c:acd:: with SMTP id k13mr7189278itl.13.1558509149257;
        Wed, 22 May 2019 00:12:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558509149; cv=none;
        d=google.com; s=arc-20160816;
        b=wDABQCi8wy1wZ7LaAclH9XCIRd1Trsiq2uXQqqiqqNs7M2LwAdqk8BzE6yIgpcmMKN
         Pdgd0JHM7maM2s3UJ/Mj+lM1W5yC2B689QmRrge2OwX1wMfHCIzSGgSkF+3rc6gCs8ao
         c0400fW70QS+hu+kXmAJbdtIrzHzoKPaPqdqZz7feGccJnP8Z+lf13VTdPZsyLtVKO0+
         5xadozGUT1B2CZo6x2GaL3KbrsmAkG6BelRe5CuRDYeANc6acuBLhJvNl9/5StqshpAS
         XJGWJXex+tcKaIY65+AuWeob2j9HfNsUal6PACkrah5QBzezStKR76bF7n9c0LIN0Sja
         fuxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8vwel+zwag9MFfHBTELr45/BZVK9Oekk4mSSY15WVJg=;
        b=X/qZM1WHKjbEXCn0PvDhNjUJaG7Z/gZGQ1vo5Dx/GsN6M9eiqppsBm30CF3jdm0RAK
         zuhMisITyn11djqvGXI/1FRE/G7UEcv/EiXbeDNGZos8GnrMN5LC8anGGTzBzByY8BVf
         Bp0Hx+nYEfjY0Gm3GsGxRUBpcOe5dVrmPdDE95GzDdk0U28bJd68IhiYNSw3WxZXwnS7
         uffUwagKTfi9srq4cfGzxnte3YHr8MLYf4onfGrbdxfRbZFXmzIijuPx7G9TxA663x5e
         81c9KaYRDKPwYgc7Bspkp3r7tH08fAfZqmGPcPvp9mzLi+U9ULX5sZN0/pHA2IOsdYKF
         PEbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ypw8yEs9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d21sor11518919ios.138.2019.05.22.00.12.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 00:12:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ypw8yEs9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8vwel+zwag9MFfHBTELr45/BZVK9Oekk4mSSY15WVJg=;
        b=Ypw8yEs9+N/DwH4Nk2+N2fjbqKHdQi0sMhhUtPfBdUjN2F4BzT2clYTmORyG2Kr7wB
         W4GT1RPKIrPiHh7GadeZL0gjHjMLYRWOYNI0g1ijIf4EUE16zPn2Gkh4jmAnobNIT5Rn
         jEMygTrNUPeoVUvlU8OkYUJ5IEuPQFS42Y/Jojm31waQL6Y3NjrgyfVTZg7eJkfC25Gq
         VM4Eh4xvbA+mMIjA2RnNvHjMs/2ZCzYsdmLV0ISKJgBaKjxAQdSOT378vZCoyJdwRmYZ
         +NOxel15VokkCm54AsDI8LE6YG30Eew02hwTeJEHRftcvm3D4hhFHU6YfVI5Au4R6CIa
         GcTg==
X-Google-Smtp-Source: APXvYqysSAZTTEffDQnX7pBKnPa6xDrJc+Smh87dFhgghcan6XQ+nNeaICcIJ6iMQbzKeYVURwHRu3RWQoTAE1j4NuI=
X-Received: by 2002:a6b:7006:: with SMTP id l6mr22293884ioc.161.1558509148849;
 Wed, 22 May 2019 00:12:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw> <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw> <20190513153143.GK24036@dhcp22.suse.cz>
In-Reply-To: <20190513153143.GK24036@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 22 May 2019 15:12:16 +0800
Message-ID: <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, brho@google.com, 
	Dave Hansen <dave.hansen@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Peter Zijlstra <peterz@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>, 
	Oscar Salvador <osalvador@suse.de>, Andy Lutomirski <luto@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 11:31 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 13-05-19 11:20:46, Qian Cai wrote:
> > On Mon, 2019-05-13 at 16:04 +0200, Michal Hocko wrote:
> > > On Mon 13-05-19 09:43:59, Qian Cai wrote:
> > > > On Mon, 2019-05-13 at 14:41 +0200, Michal Hocko wrote:
> > > > > On Sun 12-05-19 01:48:29, Qian Cai wrote:
> > > > > > The linux-next commit ("x86, numa: always initialize all possible
> > > > > > nodes") introduced a crash below during boot for systems with a
> > > > > > memory-less node. This is due to CPUs that get onlined during SMP boot,
> > > > > > but that onlining triggers a page fault in bus_add_device() during
> > > > > > device registration:
> > > > > >
> > > > > >       error = sysfs_create_link(&bus->p->devices_kset->kobj,
> > > > > >
> > > > > > bus->p is NULL. That "p" is the subsys_private struct, and it should
> > > > > > have been set in,
> > > > > >
> > > > > >       postcore_initcall(register_node_type);
> > > > > >
> > > > > > but that happens in do_basic_setup() after smp_init().
> > > > > >
> > > > > > The old code had set this node online via alloc_node_data(), so when it
> > > > > > came time to do_cpu_up() -> try_online_node(), the node was already up
> > > > > > and nothing happened.
> > > > > >
> > > > > > Now, it attempts to online the node, which registers the node with
> > > > > > sysfs, but that can't happen before the 'node' subsystem is registered.
> > > > > >
> > > > > > Since kernel_init() is running by a kernel thread that is in
> > > > > > SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> > > > > > during the early boot in __try_online_node().
> > > > >
> > > > > Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
> > > > > drop try_online_node from do_cpu_up? Your v2 remark below suggests that
> > > > > we need to call node_set_online because something later on depends on
> > > > > that. Btw. why do we even allocate a pgdat from this path? This looks
> > > > > really messy.
> > > >
> > > > See the commit cf23422b9d76 ("cpu/mem hotplug: enable CPUs online before
> > > > local
> > > > memory online")
> > > >
> > > > It looks like try_online_node() in do_cpu_up() is needed for memory hotplug
> > > > which is to put its node online if offlined and then hotadd_new_pgdat()
> > > > calls
> > > > build_all_zonelists() to initialize the zone list.
> > >
> > > Well, do we still have to followthe logic that the above (unreviewed)
> > > commit has established? The hotplug code in general made a lot of ad-hoc
> > > design decisions which had to be revisited over time. If we are not
> > > allocating pgdats for newly added memory then we should really make sure
> > > to do so at a proper time and hook. I am not sure about CPU vs. memory
> > > init ordering but even then I would really prefer if we could make the
> > > init less obscure and _documented_.
> >
> > I don't know, but I think it is a good idea to keep the existing logic rather
> > than do a big surgery
>
> Adding more hacks just doesn't make the situation any better.
>
> > unless someone is able to confirm it is not breaking NUMA
> > node physical hotplug.
>
> I have a machine to test whole node offline. I am just busy to prepare a
> patch myself. I can have it tested though.
>
I think the definition of "node online" is worth of rethinking. Before
patch "x86, numa: always initialize all possible nodes", online means
either cpu or memory present. After this patch, only node owing memory
as present.

In the commit log, I think the change's motivation should be "Not to
mention that it doesn't really make much sense to consider an empty
node as online because we just consider this node whenever we want to
iterate nodes to use and empty node is obviously not the best
candidate."

But in fact, we already have for_each_node_state(nid, N_MEMORY) to
cover this purpose. Furthermore, changing the definition of online may
break something in the scheduler, e.g. in task_numa_migrate(), where
it calls for_each_online_node.

By keeping the node owning cpu as online, Michal's patch can avoid
such corner case and keep things easy. Furthermore, if needed, the
other patch can use for_each_node_state(nid, N_MEMORY) to replace
for_each_online_node is some space.

Regards,
Pingfan

> --
> Michal Hocko
> SUSE Labs

