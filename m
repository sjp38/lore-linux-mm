Date: Fri, 10 Aug 2007 11:53:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
Message-Id: <20070810115352.ef869659.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708101125390.17312@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
	<20070810004059.8aa2aadb.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708101125390.17312@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007 11:37:13 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Then we need this patch?
> 
> SLUB dynamic kmalloc cache create: Prevent scheduling sysfs_add_slab workqueue twice.

No, that's OK - see the test_and_set_bit() in queue_work().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
