Date: Sun, 5 Aug 2007 20:08:26 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805180826.GD3244@elte.hu>
References: <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805073709.GA6325@elte.hu> <20070805134328.1a4474dd@the-village.bc.nu> <20070805125433.GA22060@elte.hu> <20070805143708.279f51f8@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805143708.279f51f8@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> And you honestly think that putting it in Kconfig as well as allowing 
> users to screw up horribly and creating incompatible defaults you

So far you've not offered one realistic scenario of "screw up horribly". 
People have been using noatime for a long time and there are no horror 
stories about that. _Which_ OSS HSM software relies on atime?

> can't test for in a user space app where it matters is going to 
> *change* this.

The patch i posted today adds /proc/sys/kernel/mount_with_atime. That 
can be tested by user-space, if it truly cares about atime.

> Do you really think anyone who said "noatime, compatibility, umm errr" 
> is going to say "noatime, compatibility, but hey its in Kconfig lets 
> do it". You argument doesn't hold up to minimal rational 
> consideration. Posting to the distribution devel list with: "Its a 50% 
> performance win, we need to fix these corner cases, here's a tmpwatch 
> patch" is *exactly* what is needed to change it, and Kconfig options 
> are irrelevant to that.

i did exactly that 6 months ago, check your email folders. I went by the 
"process". But it doesnt really matter anymore, Ubuntu has done the step 
and Fedora will be forced to do it too. But it's sad that it took us 10 
years. I'd like to remind you again:

|| ...For me, I would say 50% is not enough to describe the _visible_ 
|| benefits... Not talking any specific number but past 10sec-1min+ 
|| lagging in X is history, it's gone and I really don't miss it that 
|| much... :-) Cannot reproduce even a second long delay anymore in 
|| window focusing under considerable load as it's basically 
|| instantaneous (I can see that it's loaded but doesn't affect the 
|| feeling of responsiveness I'm now getting), even on some loads that I 
|| couldn't previously even dream of... [...]

we really have to ask ourselves whether the "process" is correct if 
advantages to the user of this order of magnitude can be brushed aside 
with simple "this breaks binary-only HSM" and "it's not standards 
compliant" arguments.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
