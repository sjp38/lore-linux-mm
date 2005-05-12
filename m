Date: Thu, 12 May 2005 09:07:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Avoiding mmap fragmentation  (against 2.6.12-rc4) to
Message-ID: <20050512070736.GA15494@elte.hu>
References: <20050510115818.0828f5d1.akpm@osdl.org> <200505101934.j4AJYfg26483@unix-os.sc.intel.com> <20050510124357.2a7d2f9b.akpm@osdl.org> <17025.4213.255704.748374@gargle.gargle.HOWL> <20050510125747.65b83b4c.akpm@osdl.org> <17026.6227.225173.588629@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17026.6227.225173.588629@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>
Cc: Andrew Morton <akpm@osdl.org>, kenneth.w.chen@intel.com, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Wolfgang Wander <wwc@rentec.com> wrote:

> The patch below is against linux-2.6.12-rc4.
> 
> Ingo recently introduced a great speedup for allocating new mmaps 
> using the free_area_cache pointer which boosts the specweb SSL 
> benchmark by 4-5% and causes huge performance increases in thread 
> creation.

small correction: 'recently' was more than 2.5 years ago (!). So this 
issue is something that hits certain rare workloads. Note that the mmap 
speedup was also backported to 2.4 so it is quite widely deployed. This 
is the first time anyone complained.

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
