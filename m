From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804094119.81d8e533.akpm@linux-foundation.org>
	<87wswbjejw.fsf@mid.deneb.enyo.de>
	<20070804230007.30857453.akpm@linux-foundation.org>
Date: Sun, 05 Aug 2007 09:57:02 +0200
In-Reply-To: <20070804230007.30857453.akpm@linux-foundation.org> (Andrew
	Morton's message of "Sat, 4 Aug 2007 23:00:07 -0700")
Message-ID: <87r6miza5t.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

* Andrew Morton:

>>  XFS overwrites that data with zeros upon reboot, which tends to
>> irritate users when it happens.
>
> yup.
>
>> >From this point of view, data=ordered doesn't seem too bad.
>
> If your computer is used by multiple users who don't trust each other,
> sure.  That covers, what?  About 2% of machines?

I wasn't concerned so much with security, but with user experience.
For instance, some editors don't perform fsync-then-rename, but simply
truncate the file when saving (because they want to preserve hard
links).  With XFS, this tends to cause null bytes on crashes.  Since
ext3 has got a much larger install base, this would result in lots of
bug reports, I fear.

Without zeroing, the truncating editor might garble the file in a more
obvious way, but you've got the security issue (and I agree that this
is more of a PR issue).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
