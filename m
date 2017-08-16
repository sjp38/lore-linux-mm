Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84A366B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:39:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 16so56490642pgg.8
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 02:39:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e93si313610plk.213.2017.08.16.02.39.56
        for <linux-mm@kvack.org>;
        Wed, 16 Aug 2017 02:39:57 -0700 (PDT)
Date: Wed, 16 Aug 2017 18:38:36 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816093836.GV20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170816050506.GR20323@X58A-UD3R>
 <20170816055808.GB11771@tardis>
 <20170816071421.GT20323@X58A-UD3R>
 <20170816080622.GU20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816080622.GU20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>, mingo@kernel.org, peterz@infradead.org
Cc: Thomas Gleixner <tglx@linutronix.de>, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 16, 2017 at 05:06:23PM +0900, Byungchul Park wrote:
> On Wed, Aug 16, 2017 at 04:14:21PM +0900, Byungchul Park wrote:
> > On Wed, Aug 16, 2017 at 01:58:08PM +0800, Boqun Feng wrote:
> > > > I'm not sure this caused the lockdep warning but, if they belongs to the
> > > > same class even though they couldn't be the same instance as you said, I
> > > > also think that is another problem and should be fixed.
> > > > 
> > > 
> > > My point was more like this is a false positive case, which we should
> > > avoid as hard as we can, because this very case doesn't look like a
> > > deadlock to me.
> > > 
> > > Maybe the pattern above does exist in current kernel, but we need to
> > > guide/adjust lockdep to find the real case showing it's happening.
> > 
> > As long as they are initialized as a same class, there's no way to
> > distinguish between them within lockdep.
> > 
> > And I also think we should avoid false positive cases. Do you think
> > there are many places where completions are initialized in a same place
> > even though they could never be the same instance?
> > 
> > If no, it would be better to fix it whenever we face it, as you did.
> 
> BTW, of course, the same problem would have occured when applying
> lockdep for the first time. How did you solve it?
> 
> I mean that lockdep basically identifies classes even for typical locks
> with the call site. So two locks could be the same class even though
> they should not be the same. Of course, for now, we avoid the problemaic
> cases with sub-class. Anyway, the problems certainly would have arised
             ^
             or setting a class or re-design code like what Boqun
             suggested. And so on...

> for the first time. I want to follow that solution you did.
> 
> Thanks,
> Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
