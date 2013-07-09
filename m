Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id ABE436B0033
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:34:14 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id d10so4929409lbj.14
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 10:34:12 -0700 (PDT)
Date: Tue, 9 Jul 2013 21:34:08 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130709173407.GA9188@localhost.localdomain>
References: <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130708140419.d9079dd67111090beb6cef3d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130708140419.d9079dd67111090beb6cef3d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 08, 2013 at 02:04:19PM -0700, Andrew Morton wrote:
> On Mon, 8 Jul 2013 14:53:52 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > > Good news! The test was running since morning and it didn't hang nor
> > > crashed. So this really looks like the right fix. It will run also
> > > during weekend to be 100% sure. But I guess it is safe to say
> > 
> > Hmm, it seems I was too optimistic or we have yet another issue here (I
> > guess the later is more probable).
> > 
> > The weekend testing got stuck as well. 
> > 
> > The dmesg shows there were some hung tasks:
> 
> That looks like the classic "we lost an IO completion" trace.
> 
> I think it would be prudent to defer these patches into 3.12.
Agree.

Will they still in -mm, or do I have to resend ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
