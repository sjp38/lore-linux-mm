Message-ID: <47BF5932.9040200@zytor.com>
Date: Fri, 22 Feb 2008 15:22:26 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: SMP-related kernel memory leak
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>	 <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>	 <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>	 <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>	 <47BDEFB4.1010106@zytor.com>	 <6101e8c40802220844h2553051bw38154dbad91de1e3@mail.gmail.com>	 <47BEFD5D.402@zytor.com> <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
In-Reply-To: <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Pinter <oliver.pntr@gmail.com>
Cc: Bart Van Assche <bart.vanassche@gmail.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-mm@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Oliver Pinter wrote:
> hi thanks,
> but 421d99193537a6522aac2148286f08792167d5fd is never in 2.6.22.y  and
> nor stable-queue-2.6.22.y ...

That's a serious problem.  This is a critical bug.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
