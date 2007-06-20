Date: Tue, 19 Jun 2007 22:08:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Some thoughts on memory policies
In-Reply-To: <20070620040131.GA29240@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706192205410.18467@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
 <20070620040131.GA29240@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, wli@holomorphy.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jun 2007, Paul Mundt wrote:

> There's quite a bit of room for improving and extending the existing
> code, and those options should likely be exhausted first.

There is a confusing maze of special rules if one goes beyond the simple 
process address space case. There are no clean rules on how to combine 
memory policies. Refcounting / updating becomes a problem because policies 
are intended to be only updated from the process that set them up. Look at 
the gimmicks that Paul needed to do to update memory policies when a 
process is migrated and the vmas on the stack for shmem etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
