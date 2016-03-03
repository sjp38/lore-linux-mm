Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id F13A76B0253
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 03:22:57 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so21016870wml.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:22:57 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 17si47336353wjv.159.2016.03.03.00.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 00:22:57 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id n186so120100616wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:22:56 -0800 (PST)
Date: Thu, 3 Mar 2016 09:22:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kswapd consumes 100% CPU when highest zone is small
Message-ID: <20160303082254.GA26202@dhcp22.suse.cz>
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
 <20160302173639.GD26701@dhcp22.suse.cz>
 <CAKQB+fss2UZOP-39GCpQY3T8MJoErm_0AeDnnAPZZ4MEWLXs7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKQB+fss2UZOP-39GCpQY3T8MJoErm_0AeDnnAPZZ4MEWLXs7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerry Lee <leisurelysw24@gmail.com>
Cc: linux-mm@kvack.org

On Thu 03-03-16 10:23:03, Jerry Lee wrote:
> On 3 March 2016 at 01:36, Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 02-03-16 14:20:38, Jerry Lee wrote:
[...]
> > > Is there anything I could do to totally get rid of the problem?
> >
> > I would try to sacrifice those few megs and get rid of zone normal
> > completely. AFAIR mem=4G should limit the max_pfn to 4G so DMA32 should
> > cover the shole memory.
> >
> 
> I came up with a patch that seem to work well on my system.  But, I
> am afraid that it breaks the rule that all zones must be balanced for
> order-0 request and It may cause some other side-effect?  I thought
> that the patch is just a workaround (a bad one) and not a cure-all.

One thing I haven't noticed previously is that you are running on the 3.12
kernel. I vaguely remember there were some fixes for small zones. Not
sure it would work for such a small zone but it would be worth trying I
guess. Could you retest with 4.4?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
