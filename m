Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Fri, 31 Aug 2001 08:48:26 -0500
Message-Id: <3B8F94C0.9080103@syntegra.com>
Date: Fri, 31 Aug 2001 08:44:32 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010830221315Z16034-32383+2530@humbolt.nl.linux.org> <3B8EC0B8.3000504@syntegra.com> <20010830225802Z16121-32384+1142@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Unfortunately, I don't have this compiled in the kernel.  I'm 
recompiling now with the -ac5 patch and the debugging enabled.  I'll 
start another test with it and hopefully have better debug info within a 
couple hours.

Andy

Daniel Phillips wrote:
> On August 31, 2001 12:39 am, Andrew Kay wrote:
> 
>>I am running the stock klogd (1.4.0) from the redhat 7.1 install.  I'll 
>>give it a try with the 2.4.9-ac4 tomorrow.  The output you saw is from a 
>>  mostly static kernel (except for reiserfs).  Ps -aux shows a bit of 
>>output, but remember that it hangs after encountering the error... Mhsqd 
>>is one of our products.  I strongly suspect that the hung process is 
>>SMTPserver, which isn't shown
>>
> 
> OK, how about SysReq (t) for a backtrace of the stuck tasks.
> 
> --
> Daniel
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
