Date: Wed, 24 Jan 2007 18:41:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <20070125093259.74f76144.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0701241841000.12325@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
 <20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>
 <20070124141510.7775829c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070125093259.74f76144.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007, KAMEZAWA Hiroyuki wrote:

> On Wed, 24 Jan 2007 14:15:10 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> >   And...some customers want to keep memory Free as much as possible.
> >   99% memory usage makes insecure them ;)
> > 
> If there is a way that the "free" command can show "never used" memory,
> they will not complain ;).
> 
> But I can't think of the way to show that.
> ==
> [kamezawa@aworks src]$ free
>             total       used       free     shared    buffers     cached
> Mem:        741604     724628      16976          0      62700     564600
> -/+ buffers/cache:      97328     644276
> Swap:      1052216       2532    1049684
> ==

Could we call the free memory "unused memory" and not talk about free 
memory at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
