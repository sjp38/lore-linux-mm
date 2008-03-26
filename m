Date: Wed, 26 Mar 2008 12:16:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] x86: Modify Kconfig to allow up to 4096 cpus
In-Reply-To: <47EA7A5A.5030207@sgi.com>
Message-ID: <Pine.LNX.4.64.0803261215320.31000@schroedinger.engr.sgi.com>
References: <20080326014137.934171000@polaris-admin.engr.sgi.com>
 <20080326014138.292294000@polaris-admin.engr.sgi.com>
 <20080326160924.GC1789@cs181133002.pp.htv.fi> <47EA7A5A.5030207@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Adrian Bunk <bunk@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Mar 2008, Mike Travis wrote:

> I guess the main effect is that "MAXSMP" represents what's really
> usable for an architecture based on other factors.  The limit of
> NODES_SHIFT = 15 is that it's represented in some places as a signed
> 16-bit value, so 15 is the hard limit without coding changes, not
> an architecture limit.

NODES_SHIFT also controls how many page flag bits are set aside for the 
node number. If you limit x86_64 to 512 nodes then lets keep this at 9.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
