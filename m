Received: by ug-out-1314.google.com with SMTP id c2so619725ugf
        for <linux-mm@kvack.org>; Sat, 04 Aug 2007 10:38:44 -0700 (PDT)
Date: Sat, 4 Aug 2007 19:38:01 +0200
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070804193801.d310d025.diegocg@gmail.com>
In-Reply-To: <20070804171724.GA4740@elte.hu>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<20070804190210.8b1530dd.diegocg@gmail.com>
	<20070804171724.GA4740@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

El Sat, 4 Aug 2007 19:17:24 +0200, Ingo Molnar <mingo@elte.hu> escribio:

> i've got util-linux-2.13-0.46.fc6 and 2.6.22 on that box, shouldnt that 
> be recent enough? As far as i can see it from the kernel-side code, this 
> works on the general VFS level and hence should be supported by ext3 
> already.

Mmmh, "mount -o remount,noatime /" seems to Work For Me in Ubuntu
with util-linux/mount "2.12r-17ubuntu"...but then Google says [1] that
Ubuntu has been shipping with relatime enabled as default for months,
so it's probably patched (probably only in the kernel). So maybe upstream
util-linux hasn't merged the relatime patch.

[1]: http://lkml.org/lkml/2007/2/12/30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
