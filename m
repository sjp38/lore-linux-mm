Message-ID: <3EEAD41B.2090709@us.ibm.com>
Date: Sat, 14 Jun 2003 00:51:55 -0700
From: Mingming Cao <cmm@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.5.70-mm9
References: <20030613013337.1a6789d9.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm9/
> 
> 
> Lots of fixes, lots of new things.
>

Good news, Andrew. I run 50 fsx tests on ext3 filesystems on 2.5.70-mm9. 
   The hang problem I used seen on 2.5.70-mm6 kernel is gone. The tests 
runs fine for more than 9 hours. (Normally the problem will occur after 
7 hours run on 2.5.70-mm6 kernel).

I am running the tests on 8 way PIII 700MHz, 4G memory, with 
elevator=deadline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
