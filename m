Date: Sat, 4 Aug 2007 21:23:50 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804212350.1b5b3aae@the-village.bc.nu>
In-Reply-To: <20070804165604.GA2310@elte.hu>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<20070804095143.b8cc2c78.akpm@linux-foundation.org>
	<20070804165604.GA2310@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

> i tried to convince distro folks about it ... but there's fear, 
> uncertainty and doubt about touching /etc/fstab and i suspect no major 
> distro will do it until another does it - which is a catch-22 :-/ So i 

Thats what Gentoo is for ;)

> guess we should add a kernel config option that allows the kernel rpm 
> maker to just disable atime by default. (re-enableable via boot-line and 
> fstab entry too) [That new kernel config option would be disabled by 
> default.] That makes it much easier to control and introduce.

It makes it much more messy and awkward as the same system behaves in
arbitary different ways under different builds of the kernel.

If you want to sort this in Fedora for example you just need to package
and announce a desktop-tuning rpm which makes the relevant updates on
install and reverses them on remove. Stick the scheduler/vm tuning values
in as well and the disk queue tweaks.

Regardless of the kernel defaults people will install such a package
en-mass...

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
