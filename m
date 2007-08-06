Date: Mon, 6 Aug 2007 11:59:19 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070806155919.GA21066@redhat.com>
References: <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805072141.GA4414@elte.hu> <20070805184408.GB22639@redhat.com> <20070806063909.GB31321@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806063909.GB31321@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Mon, Aug 06, 2007 at 08:39:09AM +0200, Ingo Molnar wrote:
 > 
 > * Dave Jones <davej@redhat.com> wrote:
 > 
 > >  > btw., Mutt does not go boom, i use it myself. It works just fine 
 > >  > and notices new mails even on a noatime,nodiratime filesystem.
 > >  
 > > It still fails miserably for me.
 > > 
 > > If I hit 'C' and '?' I get a list of my mail folders, with some of 
 > > them marked 'N' if they have new mail.  Without atime, those N's never 
 > > show up and every mbox looks like it has no new mail.
 > 
 > does it work with the "atime on steroids" patch below? (no need to 
 > configure anything, just apply the patch and go.)

people have reported that relatime does work, but my util-linux
isn't new enough to support it, so I've never got it to work.
I'll give your diff a try later, though as it seems to be
equivalent I expect it'll work.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
