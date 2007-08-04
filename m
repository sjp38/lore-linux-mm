Date: Sat, 4 Aug 2007 21:26:15 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804192615.GA25600@lazybastard.org>
References: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070804192130.GA25346@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sat, 4 August 2007 21:21:30 +0200, Ingo Molnar wrote:
> * JA?rn Engel <joern@logfs.org> wrote:
> 
> > > I actually vote for that.  IMO, distros should turn -on- atime 
> > > updates when they know its needed.
> > 
> > If you mean "relatime" I concur.  "noatime" hurts mutt and others 
> > while "relatime" has no known problems, afaics.
> 
> so ... one app can keep 30,000+ apps hostage?
> 
> i use Mutt myself, on such a filesystem:
> 
>    /dev/md0 on / type ext3 (rw,noatime,nodiratime,user_xattr)
> 
> and i can see no problems, it notices new mails just fine.

Given the choice between only "atime" and "noatime" I'd agree with you.
Heck, I use it myself.  But "relatime" seems to combine the best of both
worlds.  It currently just suffers from mount not supporting it in any
relevant distro.

JA?rn

-- 
Joern's library part 2:
http://www.art.net/~hopkins/Don/unix-haters/tirix/embarrassing-memo.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
