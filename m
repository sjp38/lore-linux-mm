Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78A958D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:30:00 -0500 (EST)
Received: by bwz16 with SMTP id 16so3530815bwz.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:29:57 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1298010320.2642.7.camel@edumazet-laptop>
References: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <m1sjvm822m.fsf@fess.ebiederm.org>
	 <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	 <20110217.203647.193696765.davem@davemloft.net>
	 <1298010320.2642.7.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 08:29:51 +0100
Message-ID: <1298014191.2642.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com, opurdila@ixiacom.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Le vendredi 18 fA(C)vrier 2011 A  07:25 +0100, Eric Dumazet a A(C)crit :
> Le jeudi 17 fA(C)vrier 2011 A  20:36 -0800, David Miller a A(C)crit :
> > 
> > Eric D., please get a final version of the fix posted to netdev and
> > I'll make sure it slithers it's way to Linus's tree :-)
> > 
> > Thanks!
> 
> I believe we can apply Linus patch as is for current linux-2.6
> 
> Then add a second patch for previous kernels (the parts I added), since
> we might had a previous bug, un-noticed ?
> 

I am working on this right now, to make sure "my part" is really needed
for stable teams.

I'll send an update in a couple of hours.

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
