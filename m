Date: Sun, 15 Sep 2002 00:17:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] add vmalloc stats to meminfo
Message-ID: <20020915071727.GI3530@holomorphy.com>
References: <3D8422BB.5070104@us.ibm.com> <3D84340A.25ED4C69@digeo.com> <20020915071157.GH3530@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020915071157.GH3530@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 15, 2002 at 12:11:57AM -0700, William Lee Irwin III wrote:
> Also, dynamic vmalloc allocations may very well be starved by boot-time
> allocations on systems where much vmallocspace is required for IO memory.
> The failure mode of such is effectively deadlock, since they block
> indefinitely waiting for permanent boot-time allocations to be freed up.

This is dead wrong. NFI wtf I was thinking. Ignore that one.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
