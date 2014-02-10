Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 172A76B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:11:29 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id q9so8703560ykb.2
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:11:28 -0800 (PST)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id g10si11527977yhn.159.2014.02.10.13.11.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 13:11:28 -0800 (PST)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Mon, 10 Feb 2014 13:11:15 -0800
Subject: RE: [patch] drop_caches: add some documentation and info message
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E2DD2208E1C@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
	<52F51E19.9000406@redhat.com>	<20140207181332.GG6963@cmpxchg.org>
	<20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
	<20140207212601.GI6963@cmpxchg.org>
 <20140210125102.86de67241664da038676af7d@linux-foundation.org>
In-Reply-To: <20140210125102.86de67241664da038676af7d@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Tuesday, February 11, 2014 5:51 AM
> To: Johannes Weiner
> Cc: Rik van Riel; Dave Hansen; Michal Hocko; Motohiro Kosaki JP; KAMEZAWA
> Hiroyuki; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [patch] drop_caches: add some documentation and info
> message
>=20
> On Fri, 7 Feb 2014 16:26:01 -0500 Johannes Weiner <hannes@cmpxchg.org>
> wrote:
>=20
> > On Fri, Feb 07, 2014 at 12:31:29PM -0800, Andrew Morton wrote:
> > > On Fri, 7 Feb 2014 13:13:32 -0500 Johannes Weiner
> <hannes@cmpxchg.org> wrote:
> > >
> > > > @@ -63,6 +64,9 @@ int drop_caches_sysctl_handler(ctl_table *table,
> int write,
> > > >  			iterate_supers(drop_pagecache_sb, NULL);
> > > >  		if (sysctl_drop_caches & 2)
> > > >  			drop_slab();
> > > > +		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel
> caches: %d\n",
> > > > +				   current->comm, task_pid_nr(current),
> > > > +				   sysctl_drop_caches);
> > > >  	}
> > > >  	return 0;
> > > >  }
> > >
> > > My concern with this is that there may be people whose
> > > other-party-provided software uses drop_caches.  Their machines will
> > > now sit there emitting log messages and there's nothing they can do
> > > about it, apart from whining at their vendors.
> >
> > Ironically, we have a customer that is complaining that we currently
> > do not log these events, and they want to know who in their stack is
> > being idiotic.
>=20
> Right.  But if we release a kernel which goes blah on every write to
> drop_caches, that customer has logs full of blahs which they are now tota=
lly
> uninterested in.

Please let me know if I misunderstand something. This patch uses KERN_INFO.
Then, any log shouldn't be emitted by default.

Moreover, if someone change syslog log level to INFO, they are going to see
much prenty annoying and too much logs even if we reject this patch.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
