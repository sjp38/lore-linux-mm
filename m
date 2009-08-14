Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EF79E6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 00:54:04 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so301631rvb.26
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 21:54:11 -0700 (PDT)
Message-ID: <4A84EDE4.1080605@vflare.org>
Date: Fri, 14 Aug 2009 10:23:56 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: compcache as a pre-swap area
References: <200908122007.43522.ngupta@vflare.org> <200908130805.36787.a1426z@gawab.com> <d760cf2d0908131031i2305f2deqe20d6a96c8d568af@mail.gmail.com> <200908140702.23947.a1426z@gawab.com>
In-Reply-To: <200908140702.23947.a1426z@gawab.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Al Boldi <a1426z@gawab.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/14/2009 09:32 AM, Al Boldi wrote:
> Nitin Gupta wrote:
>> compcache is really not really a swap replacement. Its just another
>> swap device that
>> compresses data and stores it in memory itself. You can have disk
>> based swaps along
>> with ramzswap (name of block device).
>
> So once compcache fills up, it will start to age its contents into normal
> swap?
>

This is desirable but not yet implemented. For now, if 'backing swap' is used, 
compcache will forward incompressible pages to the backing swap device. If 
compcache fills up, kernel will simply send further swap-outs to swap device 
which comes next in priority.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
