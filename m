Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2CC9C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:37:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65BD3218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:37:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hEKKgLcC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65BD3218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE3008E0016; Wed, 30 Jan 2019 14:37:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E697B8E0001; Wed, 30 Jan 2019 14:37:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D323F8E0016; Wed, 30 Jan 2019 14:37:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D93B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:37:54 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id i142so354266ybg.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:37:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ynztbY1mL0CpFlAEvrgll//q6zMLgn4eN+pIRdt4AAk=;
        b=mgaVMfVXdwi73nVkxOhaL4kVWeUnCmQaqHCzlc5Z1yoQ6PYFTtPW/2/ou3POBChklV
         sYlwWvK+R4YZ2AlJHT3ZD1AZET3sQM0Jmsi6YjlCmFIV/HJ3vbdV5jNuoVsb9eq+Ljjm
         dKWHPkVdUV8vUhdAihhl4/cQupgGuZCOqSLtX2YcsJ3LwIW8qjq5ztCyR2OeVwj0iyhr
         fF2apZt+YA2Opumug6UHofshvBBjsoa+vIUa3HqHKjxxpLi093cBcBEhsEX6N0dvZB2v
         ceba2LgzL2QYR3XLy/WgnKNxbE5tN4vZNOB1tK99RHWVobeEcyXrjDDBFtX815q+HPkx
         XoNw==
X-Gm-Message-State: AHQUAuZVJlxcOG2Kp9YzvQWAZs94/phdDbtdhbDcq2mhtrN/dF3YW84l
	ebapNTzcy6dmsA4/ZMKymSxQ9JChK+twyEwkiUmGD52C8dDpaWGvaP6aiYSteKE++lykYAvMAmm
	At9yOMxof/bjFupm4wpPtr2mMx4HNSeTzjqRfYcCPj04qIMMkDUrGUtAMY8tfzVq7MwDoyNrBHh
	SHE8/zI215hGuKvCN1vSkX6TN+WVebZNwawYktQykEQKoHnwA4Ad4/cmskUsMCIc5gH38Fwue0u
	IUiWKNVe6iB4NOrCw4YzcHzuO0aLdkw3wx+4OByEd5Nxv+AsK95ppmhYsvViXKcH2r31zUiDUvW
	8blHIrYtxbxe9F5uQK2qGP4PCmMUVsGGtfWjLh0Bn/czUr459s0G/EL0HDsgg3j4xl8BadA8FVU
	/
X-Received: by 2002:a25:50cc:: with SMTP id e195mr7132834ybb.422.1548877074371;
        Wed, 30 Jan 2019 11:37:54 -0800 (PST)
X-Received: by 2002:a25:50cc:: with SMTP id e195mr7132822ybb.422.1548877073884;
        Wed, 30 Jan 2019 11:37:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548877073; cv=none;
        d=google.com; s=arc-20160816;
        b=ih11Yw+kISpxoxiF1ZaIzquY6ycRQzuHJBiTxsA4G6J9gzMQF6K8JfsdtSiCDP6WQX
         9fiJO6mphOT9Mc13emk7x78+h8n51oDBHT0Fm4WaowMUmq3TFmpJayEhpQ9vkmiGirZK
         Stl0DIQLqtHp5QmTGsNYDXscmhzF4OYGk10yK9VhmjJPaXwWqW+v6gGAdMEJtJ6niM5A
         iemThIXPwzn4TBOScT5G452VC/KD2r/GZSD7pk/4x4qNmkywv1amIwcwzEGXTsDHcNm+
         dn/CX2ROkJUydSgvRtJNiOrnfnUE+DaJDo33hETa8wlVRk4XPowtSRC6iZPQfaCA0Q+n
         byhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ynztbY1mL0CpFlAEvrgll//q6zMLgn4eN+pIRdt4AAk=;
        b=ev1LQHekDINGnD070Qnfdl/XF8ude/RIQ2sqDLyHMBbutC7E2IKlSmV0S3exxWz6Ea
         zQc4bhBYabycJBUSZmQGrcHiiA7Dt9QNt+fDgmYBin5c6zhtGpMnnrN046eqGPKzfyMW
         r+tv8G+0Xqp9JLnEfhBo34K+uN9Aoe+y2CqvHJTe+2sfTAQ4Y2im+sduNLmE11OcYKH6
         aqdu7Me2ZfYmdbnwbLMaWi8uPgasaAdt/Dq31jBidCUbPCA9nGwHwxS2MXkvYESTNf41
         MzGxWOIqptFqZZV/AZVsi5wTOUJeu9AEwKRD3Dj+tTzKOnabA8pcvQRX0IPCiZX3sJKR
         Tpiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hEKKgLcC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l205sor1086489ybl.26.2019.01.30.11.37.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:37:53 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hEKKgLcC;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ynztbY1mL0CpFlAEvrgll//q6zMLgn4eN+pIRdt4AAk=;
        b=hEKKgLcCzb2TF8FQN9P2G70rLcqxOf+LMks/+bF+A75PISRGD8IJ9dC5LM2uk05Xwq
         55VsBJhulcECv3kpovgOaIni5zJcPfJUS59855DCJ7ExDIP5ewLYj3ZjEVsiCG6PTEPM
         Zqiv5d0Kub8BDoQ50wztXVuUhutgHbqGzcZzom1m9me6gBYX7Vl5RrUWDnYxTiznNLZs
         gSZPPN52kSVg6gWY1zJ5H1OUEUDHNjAOiFC+pL2T/p3giL4aVbqLAjXkrufL5hGaOC6Z
         tlCSEkC13nHm6KoldXcMhad4Ey3Nrts77/IJMgMhS0kiTkyCLuCCX209hI2fh1TRz8xD
         uO7Q==
X-Google-Smtp-Source: ALg8bN4m6DdZb64I2TwM1WAOhkdzCmwIj2WgVfJC+FcPK4G0gACjv2e4CSsynpbc+jp0qKmatItJpljIxuFrLjpZ2A4=
X-Received: by 2002:a25:6f8b:: with SMTP id k133mr29688224ybc.496.1548877073376;
 Wed, 30 Jan 2019 11:37:53 -0800 (PST)
MIME-Version: 1.0
References: <20190128151859.GO18811@dhcp22.suse.cz> <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz> <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz> <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz> <20190130170658.GY50184@devbig004.ftw2.facebook.com>
 <CALvZod5ma62fRKqrAhMcuNT3GYT3FpRX+DCmeVr2nDg1u=9T8w@mail.gmail.com>
 <20190130192712.GA21279@cmpxchg.org> <20190130193026.GA21410@cmpxchg.org>
In-Reply-To: <20190130193026.GA21410@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 30 Jan 2019 11:37:41 -0800
Message-ID: <CALvZod65htZmApWkv-MrAjg6V1OGBLmdyFP_030LARD7ajS3mw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Chris Down <chris@chrisdown.name>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:30 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Wed, Jan 30, 2019 at 02:27:12PM -0500, Johannes Weiner wrote:
> > On Wed, Jan 30, 2019 at 11:11:44AM -0800, Shakeel Butt wrote:
> > > Hi Tejun,
> > >
> > > On Wed, Jan 30, 2019 at 9:07 AM Tejun Heo <tj@kernel.org> wrote:
> > > >
> > > > Hello, Michal.
> > > >
> > > > On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > > > > > Yeah, cgroup.events and .stat files as some of the local stats would
> > > > > > be useful too, so if we don't flip memory.events we'll end up with sth
> > > > > > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > > > > > which is gonna be hilarious.
> > > > >
> > > > > Why cannot we simply have memory.events_tree and be done with it? Sure
> > > > > the file names are not goin to be consistent which is a minus but that
> > > > > ship has already sailed some time ago.
> > > >
> > > > Because the overall cost of shitty interface will be way higher in the
> > > > longer term.  cgroup2 interface is far from perfect but is way better
> > > > than cgroup1 especially for the memory controller.  Why do you think
> > > > that is?
> > > >
> > >
> > > I thought you are fine with the separate interface for the hierarchical events.
> >
> > Every other file in cgroup2 is hierarchical, but for recursive
> > memory.events you'd need to read memory.events_tree?
> >
> > Do we hate our users that much? :(
>
> FTR, I would be okay with adding .local versions to existing files
> where such a behavior could be useful. But that seems to be a separate
> discussion from fixing memory.events here.

Oh ok, the dispute is on the name of the interface. I am fine with
whatever the decision is made as we (Google) are still not using these
interfaces. However what's the way forward here?

thanks,
Shakeel

