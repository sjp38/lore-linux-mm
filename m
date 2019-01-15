Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA5FAC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 19:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 617FE20656
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 19:38:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FzAXW+YI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 617FE20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B51E18E0003; Tue, 15 Jan 2019 14:38:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B01098E0002; Tue, 15 Jan 2019 14:38:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A179D8E0003; Tue, 15 Jan 2019 14:38:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71E5E8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 14:38:36 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id y6so1784035ybb.11
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 11:38:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2cLRbj6ZrwUgB3ed0j9nxtSpZlKaYfrBPTp259N8B/A=;
        b=mhk2ZJ+svUOOX9nuQvAnn0WVVOoqJVwGtzQOY7nGkoEPj6CnRu5xIK0fqdC94HfCcV
         3/lLMEyKOJzs1fHQw1JwqpH9iBGY0EktACHp5KWGYVOd6RbDr8L79kkPq4/4i+QmxvdG
         2KfYkKrFTcqgSMcSdIvSq7beRhT7olCFE9Xnd6g34Fc1CKMKf3E9tvyDZkQeeuF65rUZ
         renbj5FSpTQZSvkz8vkvYoGohTCAW/ssUBoEe9z4SEAXLD/tQLK8HbWiTPxZaAjepA08
         MeHRsVgwPE4P4VQlubba/cHcp/UrXoDZY+veJ330Qx1BEYA3mronuKduRcAhO/mspDKG
         ceKw==
X-Gm-Message-State: AJcUukdIClCZBISfDEI7CTYpstgftSAyQh//2L8l7FWiwABmQ/eFpzHX
	mRsUYkolziQF1zO8NR0DyKj8mirFjwQy9RKTvI2T2DXPz54uvSpEYVraVAPs2PRk5PgIabRF0n7
	NoH+0E0/A0vscSQ5D2Qid2jHp9bf2g0NEWbghuXar/q8RyhboW79oVQdIlJ+3BtKMpNOJIJaPwy
	CkR4j6w29vV0l7+ouDZn5yZINUkVoq3HzZ/hd/qeIzQYKv4G6De90lyKff8Jg9s/bWy5NGoMRLM
	TK3D2Es8zulKQNRlYH5qS6Jn1WkWjgdm6QcJTlVkvfYqkZOQ1/79okBxDlLcnAzx4r3vAHpcxSQ
	ivpmIC69XCXylhWxC8ldgzT6njq21gC2JRZrTF/goy713lnjzqpQEbN15UYYZdthIFKiiwPtk56
	F
X-Received: by 2002:a25:5755:: with SMTP id l82mr4785005ybb.138.1547581116067;
        Tue, 15 Jan 2019 11:38:36 -0800 (PST)
X-Received: by 2002:a25:5755:: with SMTP id l82mr4784949ybb.138.1547581115053;
        Tue, 15 Jan 2019 11:38:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547581115; cv=none;
        d=google.com; s=arc-20160816;
        b=i+hKzZcrM2haF1CdQMrfe/GtTw2Bshr0sCn0LRDW2PZqKxQgvy5BVVf4fYb/1/6hlF
         wpJK1KUsOF1E0F9VLvuFnFBCOTGXfcp/rScPGBtu3NIu7XtySikirheVHAic0kARtOQ4
         BlnEMrO88l9ZOWsusslOli8b7RG/RKXKDLKV3bTRDQXdc+Wqv8NICkEPCSHTIi+lY2S+
         JA9+UOUhiR1Qc5PQ+O56/grknk44FTprwasrOL6kRj4y9C5dOXUluNldwv0Vp4oS7Gc3
         I5a2XnckKaYJ2ir3c3vrdoCG5opTF9vKKE/7Ix/juJpD+eh+gT8puKYqdBuZHu+m1l61
         7T5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2cLRbj6ZrwUgB3ed0j9nxtSpZlKaYfrBPTp259N8B/A=;
        b=wg48kjkYTkLzQKNvcLJXQfX2udapNGshv+UiatyB/0OtsRMfz4veiIA2UrkAVOvng7
         TAYovVYKf1pOrGWBtVw9LUnELDlwOKZmvv6AwGHHeBVbr0RBMvA69rW7L0GZeXkdUKig
         RJYsKzaNYGh91NzqIONYToUkJsOOCo8jsVjsO9E+C/k32vuXNjWz9q8DJYkoErlrh97v
         dxp1YYBhspU22qvX1uwbZKn6WfEWsQ55MKo87VuFIun6BKq1BDl5Xhr3/p2uzsYY2UhN
         pY7Ndbv5DmVcT1IlD8A7CPI1f0E/snBzQeUmvqBPLndWE+rM7X8oaFXTYXAPdX5ge5ih
         NtGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FzAXW+YI;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x137sor600057ywg.141.2019.01.15.11.38.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 11:38:35 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FzAXW+YI;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2cLRbj6ZrwUgB3ed0j9nxtSpZlKaYfrBPTp259N8B/A=;
        b=FzAXW+YIbjj8DpDu2MDZ0WqKcbXJ3SWF4P4UCqbL6HqTDOHlIVL0/XhJBDCgyPXCFc
         FbspV0nhzHZO8u/Ui72yv8BpC0PyJ7HV+HDf66IyeE+1MbtLTIflaluazaHmr553ae2V
         tjAp+4at4o5/IaXTAG1yJwNSn6mW7LZAOVJBfXG4Gacb1DLDnuZmUOn4WiDULexO6/GH
         9igeGGjyTkTLX4hN5Jl3Ad/adMcbKzeZOIxv7YbGYHl7ARq1k0DKmo7G8q+kR0Glzlq4
         pRcRQN+AHiqpTofCYLOpEk3zar28MiDfsBNDsd1eI9MqGjbAlTW8DGTTe+jJ9YP1XpUj
         aHxQ==
X-Google-Smtp-Source: ALg8bN7Vxx2AeMbVykY9japellF7+ir8UaUpIcIPYA19UNwpNQo4G0nfXJhT8X3UW1MwgOkVr3qIxdIScB5X9LFw4ns=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr4491703ywm.489.1547581114321;
 Tue, 15 Jan 2019 11:38:34 -0800 (PST)
MIME-Version: 1.0
References: <20190110174432.82064-1-shakeelb@google.com> <20190111205948.GA4591@cmpxchg.org>
 <CALvZod7O2CJuhbuLUy9R-E4dTgL4WBg8CayW_AFnCCG6KCDjUA@mail.gmail.com>
 <20190113183402.GD1578@dhcp22.suse.cz> <CALvZod6paX4_vtgP8AJm5PmW_zA_ecLLP2qTvQz8rRyKticgDg@mail.gmail.com>
 <20190115072551.GO21345@dhcp22.suse.cz>
In-Reply-To: <20190115072551.GO21345@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 15 Jan 2019 11:38:23 -0800
Message-ID:
 <CALvZod6U+OGZJ1mcSG++Q5CJtEjLbr3pwvLRBbkpbZbqf6YSsA@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115193823.bIAU9Y9Ea9D7UScTPj8YVEBRiF_Wl5UcJsfD4rHBdIg@z>

On Mon, Jan 14, 2019 at 11:25 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 14-01-19 12:18:07, Shakeel Butt wrote:
> > On Sun, Jan 13, 2019 at 10:34 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 11-01-19 14:54:32, Shakeel Butt wrote:
> > > > Hi Johannes,
> > > >
> > > > On Fri, Jan 11, 2019 at 12:59 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > >
> > > > > Hi Shakeel,
> > > > >
> > > > > On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> > > > > > If a memcg is over high limit, memory reclaim is scheduled to run on
> > > > > > return-to-userland.  However it is assumed that the memcg is the current
> > > > > > process's memcg.  With remote memcg charging for kmem or swapping in a
> > > > > > page charged to remote memcg, current process can trigger reclaim on
> > > > > > remote memcg.  So, schduling reclaim on return-to-userland for remote
> > > > > > memcgs will ignore the high reclaim altogether. So, record the memcg
> > > > > > needing high reclaim and trigger high reclaim for that memcg on
> > > > > > return-to-userland.  However if the memcg is already recorded for high
> > > > > > reclaim and the recorded memcg is not the descendant of the the memcg
> > > > > > needing high reclaim, punt the high reclaim to the work queue.
> > > > >
> > > > > The idea behind remote charging is that the thread allocating the
> > > > > memory is not responsible for that memory, but a different cgroup
> > > > > is. Why would the same thread then have to work off any high excess
> > > > > this could produce in that unrelated group?
> > > > >
> > > > > Say you have a inotify/dnotify listener that is restricted in its
> > > > > memory use - now everybody sending notification events from outside
> > > > > that listener's group would get throttled on a cgroup over which it
> > > > > has no control. That sounds like a recipe for priority inversions.
> > > > >
> > > > > It seems to me we should only do reclaim-on-return when current is in
> > > > > the ill-behaved cgroup, and punt everything else - interrupts and
> > > > > remote charges - to the workqueue.
> > > >
> > > > This is what v1 of this patch was doing but Michal suggested to do
> > > > what this version is doing. Michal's argument was that the current is
> > > > already charging and maybe reclaiming a remote memcg then why not do
> > > > the high excess reclaim as well.
> > >
> > > Johannes has a good point about the priority inversion problems which I
> > > haven't thought about.
> > >
> > > > Personally I don't have any strong opinion either way. What I actually
> > > > wanted was to punt this high reclaim to some process in that remote
> > > > memcg. However I didn't explore much on that direction thinking if
> > > > that complexity is worth it. Maybe I should at least explore it, so,
> > > > we can compare the solutions. What do you think?
> > >
> > > My question would be whether we really care all that much. Do we know of
> > > workloads which would generate a large high limit excess?
> > >
> >
> > The current semantics of memory.high is that it can be breached under
> > extreme conditions. However any workload where memory.high is used and
> > a lot of remote memcg charging happens (inotify/dnotify example given
> > by Johannes or swapping in tmpfs file or shared memory region) the
> > memory.high breach will become common.
>
> This is exactly what I am asking about. Is this something that can
> happen easily? Remote charges on themselves should be rare, no?
>

At the moment, for kmem we can do remote charging for fanotify,
inotify and buffer_head and for anon pages we can do remote charging
on swap in. Now based on the workload's cgroup setup the remote
charging can be very frequent or rare.

At Google, remote charging is very frequent but since we are still on
cgroup-v1 and do not use memory.high, the issue this patch is fixing
is not observed. However for the adoption of cgroup-v2, this fix is
needed.

Shakeel

