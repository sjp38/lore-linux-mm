Date: Sat, 4 Aug 2007 23:00:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070804230007.30857453.akpm@linux-foundation.org>
In-Reply-To: <87wswbjejw.fsf@mid.deneb.enyo.de>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804094119.81d8e533.akpm@linux-foundation.org>
	<87wswbjejw.fsf@mid.deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

On Sat, 04 Aug 2007 21:16:35 +0200 Florian Weimer <fw@deneb.enyo.de> wrote:

> * Andrew Morton:
> 
> > The easy preventive is to mount with data=writeback.  Maybe that should
> > have been the default.
> 
> The documentation I could find suggests that this may lead to a
> security weakness (old data in blocks of a file that was grown just
> before the crash leaks to a different user).

yup.  This problem also exists in ext2, reiserfs (unless using
ordered-mode), JFS, others.

>  XFS overwrites that data
> with zeros upon reboot, which tends to irritate users when it happens.

yup.

> >From this point of view, data=ordered doesn't seem too bad.

If your computer is used by multiple users who don't trust each other,
sure.  That covers, what?  About 2% of machines?

I was using data=writeback for a while on my most-thrashed disk.  The
results were a bit disappointing - not much difference.  ext2 is a lot
quicker.

(I don't use anything which is fsync-happy, btw).  (I used to have a patch
which sysctl-tunably turned fsync, msync, fdatasync into "return 0" for use
on the laptop but I seem to have lost it)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
