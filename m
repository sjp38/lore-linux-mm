Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 9D3C538D56
	for <linux-mm@kvack.org>; Tue, 19 Jun 2001 16:05:22 -0300 (EST)
Date: Tue, 19 Jun 2001 16:05:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.6pre3: kswapd dominating CPU
In-Reply-To: <F341E03C8ED6D311805E00902761278C07EFA675@xfc04.fc.hp.com>
Message-ID: <Pine.LNX.4.33.0106191555250.1376-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "ZINKEVICIUS,MATT (HP-Loveland,ex1)" <matt_zinkevicius@hp.com>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2001, ZINKEVICIUS,MATT (HP-Loveland,ex1) wrote:

> For a while now 2.4 kernels have been a little flaky for us with
> regards to memory management. We had chalked this up to the
> known VM updates going on and have ignored and worked around it
> as much as we could. Now that 2.4.6pre3 is out and supposedly VM
> friendly and we are still seeing our original problem I thought
> it was time I submitted the details to you guys to get some
> help.
>
> We are benchmarking NFS with SpecSFS 97 version 2. When the
> machine gets close to running out of physical memory (according
> to top) kswapd quickly become the most active process (98% CPU
> time). This occurs whether or not we have any swap space
> enabled! The nfsd daemons get starved and our performance drops
> to null.

Ahhh, I see the problem.

The kswapd-eating-all-cpu problem is fixef in 2.4.6-pre3,
but only for DISK BASED filesystems and swap. For these
systems we will do synchronous IO once in a while and by
waiting on IO completion we avoid eating too much CPU.

For NFS we currently don't have any way to wait on IO
completion. I'll have to look into this later, I guess ;)

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
