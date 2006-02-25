From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] sys_migrate_pages: Allow the specification of migration options
Date: Sat, 25 Feb 2006 06:21:02 +0100
References: <Pine.LNX.4.64.0602241728300.24858@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602241728300.24858@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602250621.03637.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Saturday 25 February 2006 02:42, Christoph Lameter wrote:
> Andi, 
> 
> Andrew suggested to add another parameter to sys_migrate_pages in an 
> earlier thread. We discussed a patch that made sys_migrate_pages 
> move all pages of a process when invoked as root. Here is an alternate 
> patch adding a parameter that would give root control if migrate_pages 
> will move pages referenced only by the specified process or all 
> referenced pages.
> 
> This would break numactl and require another update cycle. What would you 
> prefer? 

No problem from my side if you can get the change in before 2.6.16.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
