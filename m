Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5D28D003A
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 14:14:26 -0500 (EST)
Received: by fxm12 with SMTP id 12so4224309fxm.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:14:20 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110218190128.GF13211@ghostprotocols.net>
References: <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <20110218122938.GB26779@tiehlicka.suse.cz>
	 <20110218162623.GD4862@tiehlicka.suse.cz>
	 <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	 <m17hcx43m3.fsf@fess.ebiederm.org>
	 <AANLkTikh4oaR6CBK3NBazer7yjhE0VndsUB5FCDRsbJc@mail.gmail.com>
	 <20110218190128.GF13211@ghostprotocols.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 20:13:49 +0100
Message-ID: <1298056429.2425.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org

Le vendredi 18 fA(C)vrier 2011 A  17:01 -0200, Arnaldo Carvalho de Melo a
A(C)crit :

> Original code is ANK's, I just made it possible to use with DCCP, and
> yeah, the smiley is appropriate, something 6 years old and the world
> around it changing continually... well, thanks for the git blame ;-)
> 

At that time, net namespaces did not exist.

I would blame people implementing them ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
