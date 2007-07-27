Date: Fri, 27 Jul 2007 03:00:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070727030040.0ea97ff7.akpm@linux-foundation.org>
In-Reply-To: <20070727014749.85370e77.akpm@linux-foundation.org>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<p73abtkrz37.fsf@bingen.suse.de>
	<46A85D95.509@kingswood-consulting.co.uk>
	<20070726092025.GA9157@elte.hu>
	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	<20070726094024.GA15583@elte.hu>
	<20070726030902.02f5eab0.akpm@linux-foundation.org>
	<1185454019.6449.12.camel@Homer.simpson.net>
	<20070726110549.da3a7a0d.akpm@linux-foundation.org>
	<1185513177.6295.21.camel@Homer.simpson.net>
	<1185521021.6295.50.camel@Homer.simpson.net>
	<20070727014749.85370e77.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 01:47:49 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> More sophisticated testing is needed - there's something in
> ext3-tools which will mmap, page in and hold a file for you.

So much for that theory.  afaict mmapped, active pagecache is immune to
updatedb activity.  It just sits there while updatedb continues munching
away at the slab and blockdev pagecache which it instantiated.  I assume
we're never getting the VM into enough trouble to tip it over the
start-reclaiming-mapped-pages threshold (ie: /proc/sys/vm/swappiness).

Start the updatedb on this 128MB machine with 80MB of mapped pagecache, it
falls to 55MB fairly soon and then never changes.

So hrm.  Are we sure that updatedb is the problem?  There are quite a few
heavyweight things which happen in the wee small hours.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
