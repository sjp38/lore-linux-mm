Date: Sat, 27 Nov 2004 06:19:40 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-ID: <20041127081940.GB7740@logos.cnet>
References: <16800.47044.75874.56255@gargle.gargle.HOWL> <20041126185833.GA7740@logos.cnet> <16808.23030.312384.635657@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16808.23030.312384.635657@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@vger.kernel.org>, Andrew Morton <AKPM@Osdl.ORG>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 27, 2004 at 01:41:58PM +0300, Nikita Danilov wrote:
> Marcelo Tosatti writes:
> 
> [...]
> 
>  > 
>  > Average Half Load -j 4 Run:                     Average Half Load -j 4 Run:
>  > Elapsed Time 274.916                            Elapsed Time 245.026
>  > User Time 833.63                                User Time 832.34
>  > System Time 73.704                              System Time 73.41
>  > Percent CPU 335.8                               Percent CPU 373.6
>  > Context Switches 12984.8                        Context Switches 13427.4
>  > Sleeps 21459.2                                  Sleeps 21642
> 
> What is "System Time" here? Does in include CPU consumption by, say,
> kswapd?

I dont think "System Time" counts for kswapd - but only time spent inside 
the kernel, including page reclamation efforts.

> If not, then one may conjecture that mark_page_accessed batching
> modifies ordering of pages on zone "LRU" lists in a way that measurably
> changes efficiency of VM scanning, and mostly affects process that scans
> most---kswapd.

I agree.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
