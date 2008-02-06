Date: Wed, 6 Feb 2008 14:10:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: statistics improvements
In-Reply-To: <47AA2955.50502@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0802061409420.3712@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <20080206001948.6f749aa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802061259490.26108@schroedinger.engr.sgi.com>
 <47AA2955.50502@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2008, Eric Dumazet wrote:

> > +	for_each_online_cpu(cpu) {
> > +		int x = get_cpu_slab(s, cpu)->stat[si];
> 
> unsigned int x = ...

Ahh. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
