Received: by fg-out-1718.google.com with SMTP id e12so357317fga.4
        for <linux-mm@kvack.org>; Fri, 22 Feb 2008 15:12:24 -0800 (PST)
Message-ID: <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
Date: Sat, 23 Feb 2008 00:12:24 +0100
From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <47BEFD5D.402@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
	 <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>
	 <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>
	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>
	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>
	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
	 <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
	 <47BDEFB4.1010106@zytor.com>
	 <6101e8c40802220844h2553051bw38154dbad91de1e3@mail.gmail.com>
	 <47BEFD5D.402@zytor.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Bart Van Assche <bart.vanassche@gmail.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-mm@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

hi thanks,
but 421d99193537a6522aac2148286f08792167d5fd is never in 2.6.22.y  and
nor stable-queue-2.6.22.y ...

On 2/22/08, H. Peter Anvin <hpa@zytor.com> wrote:
> Oliver Pinter wrote:
> > Hi!
> >
> > what is the patch name or git ID?
>
> 96990a4ae979df9e235d01097d6175759331e88c
>
> However, there was a second portion,
> 421d99193537a6522aac2148286f08792167d5fd, which was then reverted at
> 49eaaa1a6c950e7a92c4386c199b8ec950f840b9.
>
> The fact that it doesn't happen on a single processor makes me believe
> it's still a problem with the quicklists not getting freed properly.  It
> would be nice if someone could go in with system tap or just plain
> "gdb vmlinux /proc/kcore" and verify if there is a large number of pages
> queued up on the quicklists on some of the CPUs, while at least one of
> them is zero.
>
> (It would be nice to have quicklist statistics exported somewhere, too.)
>
> 	-hpa
>


-- 
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
