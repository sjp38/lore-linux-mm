Date: Wed, 5 Sep 2007 01:40:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu
 variable (v2) (fwd)
Message-Id: <20070905014057.bf3d2f22.akpm@linux-foundation.org>
In-Reply-To: <200709050910.10954.ak@suse.de>
References: <Pine.LNX.4.64.0708312028400.24049@schroedinger.engr.sgi.com>
	<20070904141055.e00a60d7.akpm@linux-foundation.org>
	<46DDE623.1090402@sgi.com>
	<200709050910.10954.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: travis@sgi.com, clameter@sgi.com, steiner@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> On Wed, 5 Sep 2007 09:10:10 +0100 Andi Kleen <ak@suse.de> wrote:
> > I can easily do the changes for ia64 and test them.  I don't have the
> > capability of testing on the powerpc.
> 
> You can get cross compilers and make it compile

http://userweb.kernel.org/~akpm/cross-compilers/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
