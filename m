Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9804B6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 17:47:59 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Date: Mon, 29 Oct 2012 17:47:36 -0400
Message-Id: <1351547256-837-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <m21ughksh3.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Dave Chinner <david@fromorbit.com>, Tony Luck <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Mon, Oct 29, 2012 at 12:07:04PM -0700, Andi Kleen wrote:
> Theodore Ts'o <tytso@mit.edu> writes:
...
> > Also, if you're going to keep this state in memory, what happens if
> > the inode gets pushed out of memory? 
> 
> You lose the error, just like you do today with any other IO error.
> 
> We had a lot of discussions on this when the memory error handling
> was originally introduced, that was the conclusuion.
> 
> I don't think a special panic knob for this makes sense either.
> We already have multiple panic knobs for memory errors, that
> can be used.

Yes. I understand that adding a new knob is not good.
So this patch uses the existing ext4 knob without adding new one.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
