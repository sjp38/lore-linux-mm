Message-ID: <47BDEFB4.1010106@zytor.com>
Date: Thu, 21 Feb 2008 13:40:04 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: SMP-related kernel memory leak
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>	 <6101e8c40802191018t668faf3avba9beeff34f7f853@mail.gmail.com>	 <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>	 <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com> <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
In-Reply-To: <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Pinter <oliver.pntr@gmail.com>
Cc: Bart Van Assche <bart.vanassche@gmail.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-mm@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Oliver Pinter wrote:
>>> I have added a new graph to
>>> http://bugzilla.kernel.org/show_bug.cgi?id=9991, namely a graph
>>> showing memory usage for a PAE-kernel booted with mem=1G and with a
>>> minimized kernel config. The graph shows that memory usage increases
>>> to a certain limit. Other tests have shown that this limit is
>>> proportional to the amount of memory specified in mem=... This is not
>>> a SLAB leak: as the numbers show, slab usage remains constant during
>>> all tests.
>>>
>>> I'm puzzled by these results ...
>>>

This sounds to me a lot like the quicklist PUD leak we had, which I 
thought had been fixed in recent kernels...

It would be useful to know: does this happen with UP at all?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
