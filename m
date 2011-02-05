Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B9CCC8D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 13:23:29 -0500 (EST)
Received: by vws10 with SMTP id 10so2131652vws.14
        for <linux-mm@kvack.org>; Sat, 05 Feb 2011 10:23:28 -0800 (PST)
Message-ID: <4D4D95C6.20505@vflare.org>
Date: Sat, 05 Feb 2011 13:24:06 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: zcache and kztmem combine to become the new zcache
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

To zcache and kztmem users/reviewers --

We, Nitin and Dan, have decided to combine zcache and kztmem and
call the resulting work as zcache.

Since kztmem has evolved further than zcache, we have agreed to
use the kztmem code as the foundation for future work, so Dan will
resubmit the kztmem patchset soon with the name changed to zcache.

Since both the "old zcache" and "new zcache" depend on the proposed
cleancache patch, Nitin and Dan will jointly work with the Linux
maintainers to support merging of cleancache, and also work together
on possibilities for merging frontswap and zram, since they serve
a similar function.

If you have any questions or concerns, please ensure you reply
to both of us.

Nitin Gupta and Dan Magenheimer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
