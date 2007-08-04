Date: Sat, 4 Aug 2007 18:56:04 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804165604.GA2310@elte.hu>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <20070804095143.b8cc2c78.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804095143.b8cc2c78.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> > yeah, it's really ugly. But otherwise i've got no real complaint 
> > about ext3 - with the obligatory qualification that 
> > "noatime,nodiratime" in /etc/fstab is a must. This speeds up things 
> > very visibly - especially when lots of files are accessed. It's kind 
> > of weird that every Linux desktop and server is hurt by a noticeable 
> > IO performance slowdown due to the constant atime updates,
> 
> Not just more IO: it will cause great gobs of blockdev pagecache to 
> remain in memory, too.

i tried to convince distro folks about it ... but there's fear, 
uncertainty and doubt about touching /etc/fstab and i suspect no major 
distro will do it until another does it - which is a catch-22 :-/ So i 
guess we should add a kernel config option that allows the kernel rpm 
maker to just disable atime by default. (re-enableable via boot-line and 
fstab entry too) [That new kernel config option would be disabled by 
default.] That makes it much easier to control and introduce.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
