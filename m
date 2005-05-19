Date: Thu, 19 May 2005 15:54:41 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
Message-Id: <20050519155441.7a8e94f9.akpm@osdl.org>
In-Reply-To: <17036.56626.994129.265926@gargle.gargle.HOWL>
References: <17035.30820.347382.9137@gargle.gargle.HOWL>
	<200505181757.j4IHv0g14491@unix-os.sc.intel.com>
	<17036.56626.994129.265926@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>
Cc: kenneth.w.chen@intel.com, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander <wwc@rentec.com> wrote:
>
> Clearly one has to weight the performance issues against the memory
>  efficiency but since we demonstratibly throw away 25% (or 1GB) of the
>  available address space in the various accumulated holes a long
>  running application can generate

That sounds pretty bad.

> I hope that for the time being we can
>  stick with my first solution,

I'm inclined to do this.

> preferably extended by your munmap fix?

And this, if someone has a patch? 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
