Date: Tue, 4 Sep 2007 20:48:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu variable
 (v2) (fwd)
In-Reply-To: <20070904141055.e00a60d7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709042047380.7231@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0708312028400.24049@schroedinger.engr.sgi.com>
 <46DDC017.4040301@sgi.com> <20070904141055.e00a60d7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Travis <travis@sgi.com>, steiner@sgi.com, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Sep 2007, Andrew Morton wrote:

> > My question though, would include/linux/smp.h be the appropriate place for
> > the above define?  (That is, if the above approach is the correct one... ;-)
> 
> It'd be better to convert the unconverted architectures?

That is certainly the cleanest solution. Maybe we can only convert the 
variables used in the scheduler that way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
