Date: Fri, 27 Sep 2002 23:04:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: mremap() pte allocation atomicity error
Message-ID: <20020928060450.GW3530@holomorphy.com>
References: <20020928052813.GY22942@holomorphy.com> <3D95442E.C0959F4A@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D95442E.C0959F4A@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 27, 2002 at 10:54:54PM -0700, Andrew Morton wrote:
> A simple fix would be to drop the atomic kmap of the source pte
> and take it again after the alloc_one_pte_map() call.
> Can you think of a more efficient way?

Not one that isn't highly invasive, no. This is what I had in mind
for the easy fix.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
