Message-ID: <46BA0114.7040801@tmr.com>
Date: Wed, 08 Aug 2007 13:44:52 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>	<20070804063217.GA25069@elte.hu>	<20070804070737.GA940@elte.hu>	<20070804103347.GA1956@elte.hu>	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>	<20070804163733.GA31001@elte.hu>	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>	<46B4C0A8.1000902@garzik.org>	<20070804191205.GA24723@lazybastard.org>	<20070804192130.GA25346@elte.hu>	<20070804211156.5f600d80@the-village.bc.nu>	<46B4E161.9080100@garzik.org>	<46B8C016.6090806@tmr.com> <20070807203502.66b9ebda@the-village.bc.nu>
In-Reply-To: <20070807203502.66b9ebda@the-village.bc.nu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> However, relatime has the POSIX behavior without the overhead. Therefore 
> 
> No. relatime has approximately SuS behaviour. Its not the same as
> "correct" behaviour.
> 
Actually correct, but in terms of what can or does break, relatime seems 
a lot closer than noatime, I can't (personally) come up with any 
scenario where real applications would see something which would change 
behavior adversely.

Making noatime a default in the kernel requiring a boot option to 
restore current behavior seems to be a turn toward the "it doesn't 
really work right but it's *fast*" model. If vendors wanted noatime they 
are smart enough to enable it. Now with relatime giving most of the 
benefits and few (of any) of the side effects, I would expect a change.

By all means relatime by default in FC8, but not noatime, and let those 
who find some measurable benefit from noatime use it.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
