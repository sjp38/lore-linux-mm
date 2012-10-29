Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 889CA6B0072
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 06:37:07 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20121026061206.GA31139@thunk.org>
	<3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
	<20121026184649.GA8614@thunk.org>
	<3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com>
	<20121027221626.GA9161@thunk.org> <20121029011632.GN29378@dastard>
	<20121029024024.GC9365@thunk.org>
Date: Mon, 29 Oct 2012 03:37:05 -0700
In-Reply-To: <20121029024024.GC9365@thunk.org> (Theodore Ts'o's message of
	"Sun, 28 Oct 2012 22:40:24 -0400")
Message-ID: <m27gq9r2cu.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

Theodore Ts'o <tytso@mit.edu> writes:

> On Mon, Oct 29, 2012 at 12:16:32PM +1100, Dave Chinner wrote:
>> 
>> Except that there are filesystems that cannot implement such flags,
>> or require on-disk format changes to add more of those flags. This
>> is most definitely not a filesystem specific behaviour, so any sort
>> of VFS level per-file state needs to be kept in xattrs, not special
>> flags. Filesystems are welcome to optimise the storage of such
>> special xattrs (e.g. down to a single boolean flag in an inode), but
>> using a flag for something that dould, in fact, storage the exactly
>> offset and length of the corruption is far better than just storing
>> a "something is corrupted in this file" bit....
>
> Agreed, if we're going to add an xattr, then we might as well store

I don't think an xattr makes sense for this. It's sufficient to keep
this state in memory.

In general these error paths are hard to test and it's important
to keep them as simple as possible. Doing IO and other complexities
just doesn't make sense. Just have the simplest possible path
that can do the job.

> not just a boolean, but some indication of what part of the file was

You're overdesigning I think.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
