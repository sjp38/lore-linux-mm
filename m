Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDC86B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:07:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so54020696pgr.6
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:07:47 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f19si172826pgk.358.2017.08.16.01.07.45
        for <linux-mm@kvack.org>;
        Wed, 16 Aug 2017 01:07:46 -0700 (PDT)
Date: Wed, 16 Aug 2017 17:06:23 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816080622.GU20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170816050506.GR20323@X58A-UD3R>
 <20170816055808.GB11771@tardis>
 <20170816071421.GT20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816071421.GT20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>, mingo@kernel.org, peterz@infradead.org
Cc: Thomas Gleixner <tglx@linutronix.de>, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 16, 2017 at 04:14:21PM +0900, Byungchul Park wrote:
> On Wed, Aug 16, 2017 at 01:58:08PM +0800, Boqun Feng wrote:
> > > I'm not sure this caused the lockdep warning but, if they belongs to the
> > > same class even though they couldn't be the same instance as you said, I
> > > also think that is another problem and should be fixed.
> > > 
> > 
> > My point was more like this is a false positive case, which we should
> > avoid as hard as we can, because this very case doesn't look like a
> > deadlock to me.
> > 
> > Maybe the pattern above does exist in current kernel, but we need to
> > guide/adjust lockdep to find the real case showing it's happening.
> 
> As long as they are initialized as a same class, there's no way to
> distinguish between them within lockdep.
> 
> And I also think we should avoid false positive cases. Do you think
> there are many places where completions are initialized in a same place
> even though they could never be the same instance?
> 
> If no, it would be better to fix it whenever we face it, as you did.

BTW, of course, the same problem would have occured when applying
lockdep for the first time. How did you solve it?

I mean that lockdep basically identifies classes even for typical locks
with the call site. So two locks could be the same class even though
they should not be the same. Of course, for now, we avoid the problemaic
cases with sub-class. Anyway, the problems certainly would have arised
for the first time. I want to follow that solution you did.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
