Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 705F1C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 03:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D523D21019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 03:58:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O6Yn6uNY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D523D21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 499C46B0003; Wed, 22 May 2019 23:58:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 423406B0006; Wed, 22 May 2019 23:58:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C3466B0007; Wed, 22 May 2019 23:58:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 061CE6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 23:58:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v187so3653782ioe.9
        for <linux-mm@kvack.org>; Wed, 22 May 2019 20:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gK23drSPTc6Sp50YYd591WJVpCNLG3i0gkiUHxG/8iE=;
        b=S+YbYolcvEPjuqxFur9I3h6z4tQQ3fzfBOP9jkAchgCjUkZhPnDGWWSKI8M4Mma7eF
         uQpmRav/yodJiNwwVUh5RazGhWNirpmrcN6pkfirYb2mWGLcXY4oFzLeUTSNJk7k2tBd
         UU0utXur1sx0RMorG45XQmZzM0FS6b2nVx28rjWTaNtmgrOwhwr9zFS4ERgL62fOINGQ
         ni0cs2YSKnlMIk4Z8QaaBAylpdLzE4ZJzkupHcjsvE0K46FQ/FyFf6LKvZTcxqYAcX8p
         aBPLb4i0a9NqCVJtNlV8yKe03qd7OiDU4uMnJoM6ZxgcmJ73kSJp7XbZsn5xzUWj33OK
         FojQ==
X-Gm-Message-State: APjAAAVfLx6X/bVaqnj107XYzdP9d2A/JLl6Lwg5cjL54mIf3rl8z8V6
	dLtcrEa2MgHAIUSBxsIJ41V0YtzLRZXnRlGRdWFmRuZwggeUAwxrOMC21mMgJw2hZIsRwj5wcWa
	cZYhXG7fzhRZStelO79FC7ozxO+P+BDrR7gy67cI+FM6ds4Nl6V4bV7smW47Xb/1sjQ==
X-Received: by 2002:a6b:e90e:: with SMTP id u14mr19870670iof.121.1558583938610;
        Wed, 22 May 2019 20:58:58 -0700 (PDT)
X-Received: by 2002:a6b:e90e:: with SMTP id u14mr19870633iof.121.1558583937511;
        Wed, 22 May 2019 20:58:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558583937; cv=none;
        d=google.com; s=arc-20160816;
        b=sfqdZ4pyGaQk6+Zef09+XyiMZX5FsQZOGcd4IKHToA7LoMb1qXTBBQxIZa+mGFi0Tj
         W4zUcZDUHCI422mO7URKmNVyDgtDtXJogStH6o+MNjWSWYX28E8a69ru/jrKbfYHEGnG
         pDAAKMyYaadTFdPqimTe0IB581X8qQpUhsNEYr1O1RbHbnvjW1qnD2Nr0Li0+12KVh3s
         58ASROm6opUjmbitdVFkJi+3ApWVMrCRXrZo/QBa3MncFErYy0IjL5aHfziQOCRYITna
         8dElLhatVfEelZvfsabO4VTDqny3tDJfkrR2YeMBPjgjE6qNZdCliv1gL73PlW8eL9OQ
         fJbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gK23drSPTc6Sp50YYd591WJVpCNLG3i0gkiUHxG/8iE=;
        b=yjU0as+Vj/vAz0SRV56X9hwf7gE8UhPsXzhdrKFe7OebMbCgZjMTBUuXAYDAg4bJH9
         CeNtmWsx/o4VZ1CV3rmS3Z/KEPbG75eJ/n+rD0IMHM/Zmd3E/K8FKr/CHN1gnS6mBbi3
         KvDLm5+LMseXVK6dIke4pAzrwJ6C354q0YlQPQXg8s3PMMBbZS6vJthsJ8F+TKCOK6Y7
         JILAyh2MNG2NlzXWAZpLL9KbK2sBucIHgmx1gNjWgu/8A8qIDaPkYkVIY8Z5UWaQJ0KC
         RzqAOTwQ13mWW+m5A72SrZ2CzA+SB2S2bHU9g7XMVE9DIIA6uCH9a0/JY0pbUWMnCyHl
         6+Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O6Yn6uNY;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h18sor11791925ith.3.2019.05.22.20.58.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 20:58:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O6Yn6uNY;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gK23drSPTc6Sp50YYd591WJVpCNLG3i0gkiUHxG/8iE=;
        b=O6Yn6uNY1U0GDT9H8Zs+XxTtDEAWg0hV7yCdnRVLsukaCu/z8SGFTzg+Sd6Rntf/IF
         Pl9r5CJ1BGtoYQk9S+8OPyfAgV/fuB5O6Bj/M5YPzxhbxmDUNisJRZH+uysYGsN9A4ue
         m7as3a4YtFLJLAIgSFxfP4wLXczYnAe9kb/IuUlLiPXF/i/d4TnvBOD4sSnyMe17Vj8H
         j1sArQys6TlhAKDSzeyDumwPL7vh7xro00H5E2eO0BX8A0RxPlp0mygYC/xoDA4Q9hlj
         ZkIuD0te/WwKkoGxfb3OhGoZ2eccpWs9oh0jq5vVol2ipRT8ohevIL4JyOMaOSVpfJv+
         jxxQ==
X-Google-Smtp-Source: APXvYqxjgdM9Bp5/7T5lxKvZL5BxoimH1/ppzovCcySA6voShJ3Vkzvq6mBdjzh+IYVopDk/DIZdvtMiSaT9Ji8lBcg=
X-Received: by 2002:a24:2e17:: with SMTP id i23mr10763400ita.100.1558583937195;
 Wed, 22 May 2019 20:58:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw> <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw> <20190513153143.GK24036@dhcp22.suse.cz>
 <CAFgQCTt9XA9_Y6q8wVHkE9_i+b0ZXCAj__zYU0DU9XUkM3F4Ew@mail.gmail.com> <20190522111655.GA4374@dhcp22.suse.cz>
In-Reply-To: <20190522111655.GA4374@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 23 May 2019 11:58:45 +0800
Message-ID: <CAFgQCTuKVif9gPTsbNdAqLGQyQpQ+gC2D1BQT99d0yDYHj4_mA@mail.gmail.com>
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

On Wed, May 22, 2019 at 7:16 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 22-05-19 15:12:16, Pingfan Liu wrote:
> > On Mon, May 13, 2019 at 11:31 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 13-05-19 11:20:46, Qian Cai wrote:
> > > > On Mon, 2019-05-13 at 16:04 +0200, Michal Hocko wrote:
> > > > > On Mon 13-05-19 09:43:59, Qian Cai wrote:
> > > > > > On Mon, 2019-05-13 at 14:41 +0200, Michal Hocko wrote:
> > > > > > > On Sun 12-05-19 01:48:29, Qian Cai wrote:
> > > > > > > > The linux-next commit ("x86, numa: always initialize all possible
> > > > > > > > nodes") introduced a crash below during boot for systems with a
> > > > > > > > memory-less node. This is due to CPUs that get onlined during SMP boot,
> > > > > > > > but that onlining triggers a page fault in bus_add_device() during
> > > > > > > > device registration:
> > > > > > > >
> > > > > > > >       error = sysfs_create_link(&bus->p->devices_kset->kobj,
> > > > > > > >
> > > > > > > > bus->p is NULL. That "p" is the subsys_private struct, and it should
> > > > > > > > have been set in,
> > > > > > > >
> > > > > > > >       postcore_initcall(register_node_type);
> > > > > > > >
> > > > > > > > but that happens in do_basic_setup() after smp_init().
> > > > > > > >
> > > > > > > > The old code had set this node online via alloc_node_data(), so when it
> > > > > > > > came time to do_cpu_up() -> try_online_node(), the node was already up
> > > > > > > > and nothing happened.
> > > > > > > >
> > > > > > > > Now, it attempts to online the node, which registers the node with
> > > > > > > > sysfs, but that can't happen before the 'node' subsystem is registered.
> > > > > > > >
> > > > > > > > Since kernel_init() is running by a kernel thread that is in
> > > > > > > > SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> > > > > > > > during the early boot in __try_online_node().
> > > > > > >
> > > > > > > Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
> > > > > > > drop try_online_node from do_cpu_up? Your v2 remark below suggests that
> > > > > > > we need to call node_set_online because something later on depends on
> > > > > > > that. Btw. why do we even allocate a pgdat from this path? This looks
> > > > > > > really messy.
> > > > > >
> > > > > > See the commit cf23422b9d76 ("cpu/mem hotplug: enable CPUs online before
> > > > > > local
> > > > > > memory online")
> > > > > >
> > > > > > It looks like try_online_node() in do_cpu_up() is needed for memory hotplug
> > > > > > which is to put its node online if offlined and then hotadd_new_pgdat()
> > > > > > calls
> > > > > > build_all_zonelists() to initialize the zone list.
> > > > >
> > > > > Well, do we still have to followthe logic that the above (unreviewed)
> > > > > commit has established? The hotplug code in general made a lot of ad-hoc
> > > > > design decisions which had to be revisited over time. If we are not
> > > > > allocating pgdats for newly added memory then we should really make sure
> > > > > to do so at a proper time and hook. I am not sure about CPU vs. memory
> > > > > init ordering but even then I would really prefer if we could make the
> > > > > init less obscure and _documented_.
> > > >
> > > > I don't know, but I think it is a good idea to keep the existing logic rather
> > > > than do a big surgery
> > >
> > > Adding more hacks just doesn't make the situation any better.
> > >
> > > > unless someone is able to confirm it is not breaking NUMA
> > > > node physical hotplug.
> > >
> > > I have a machine to test whole node offline. I am just busy to prepare a
> > > patch myself. I can have it tested though.
> > >
> > I think the definition of "node online" is worth of rethinking. Before
> > patch "x86, numa: always initialize all possible nodes", online means
> > either cpu or memory present. After this patch, only node owing memory
> > as present.
> >
> > In the commit log, I think the change's motivation should be "Not to
> > mention that it doesn't really make much sense to consider an empty
> > node as online because we just consider this node whenever we want to
> > iterate nodes to use and empty node is obviously not the best
> > candidate."
> >
> > But in fact, we already have for_each_node_state(nid, N_MEMORY) to
> > cover this purpose.
>
> I do not really think we want to spread N_MEMORY outside of the core MM.
> It is quite confusing IMHO.
> .
But it has already like this. Just git grep N_MEMORY.

> > Furthermore, changing the definition of online may
> > break something in the scheduler, e.g. in task_numa_migrate(), where
> > it calls for_each_online_node.
>
> Could you be more specific please? Why should numa balancing consider
> nodes without any memory?
>
As my understanding, the destination cpu can be on a memory less node.
BTW, there are several functions in the scheduler facing the same
scenario, task_numa_migrate() is an example.

> > By keeping the node owning cpu as online, Michal's patch can avoid
> > such corner case and keep things easy. Furthermore, if needed, the
> > other patch can use for_each_node_state(nid, N_MEMORY) to replace
> > for_each_online_node is some space.
>
> Ideally no code outside of the core MM should care about what kind of
> memory does the node really own. The external code should only care
> whether the node is online and thus usable or offline and of no
> interest.
Yes, but maybe it will pay great effort on it.

Regards,
Pingfan
> --
> Michal Hocko
> SUSE Labs

