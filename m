Subject: Re: 2.5.70-mm6
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <20030607151440.6982d8c6.akpm@digeo.com>
References: <20030607151440.6982d8c6.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1055074197.584.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 08 Jun 2003 14:09:57 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2003-06-08 at 00:14, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm6/
> 
> . Numerous little fixes and additional work against additional patches.
> 
> . Waaay too many "cleanups".  These are taking significant amounts of
>   effort and it is time to start learning to live with dirty code.
> 
> . -mm kernels will be running at HZ=100 for a while.  This is because
>   the anticipatory scheduler's behaviour may be altered by the lower
>   resolution.  Some architectures continue to use 100Hz and we need the
>   testing coverage which x86 provides.

Testing it right now... It compiles nicely with gcc 3.3 (remember the
problems I had with snd-ymfpci when using gcc 3.2), boots and seems
functional.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
