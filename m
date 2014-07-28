Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB0A6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 18:43:30 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so7584962iec.10
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:43:30 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id nh10si21882015icc.92.2014.07.28.15.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 15:43:29 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so4385601igd.5
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:43:28 -0700 (PDT)
Date: Mon, 28 Jul 2014 15:43:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't allow fault_around_bytes to be 0
In-Reply-To: <53D62599.6000605@samsung.com>
Message-ID: <alpine.DEB.2.02.1407281542460.8998@chino.kir.corp.google.com>
References: <53D07E96.5000006@oracle.com> <1406533400-6361-1-git-send-email-a.ryabinin@samsung.com> <20140728093611.GA3975@node.dhcp.inet.fi> <53D62599.6000605@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>

On Mon, 28 Jul 2014, Andrey Ryabinin wrote:

> do_fault_around expects fault_around_bytes rounded down to nearest
> page order. Instead of calling rounddown_pow_of_two every time
> in fault_around_pages()/fault_around_mask() we could do round down
> when user changes fault_around_bytes via debugfs interface.
> 

If you're going to optimize this, it seems like fault_around_bytes would 
benefit from being __read_mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
