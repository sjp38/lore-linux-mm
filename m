Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id CE4D56B0072
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 20:01:00 -0400 (EDT)
Message-ID: <508F188D.2000408@ce.jp.nec.com>
Date: Tue, 30 Oct 2012 09:00:13 +0900
From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20121026061206.GA31139@thunk.org> <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com> <20121026184649.GA8614@thunk.org> <3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com> <20121027221626.GA9161@thunk.org> <20121029011632.GN29378@dastard> <20121029024024.GC9365@thunk.org> <m27gq9r2cu.fsf@firstfloor.org> <20121029182455.GA7098@thunk.org> <m21ughksh3.fsf@firstfloor.org>
In-Reply-To: <m21ughksh3.fsf@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On 10/30/12 04:07, Andi Kleen wrote:
> Theodore Ts'o <tytso@mit.edu> writes:
>> Note that the problem that we're dealing with is buffered writes; so
>> it's quite possible that the process which wrote the file, thus
>> dirtying the page cache, has already exited; so there's no way we can
>> guarantee we can inform the process which wrote the file via a signal
>> or a error code return.
> 
> Is that any different from other IO errors? It doesn't need to 
> be better.

IMO, it is different in that next read from disk will likely succeed.
(and read corrupted data)
For IO errors come from disk failure, next read will likely fail
again so we don't have to remember it somewhere.

>> Also, if you're going to keep this state in memory, what happens if
>> the inode gets pushed out of memory? 
> 
> You lose the error, just like you do today with any other IO error.

-- 
Jun'ichi Nomura, NEC Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
