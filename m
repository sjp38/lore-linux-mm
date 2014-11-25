Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5122D6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:38:23 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so440717wgg.28
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 02:38:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hg6si1371448wjc.36.2014.11.25.02.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 02:38:22 -0800 (PST)
Date: Tue, 25 Nov 2014 11:38:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
Message-ID: <20141125103820.GA4607@dhcp22.suse.cz>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
 <20141124165032.GA11745@curandero.mameluci.net>
 <alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org

On Mon 24-11-14 14:29:00, David Rientjes wrote:
> On Mon, 24 Nov 2014, Michal Hocko wrote:
> 
> > > The problem described above is one of phenomena which is triggered by
> > > a vulnerability which exists since (if I didn't miss something)
> > > Linux 2.0 (18 years ago). However, it is too difficult to backport
> > > patches which fix the vulnerability.
> > 
> > What is the vulnerability?
> > 
> 
> There have historically been issues when oom killed processes fail to 
> exit, so this is probably trying to address one of those issues.

Let me clarify. The patch is sold as a security fix. In that context
vulnerability means a behavior which might be abused by a user. I was
merely interested whether there are some known scenarios which would
turn a potential OOM killer deadlock into an exploitable bug. The
changelog was rather unclear about it and rather strong in claims that
any user might trigger OOM deadlock.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
