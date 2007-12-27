Date: Thu, 27 Dec 2007 11:31:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20071227153235.GA6443@skywalker>
Message-ID: <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org>
 <20071227153235.GA6443@skywalker>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007, Aneesh Kumar K.V wrote:

> On Tue, Dec 25, 2007 at 02:05:19PM -0800, Andrew Morton wrote:
> > On Thu, 20 Dec 2007 15:35:41 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > ------------[ cut here ]------------
> > > kernel BUG at mm/slab.c:3320!

An attempt to allocate from an offline node? What NUMA architecture did 
this occur on?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
