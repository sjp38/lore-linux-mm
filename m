Message-ID: <4030B48F.2070603@tmr.com>
Date: Mon, 16 Feb 2004 07:16:15 -0500
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: 2.6.3-rc3-mm1
References: <20040216015823.2dafabb4.akpm@osdl.org>
In-Reply-To: <20040216015823.2dafabb4.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

linux-kernel" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > Please read the FAQ at  http://www.tux.org/lkml/
 >

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc3/2.6.3-rc3-mm1/
> 
> 
> - New hotplug CPU implementation from Rusty
> 
> - Dropped the x86 CPU-type selection patches

Was there a problem with this? Seems like a good start to allow cleaning 
up some "but I don't have that CPU" things which embedded and tiny 
systems really would like to eliminate.
> 
> - Added support for dynamic allocation of unix98 ptys.

Good to get more testing on this.

-- 
bill davidsen <davidsen@tmr.com>
   CTO TMR Associates, Inc
   Doing interesting things with small computers since 1979
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
