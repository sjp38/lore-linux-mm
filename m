Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 19KhVD-0005ik-00
	for <linux-mm@kvack.org>; Tue, 27 May 2003 18:40:43 +0200
From: Nicholas Wourms <nwourms@myrealbox.com>
Subject: Re: 2.5.69-mm9
Date: Sun, 25 May 2003 12:47:08 -0400
Message-ID: <3ED0F38C.5020203@myrealbox.com>
References: <20030525042759.6edacd62.akpm@digeo.com> <200305251456.39404.rudmer@legolas.dynup.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rudmer van Dijk wrote:
> On Sunday 25 May 2003 13:27, Andrew Morton wrote:
> 
>>. 2.5.69-mm9 is not for the timid.  It includes extensive changes to the
>>  ext3 filesystem and the JBD layer.  It withstood an hour of testing on my
>>  4-way, but it probably has a couple of holes still.
> 
> 
> there seems to be no problem, it survives a kernel compile.
> Only the patch for fs/buffer.c seems to be reverted, it was there in -mm8
> (original patch by wli, adjusted to cleanly apply against -mm9)
> 
> 	Rudmer
> 

It looks like he "silently" updated aio-06-bread_wq-fix.patch with an 
additional fix, but it overwrote the existing diffs in that file.

Cheers,
Nicholas


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
