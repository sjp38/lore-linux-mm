Message-ID: <3E56D954.90803@cyberone.com.au>
Date: Sat, 22 Feb 2003 12:58:44 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.62-mm2
References: <20030220234733.3d4c5e6d.akpm@digeo.com> <200302212048.09802.tomlins@cam.org>
In-Reply-To: <200302212048.09802.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:

>On February 21, 2003 02:47 am, Andrew Morton wrote:
>
>>So this tree has three elevators (apart from the no-op elevator).  You can
>>select between them via the kernel boot commandline:
>>
>>        elevator=as
>>        elevator=cfq
>>        elevator=deadline
>>
>
>Has anyone been having problems booting with 'as'?  It hangs here at the point
>root gets mounted readonly.  cfq works ok.
>
What sort of disk controller arrangement and drivers are you using?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
