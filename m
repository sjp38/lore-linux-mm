From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/14] Per zone counter functionality
Date: Fri, 9 Jun 2006 06:38:28 +0200
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com> <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com> <20060608210045.62129826.akpm@osdl.org>
In-Reply-To: <20060608210045.62129826.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606090638.28167.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Friday 09 June 2006 06:00, Andrew Morton wrote:
> On Thu, 8 Jun 2006 16:02:44 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Per zone counter infrastructure
> > 
> 
> Is the use of 8-bit accumulators more efficient than using 32-bit ones? 
> Obviously it's better from a cache POV, given that we have a pretty large
> array of them.  But is there a downside on some architectures in not using
> the natural wordsize?   

Maybe on very old alphas which didn't have 8 bit stores. They need a RMW cycle.

Other than that i wouldn't expect any problems. RISCs will just do the usual
32bit add in registers, but do a 8bit load/store.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
