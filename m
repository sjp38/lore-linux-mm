Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F6B46B00B9
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:53:30 -0400 (EDT)
Received: by fxm2 with SMTP id 2so2979727fxm.4
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:53:36 -0700 (PDT)
Message-ID: <4AB8F2BE.8060007@vflare.org>
Date: Tue, 22 Sep 2009 21:22:30 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] compcache: in-memory compressed swapping v4
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org> <1253600030.30406.2.camel@penberg-laptop> <20090922153752.GA24256@kroah.com>
In-Reply-To: <20090922153752.GA24256@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On 09/22/2009 09:07 PM, Greg KH wrote:
> On Tue, Sep 22, 2009 at 09:13:50AM +0300, Pekka Enberg wrote:
>> On Tue, 2009-09-22 at 10:26 +0530, Nitin Gupta wrote:
>>>  drivers/staging/Kconfig                   |    2 +
>>>  drivers/staging/Makefile                  |    1 +
>>>  drivers/staging/ramzswap/Kconfig          |   21 +
>>>  drivers/staging/ramzswap/Makefile         |    3 +
>>>  drivers/staging/ramzswap/ramzswap.txt     |   51 +
>>>  drivers/staging/ramzswap/ramzswap_drv.c   | 1462 +++++++++++++++++++++++++++++
>>>  drivers/staging/ramzswap/ramzswap_drv.h   |  173 ++++
>>>  drivers/staging/ramzswap/ramzswap_ioctl.h |   50 +
>>>  drivers/staging/ramzswap/xvmalloc.c       |  533 +++++++++++
>>>  drivers/staging/ramzswap/xvmalloc.h       |   30 +
>>>  drivers/staging/ramzswap/xvmalloc_int.h   |   86 ++
>>>  include/linux/swap.h                      |    5 +
>>>  mm/swapfile.c                             |   34 +
>>>  13 files changed, 2451 insertions(+), 0 deletions(-)
>>
>> This diffstat is not up to date, I think.
>>
>> Greg, would you mind taking this driver into staging? There are some
>> issues that need to be ironed out for it to be merged to kernel proper
>> but I think it would benefit from being exposed to mainline.
> 
> That would be fine, will there be a new set of patches for me to apply,
> or is this the correct series?
> 

This is the correct series.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
