Date: Tue, 5 Dec 2006 12:52:39 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: la la la la ... swappiness
Message-Id: <20061205125239.6ae448fe.akpm@osdl.org>
In-Reply-To: <20061205120256.b1db9887.akpm@osdl.org>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
	<Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
	<20061205085914.b8f7f48d.akpm@osdl.org>
	<f353cb6c194d4.194d4f353cb6c@texas.rr.com>
	<Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
	<Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
	<20061205120256.b1db9887.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Aucoin <aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006 12:02:56 -0800
Andrew Morton <akpm@osdl.org> wrote:

> But otoh, it's a very common scenario, and nobody has observed it before. 
> For example:
> 
> akpm2:/home/akpm# echo 4000 > /proc/sys/vm/nr_hugepages 
> 
> Free memory on this box instantly fell from 7G down to ~250MB.  It's now
> happily chuggling its way through a `dbench 512' run.

FS(small)VO "happily".  It's running like a complete dog (but I guess
dbench 512 in 256M is a bit mean).  But it's still running!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
