Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 114426B0034
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 17:04:21 -0400 (EDT)
Date: Mon, 8 Jul 2013 14:04:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-Id: <20130708140419.d9079dd67111090beb6cef3d@linux-foundation.org>
In-Reply-To: <20130708125352.GC20149@dhcp22.suse.cz>
References: <20130629025509.GG9047@dastard>
	<20130630183349.GA23731@dhcp22.suse.cz>
	<20130701012558.GB27780@dastard>
	<20130701075005.GA28765@dhcp22.suse.cz>
	<20130701081056.GA4072@dastard>
	<20130702092200.GB16815@dhcp22.suse.cz>
	<20130702121947.GE14996@dastard>
	<20130702124427.GG16815@dhcp22.suse.cz>
	<20130703112403.GP14996@dastard>
	<20130704163643.GF7833@dhcp22.suse.cz>
	<20130708125352.GC20149@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 8 Jul 2013 14:53:52 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> > Good news! The test was running since morning and it didn't hang nor
> > crashed. So this really looks like the right fix. It will run also
> > during weekend to be 100% sure. But I guess it is safe to say
> 
> Hmm, it seems I was too optimistic or we have yet another issue here (I
> guess the later is more probable).
> 
> The weekend testing got stuck as well. 
> 
> The dmesg shows there were some hung tasks:

That looks like the classic "we lost an IO completion" trace.

I think it would be prudent to defer these patches into 3.12.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
