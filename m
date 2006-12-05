Date: Tue, 5 Dec 2006 12:02:56 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: la la la la ... swappiness
Message-Id: <20061205120256.b1db9887.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
	<Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
	<20061205085914.b8f7f48d.akpm@osdl.org>
	<f353cb6c194d4.194d4f353cb6c@texas.rr.com>
	<Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
	<Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 11:32:21 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 5 Dec 2006, Linus Torvalds wrote:
> > On Tue, 5 Dec 2006, Christoph Lameter wrote:
> > > We do not support swapping / reclaim for huge pages.
> > 
> > Well, Louis doesn't actually _want_ swapping or reclaim on them. He just 
> > wants the system to run well with the remaining 400MB of memory in his 
> > machine.
> > 
> > Which it doesn't. It just OOM's for some reason.
> 
> If you take huge chunks of memory out of a zone then the dirty limits as 
> well as the min free kbytes etc are all off. As a result the VM may 
> behave strangely.  F.e. too many dirty pages may cause an OOM since we do 
> not enter synchrononous writeout during reclaim.

yes, it's quite possible that this setup would cause the page reclaim
arithmetic to go wrong.

But otoh, it's a very common scenario, and nobody has observed it before. 
For example:

akpm2:/home/akpm# echo 4000 > /proc/sys/vm/nr_hugepages 

Free memory on this box instantly fell from 7G down to ~250MB.  It's now
happily chuggling its way through a `dbench 512' run.

But this is a 64-bit machine.  Could be that there are problems on 32-bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
