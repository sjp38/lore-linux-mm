Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA08596
	for <linux-mm@kvack.org>; Mon, 26 Oct 1998 09:45:42 -0500
Date: Mon, 26 Oct 1998 14:44:47 GMT
Message-Id: <199810261444.OAA00983@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: swap/memory patches
In-Reply-To: <Pine.LNX.3.96.981023121950.1238B-100000@dragon.bogus>
References: <Pine.LNX.3.96.981022214651.12636B-100000@mirkwood.dummy.home>
	<Pine.LNX.3.96.981023121950.1238B-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Kurt Garloff <garloff@kg1.ping.de>, Linux kernel list <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

In article <Pine.LNX.3.96.981023121950.1238B-100000@dragon.bogus>,
Andrea Arcangeli <andrea@e-mind.com> writes:

> On Thu, 22 Oct 1998, Rik van Riel wrote:
>>> (1) cow-swapin: I often observed that after compiling a large C++ program
>>> (which needs some swap), the shell keeps swapping something in on every
>>> <Enter> keypress. This is cured by swapoff -a; swapon -a.
>>> If I correctly understood, this is what cow-swapin was supposed to cure.
>> 
>> Wasn't this fixed -- Andrea, Stephen?

> Just fixed in Linus's tree.

Definitely should be!  The fix went in in 2.1.123, so if you can
reproduce the problem on any later kernel, we'd like to hear about it.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
