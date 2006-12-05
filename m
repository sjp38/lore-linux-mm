Date: Tue, 5 Dec 2006 11:32:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: la la la la ... swappiness
In-Reply-To: <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
Message-ID: <Pine.LNX.4.64.0612051130200.18569@schroedinger.engr.sgi.com>
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org> <20061205085914.b8f7f48d.akpm@osdl.org>
 <f353cb6c194d4.194d4f353cb6c@texas.rr.com> <Pine.LNX.4.64.0612051031170.11860@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0612051038250.3542@woody.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Aucoin <aucoin@houston.rr.com>, Andrew Morton <akpm@osdl.org>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Dec 2006, Linus Torvalds wrote:
> On Tue, 5 Dec 2006, Christoph Lameter wrote:
> > We do not support swapping / reclaim for huge pages.
> 
> Well, Louis doesn't actually _want_ swapping or reclaim on them. He just 
> wants the system to run well with the remaining 400MB of memory in his 
> machine.
> 
> Which it doesn't. It just OOM's for some reason.

If you take huge chunks of memory out of a zone then the dirty limits as 
well as the min free kbytes etc are all off. As a result the VM may 
behave strangely.  F.e. too many dirty pages may cause an OOM since we do 
not enter synchrononous writeout during reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
