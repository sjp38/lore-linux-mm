Message-ID: <3ECCBD6B.9070807@aitel.hist.no>
Date: Thu, 22 May 2003 14:07:07 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.69-mm8
References: <20030522021652.6601ed2b.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm8/
> 
> . One anticipatory scheduler patch, but it's a big one.  I have not stress
>   tested it a lot.  If it explodes please report it and then boot with
>   elevator=deadline.
> 
> . The slab magazine layer code is in its hopefully-final state.
> 
> . Some VFS locking scalability work - stress testing of this would be
>   useful.


It seems to work fine for UP and survives a kernel compile.

Helge Hafting


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
