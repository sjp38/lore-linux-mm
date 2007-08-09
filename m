Received: by ug-out-1314.google.com with SMTP id c2so405057ugf
        for <linux-mm@kvack.org>; Thu, 09 Aug 2007 09:51:04 -0700 (PDT)
Date: Thu, 9 Aug 2007 18:22:37 +0200
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070809182237.b5afc4c7.diegocg@gmail.com>
In-Reply-To: <46BB2C8E.2050205@redhat.com>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<20070804163733.GA31001@elte.hu>
	<20070809062511.GA23435@capsaicin.mamane.lu>
	<46BB2C8E.2050205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Ebbert <cebbert@redhat.com>
Cc: Lionel Elie Mamane <lionel@mamane.lu>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingcha@pimp.vs19.net
List-ID: <linux-mm.kvack.org>

El Thu, 09 Aug 2007 11:02:38 -0400, Chuck Ebbert <cebbert@redhat.com> escribio:

> NT maintains atimes by default, at least up to XP. You have to edit the
> registry to turn them off, and it is a single global switch -- not per
> mountpoint like Unix.
> 
> And it makes a huge difference there, too.

In windows Vista they've disabled atime updates by default.

And XP maintains atimes, but it uses a trick to avoid the performance
penalty we suffer in linux, similar to what Andi Kleen suggested: they
keep atime updates in memory for one hour, and only sync to disk after
that time - of course they also sync it if there's a oportunity to do it, like
when updating mtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
