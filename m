Subject: Re: 2.5.69-mm8
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <20030522021652.6601ed2b.akpm@digeo.com>
References: <20030522021652.6601ed2b.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1053629620.596.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 22 May 2003 20:53:41 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-05-22 at 11:16, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm8/
> 
> . One anticipatory scheduler patch, but it's a big one.  I have not stress
>   tested it a lot.  If it explodes please report it and then boot with
>   elevator=deadline.
> 
> . The slab magazine layer code is in its hopefully-final state.
> 
> . Some VFS locking scalability work - stress testing of this would be
>   useful.

Running on it right now... Compiles and boots. I'm sure it won't explode
on my face :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
