Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F392F6B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 06:20:07 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Date: Tue, 24 Mar 2009 21:27:35 +1100
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <20090319164638.GB3899@duck.suse.cz> <200903241844.22851.nickpiggin@yahoo.com.au>
In-Reply-To: <200903241844.22851.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903242127.36541.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 March 2009 18:44:21 Nick Piggin wrote:

> I close my eyes and pick something out of a hat. a686cd89. Search for XXX.
> Nice. Whether or not this cased the problem, can someone please tell me
> why it got merged in that state?

Actually I must be wrong about this if the problem was reproduced in
2.6.18. Question still stands, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
