Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 65E466B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 17:42:03 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id b205so131030127wmb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 14:42:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k9si51811540wjr.241.2016.02.16.14.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 14:42:02 -0800 (PST)
Date: Tue, 16 Feb 2016 14:41:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full
 IO and mem
Message-Id: <20160216144159.9335e48d65b7327984d298ac@linux-foundation.org>
In-Reply-To: <20151005200345.GA12889@dhcp22.suse.cz>
References: <bug-99471-27@https.bugzilla.kernel.org/>
	<bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
	<20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
	<20150915083919.GG2858@cmpxchg.org>
	<20151005200345.GA12889@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk, Rik van Riel <riel@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, serianox@gmail.com, spam@kernelspace.de, larsnostdal@gmail.com, viktorpal@yahoo.de, shentino@gmail.com

On Mon, 5 Oct 2015 22:03:46 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 15-09-15 10:39:19, Johannes Weiner wrote:
> > On Thu, Sep 10, 2015 at 02:04:18PM -0700, Andrew Morton wrote:
> > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > bugzilla web interface).
> > > 
> > > On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > > 
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=99471
> > > 
> > > Guys, could you take a look please?

So this isn't fixed and a number of new reporters (cc'ed) are chiming
in (let's please keep this going via email, not via the bugzilla UI!).

We have various theories but I don't think we've nailed it down yet.

Are any of the reporters able to come up with a set of instructions
which will permit the developers to reproduce this bug locally?

Can we think up a way of adding some form of debug/instrumentation to
the kernel which will permit us to diagnose and fix this?  It could be
something which a tester manually adds or it could be something
permanent, perhaps controlled via a procfs knob.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
