Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1141932602.6393.68.camel@localhost.localdomain>
References: <1141928905.6393.10.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
	 <1141932602.6393.68.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 10 Mar 2006 09:15:21 -0500
Message-Id: <1142000122.5204.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 14:30 -0500, Lee Schermerhorn wrote:

> If you're interested in seeing an annotated trace log of direct
> migration
> and migrate-on-fault [lazy] in action, you can find one at:
> 
> http://free.linux.hp.com/~lts/Tools/mtrace-anon-8p-direct+lazy.log
> 
> This file contains the log for 2 memtoy runs, each migrating an 8 page
> anon segment from one node to another. 

Duh!  not my day..

correct link:
http://free.linux.hp.com/~lts/Tools/mmtrace-anon-8p-direct+lazy.log



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
