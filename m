Date: Tue, 4 Sep 2007 17:00:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu
 variable (v2) (fwd)
Message-Id: <20070904170058.a55b4284.akpm@linux-foundation.org>
In-Reply-To: <46DDE623.1090402@sgi.com>
References: <Pine.LNX.4.64.0708312028400.24049@schroedinger.engr.sgi.com>
	<46DDC017.4040301@sgi.com>
	<20070904141055.e00a60d7.akpm@linux-foundation.org>
	<46DDE623.1090402@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: clameter@sgi.com, steiner@sgi.com, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> On Tue, 04 Sep 2007 16:11:31 -0700 Mike Travis <travis@sgi.com> wrote:
> > 
> > It'd be better to convert the unconverted architectures?
> 
> I can easily do the changes for ia64 and test them.  I don't have the capability
> of testing on the powerpc.  
> 
> And are you asking for just the changes to fix the build problem, or the whole
> set of the changes that were made for x86_64 and i386 in regards to converting
> NR_CPU arrays to per cpu data?

Well...  it'd be better to have all architectures doing the same thing.  If
that's impractical then we should at least implement suitable accessor
functions into the arch so that core code doesn't need to handle some
architectures one way and others the other way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
