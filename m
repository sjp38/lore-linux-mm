Message-ID: <47C5CB71.60203@zytor.com>
Date: Wed, 27 Feb 2008 12:43:29 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: SMP-related kernel memory leak
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>  <6101e8c40802191018t668faf3avba9beeff34f7f853@mail.gmail.com>  <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>  <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>  <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>  <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>  <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com> <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com> <47BDEFB4.1010106@zytor.com> <Pine.LNX.4.64.0802271156510.1790@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802271156510.1790@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Oliver Pinter <oliver.pntr@gmail.com>, Bart Van Assche <bart.vanassche@gmail.com>, linux-mm@kvack.org, linux-mm@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 21 Feb 2008, H. Peter Anvin wrote:
> 
>> This sounds to me a lot like the quicklist PUD leak we had, which I thought
>> had been fixed in recent kernels...
> 
> This was a pgd leak only AFAICT.
> 

This was for 3-level page tables, so PGD == PUD.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
