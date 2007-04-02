From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Tue, 3 Apr 2007 00:31:24 +0200
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com> <1175550968.22373.122.camel@localhost.localdomain>
In-Reply-To: <1175550968.22373.122.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704030031.24898.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Monday 02 April 2007 23:56:08 Dave Hansen wrote:
> On Mon, 2007-04-02 at 14:28 -0700, Christoph Lameter wrote:
> > I do not care what its called as long as it 
> > covers all the bases and is not a glaring performance regresssion (like 
> > SPARSEMEM so far). 
> 
> I honestly don't doubt that there are regressions, somewhere.  Could you
> elaborate, and perhaps actually show us some numbers on this?  Perhaps
> instead of adding a completely new model, we can adapt the existing ones
> somehow.

If it works I would be inclined to replaced old sparsemem with Christoph's
new one on x86-64. Perhaps that could cut down the bewildering sparsemem
ifdef jungle that is there currently.

But I presume it won't work on 32bit because of the limited address space?

> But, without some cold, hard, data, we mere mortals without the 1024-way
> machines can only guess. ;)

Yep.

-Andi (who would be scared of a 1024 way x86 machine)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
