Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 38C916B009E
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 03:49:22 -0400 (EDT)
Received: by vws18 with SMTP id 18so4756342vws.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 00:49:20 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Tue, 2 Nov 2010 08:49:20 +0100
Message-ID: <AANLkTinPTrc6FpBRTZbDcsOdwpRUayQuE+2K8U8yPorz@mail.gmail.com>
Subject: Where is the SLAM (a mutable slab allocator) development happening?
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hi,

while looking through the program of LPC, I have seen a proposal for a
talk called "SLAM: a mutable slab allocator" [1].

As there was no reference given to the code-base, I went searching on
the Wild Wild Web and found a thread called "[UnifiedV4 00/16] The
Unified slab allocator (V4)" posted to LKML.
It looks to me that these patches went to Pekka's slab/for-next GIT-branch [2].
I am not sure if this is "SLAM".

[1] says:
"I have worked as a kernel developer at Google for 3 1/2 years...",
not sure if David Rientjes email-address at Google is still valid,
thus I am sending my request to slab ML and Mainrtainers.

Can someone say where to get more informations on SLAM?
The commits in slab/for-next look also interesting to me, can someone
give an overview what can be expected in 2.6.38?
(I would give linux-next a try).

Thanks in advance for answering my questions.

Kind Regards,
- Sedat -

[1] http://www.linuxplumbersconf.org/2010/ocw/proposals/405
[2] http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=shortlog;h=refs/heads/for-next

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
