Date: Sun, 5 Aug 2007 16:17:09 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805141708.GB25753@lazybastard.org>
References: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805072141.GA4414@elte.hu> <20070805085354.GC6002@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070805085354.GC6002@1wt.eu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, 5 August 2007 10:53:54 +0200, Willy Tarreau wrote:
> On Sun, Aug 05, 2007 at 09:21:41AM +0200, Ingo Molnar wrote:
> > 
> > btw., Mutt does not go boom, i use it myself. It works just fine and 
> > notices new mails even on a noatime,nodiratime filesystem.
> 
> IIRC, atime is used by mailers and by the shell to detect that new
> mail has arrived and report it only once if there are several intances
> watching the same mbox.
> 
> I too use mutt and noatime,nodiratime everywhere (same 10 year-old
> thinko), and the only side effect is that when I have a new mail,
> it is reported in all of my xterms until I read it, clearly something
> I can live with (and sometimes it's even desirable).
> 
> In fact, mutt is pretty good at this. It updates atime and ctime itself
> as soon as it opens the mbox, so the shell is happy and only reports
> "you have mail" afterwards.

For me mutt fails to recognize new mail.  And the difference might be
this:
http://www.google.de/search?q=enable-buffy-size

JA?rn

-- 
Fancy algorithms are slow when n is small, and n is usually small.
Fancy algorithms have big constants. Until you know that n is
frequently going to be big, don't get fancy.
-- Rob Pike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
