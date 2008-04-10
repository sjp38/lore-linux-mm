Subject: Re: git-slub crashes on the t16p
In-Reply-To: <20080410015958.bc2fd041.akpm@linux-foundation.org>
Message-ID: <lnun8CCD.1207820081.9463900.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Thu, 10 Apr 2008 12:34:42 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, penberg@cs.helsinki.fi, clameter@sgi.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 4/10/2008, "Andrew Morton" <akpm@linux-foundation.org> wrote:
> It's the tree I pulled about 12 hours ago.  Quite early in boot.
> 
> crash: http://userweb.kernel.org/~akpm/p4105087.jpg
> config: http://userweb.kernel.org/~akpm/config-t61p.txt
> git-slub.patch: http://userweb.kernel.org/~akpm/mmotm/broken-out/git-slub.patch
> 
> A t61p is a dual-core x86_64.
> 
> I was testing with all of the -mm series up to and including git-slub.patch
> applied.

You have CONFIG_NUMA enabled, so we check for NULL in inc_slabs_node():

        if (!NUMA_BUILD || n) {
                atomic_long_inc(&n->nr_slabs);
                atomic_long_add(objects, &n->total_objects);

I think I hit the same problem and it went away after make clean. Hmm...

                                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
