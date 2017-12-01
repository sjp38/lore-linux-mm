Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F053D6B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:40:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so5978954pgv.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:40:50 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y73si4563013plh.706.2017.11.30.23.40.49
        for <linux-mm@kvack.org>;
        Thu, 30 Nov 2017 23:40:49 -0800 (PST)
Date: Fri, 1 Dec 2017 16:46:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/18] introduce a new tool, valid access checker
Message-ID: <20171201074655.GB21404@js1304-P5Q-DELUXE>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZwvVG7aEiZWj-OmbxVdQyFj0ebXnakjeVnar-GQACBfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZwvVG7aEiZWj-OmbxVdQyFj0ebXnakjeVnar-GQACBfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Andi Kleen <ak@linux.intel.com>

On Wed, Nov 29, 2017 at 10:27:00AM +0100, Dmitry Vyukov wrote:
> On Tue, Nov 28, 2017 at 8:48 AM,  <js1304@gmail.com> wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Hello,
> >
> > This patchset introduces a new tool, valid access checker.
> >
> > Vchecker is a dynamic memory error detector. It provides a new debug feature
> > that can find out an un-intended access to valid area. Valid area here means
> > the memory which is allocated and allowed to be accessed by memory owner and
> > un-intended access means the read/write that is initiated by non-owner.
> > Usual problem of this class is memory overwritten.
> >
> > Most of debug feature focused on finding out un-intended access to
> > in-valid area, for example, out-of-bound access and use-after-free, and,
> > there are many good tools for it. But, as far as I know, there is no good tool
> > to find out un-intended access to valid area. This kind of problem is really
> > hard to solve so this tool would be very useful.
> >
> > This tool doesn't automatically catch a problem. Manual runtime configuration
> > to specify the target object is required.
> >
> > Note that there was a similar attempt for the debugging overwritten problem
> > however it requires manual code modifying and recompile.
> >
> > http://lkml.kernel.org/r/<20171117223043.7277-1-wen.gang.wang@oracle.com>
> >
> > To get more information about vchecker, please see a documention at
> > the last patch.
> >
> > Patchset can also be available at
> >
> > https://github.com/JoonsooKim/linux/tree/vchecker-master-v1.0-next-20171122
> >
> > Enjoy it.
> 
> 
> Hi Joonsoo,
> 
> I skimmed through the code and this looks fine from KASAN point of
> view (minimal code changes and no perf impact).
> I don't feel like I can judge if this should go in or not. I will not
> use this, we use KASAN for large-scale testing, but vchecker is in a
> different bucket, it is meant for developers debugging hard bugs.
> Wengang come up with a very similar change, and Andi said that this
> looks useful.

Thanks for comment.

Hello, other reviewers!
Please let me know more opinions about this patchset.

> 
> If the decision is that this goes in, please let me take a closer look
> before this is merged.

I will let you know when the decision is made.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
