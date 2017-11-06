Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFD56B026C
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:06:17 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q81so21073009ioi.12
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:06:17 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y74si7637945itc.72.2017.11.06.02.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 02:06:14 -0800 (PST)
Date: Mon, 6 Nov 2017 11:05:58 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-ID: <20171106100558.GD3165@worktop.lehotels.local>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
 <1509739786.2473.33.camel@wdc.com>
 <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "yang.s@alibaba-inc.com" <yang.s@alibaba-inc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>

On Sun, Nov 05, 2017 at 09:19:46AM +0100, Michal Hocko wrote:
> [CC Peter]
> 
> On Fri 03-11-17 20:09:49, Bart Van Assche wrote:
> > On Fri, 2017-11-03 at 11:02 -0700, Andrew Morton wrote:
> > > Also, checkpatch says
> > > 
> > > WARNING: use of in_atomic() is incorrect outside core kernel code
> > > #43: FILE: mm/memory.c:4491:
> > > +       if (in_atomic())
> > > 
> > > I don't recall why we did that, but perhaps this should be revisited?
> > 
> > Is the comment above in_atomic() still up-to-date? From <linux/preempt.h>:
> > 
> > /*
> >  * Are we running in atomic context?  WARNING: this macro cannot
> >  * always detect atomic context; in particular, it cannot know about
> >  * held spinlocks in non-preemptible kernels.  Thus it should not be
> >  * used in the general case to determine whether sleeping is possible.
> >  * Do not use in_atomic() in driver code.
> >  */
> > #define in_atomic()	(preempt_count() != 0)
> 
> I can still see preempt_disable NOOP for !CONFIG_PREEMPT_COUNT kernels
> which makes me think this is still a valid comment.

Yes the comment is very much accurate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
