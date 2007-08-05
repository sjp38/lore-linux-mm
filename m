Subject: Re: [PATCH 00/23] per device dirty throttling -v8
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070805144645.GA28263@thunk.org>
References: <20070803123712.987126000@chello.nl>
	 <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu>
	 <200708050051.40758.ctpm@ist.utl.pt>
	 <20070805014926.400d0608@the-village.bc.nu>
	 <20070805144645.GA28263@thunk.org>
Content-Type: text/plain
Date: Sun, 05 Aug 2007 11:08:19 -0700
Message-Id: <1186337299.2777.19.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> 
> In addition, big server boxes are usually not reading a huge *number*
> of files per second.  The place where you see this as a problem is (a)
> compilation, thanks to huge /usr/include hierarchies (and here things
> have gotten worse over time as include files have gotten much more
> complex than in the early Unix days), and (b) silly desktop apps that
> want to scan huge numbers of XML files or who want to read every
> single image file on the desktop or in an open file browser window to
> show c00l icons.  Oh, and I guess I should include Maildir setups.
> 
> If you are always reading from the same small set of files (i.e., a
> database workload), then those inodes only get updated every 5 seconds
> (the traditional/default metadata update sync time, as well as the
> default ext3 journal update time), it's no big deal.  Or if you are
> running a mail server, most of the time the mail queue files are
> getting updated anyway as you process them, and usually the mail is
> delivered before 5 seconds is up anyway.  


it's just one of those things that get compounded with journaling
filesystems though..... a single async write that happens "sometime in
the future" is one thing... having a full transaction (which acts as
barrier and synchronisation point) is something totally worse.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
