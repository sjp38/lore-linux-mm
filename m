Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B56806B0075
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 05:33:03 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so2068878wiw.9
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 02:33:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si1829927wiw.60.2014.12.12.02.33.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 02:33:00 -0800 (PST)
Date: Fri, 12 Dec 2014 11:32:59 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [RFC PATCH v3 6/7] btrfs: add EXTENT_FLAG_SWAPFILE
Message-ID: <20141212103259.GM27601@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1418173063.git.osandov@osandov.com>
 <f489d4ad85df4039f3a84f1a2f89735c9a1cf88d.1418173063.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f489d4ad85df4039f3a84f1a2f89735c9a1cf88d.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 09, 2014 at 05:45:47PM -0800, Omar Sandoval wrote:
> Extents mapping a swap file should remain pinned in memory in order to
> avoid doing allocations to look up an extent when we're already low on
> memory. Rather than overloading EXTENT_FLAG_PINNED, add a new flag
> specifically for this purpose.
> 
> Signed-off-by: Omar Sandoval <osandov@osandov.com>

Reviewed-by: David Sterba <dsterba@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
