Date: Mon, 18 Jun 2007 12:00:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
In-Reply-To: <6bffcb0e0706181158l739864e0t6fb5bc564444f23c@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706181159430.1896@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>  <46767346.2040108@googlemail.com>
  <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
 <6bffcb0e0706181038j107e2357o89c525261cf671a@mail.gmail.com>
 <Pine.LNX.4.64.0706181102280.6596@schroedinger.engr.sgi.com>
 <6bffcb0e0706181158l739864e0t6fb5bc564444f23c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Michal Piotrowski wrote:

> Still the same.

Is it still exactly the same strack trace? There could be multiple issue 
if we overflow PAGE_SIZE there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
