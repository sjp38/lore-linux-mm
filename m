Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA01518
	for <linux-mm@kvack.org>; Sun, 30 Aug 1998 17:41:03 -0400
Date: Sun, 30 Aug 1998 16:10:44 +0100
Message-Id: <199808301510.QAA00801@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <87ogt4hhvh.fsf@atlas.CARNet.hr>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
	<199808280935.KAA06221@dax.dcs.ed.ac.uk>
	<87ogt4hhvh.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 29 Aug 1998 00:16:34 +0200, Zlatko Calusic
<Zlatko.Calusic@CARNet.hr> said:

[re update/bdflush:]

> Why is the former in the userspace?

Simply because the latter is the only one to have been moved to the
kernel.  That happened because the trigger for bdflush is an internal
kernel wait queue, whereas the trigger for update is a timer.  Timers
can be easily done in user space.

> I believe it is not that hard to code bdflush in the kernel, where we
> lose nothing, but save few pages of memory. One less process to run,
> as I already pointed out.

Dead easy.  It will save memory; it will also, more importantly, save
non-pageable memory (although the kernel thread will still need its
own kernel stack, it will not need the extra page tables which
accompany a user-space process).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
