Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 754386B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:54:32 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so521949pdj.25
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:54:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qz4si1620715pac.240.2014.11.25.04.54.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:54:31 -0800 (PST)
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
	<201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
	<20141124165032.GA11745@curandero.mameluci.net>
	<alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
	<20141125103820.GA4607@dhcp22.suse.cz>
In-Reply-To: <20141125103820.GA4607@dhcp22.suse.cz>
Message-Id: <201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
Date: Tue, 25 Nov 2014 21:54:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, rientjes@google.com
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Mon 24-11-14 14:29:00, David Rientjes wrote:
> > On Mon, 24 Nov 2014, Michal Hocko wrote:
> > 
> > > > The problem described above is one of phenomena which is triggered by
> > > > a vulnerability which exists since (if I didn't miss something)
> > > > Linux 2.0 (18 years ago). However, it is too difficult to backport
> > > > patches which fix the vulnerability.
> > > 
> > > What is the vulnerability?
> > > 
> > 
> > There have historically been issues when oom killed processes fail to 
> > exit, so this is probably trying to address one of those issues.

Exactly.

> 
> Let me clarify. The patch is sold as a security fix. In that context
> vulnerability means a behavior which might be abused by a user. I was
> merely interested whether there are some known scenarios which would
> turn a potential OOM killer deadlock into an exploitable bug. The
> changelog was rather unclear about it and rather strong in claims that
> any user might trigger OOM deadlock.

Well, both of you are in the CC: list of my mail which includes a reproducer
program which I sent on Thu, 26 Jun 2014 21:02:36 +0900.

Please prepare two VMs, one with XFS and one without XFS. Compile and run
the reproducer program as a local unpriviledged user and see what happens.
You will see stalled traces as with cited in this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
