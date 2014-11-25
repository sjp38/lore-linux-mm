Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A49A06B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 00:55:38 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so14097662wgh.6
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 21:55:38 -0800 (PST)
Received: from fw5a.wadns.net (fw5a-katy.wadns.net. [41.185.62.20])
        by mx.google.com with ESMTPS id qa3si356151wjc.62.2014.11.24.21.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 21:55:37 -0800 (PST)
Message-ID: <547419D6.40905@swiftspirit.co.za>
Date: Tue, 25 Nov 2014 07:55:34 +0200
From: Brendan Hide <brendan@swiftspirit.co.za>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
References: <cover.1416563833.git.osandov@osandov.com> <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com> <20141121180045.GF8568@twin.jikos.cz> <20141122200357.GA15189@mew> <20141124220302.GA5785@mew.dhcp4.washington.edu>
In-Reply-To: <20141124220302.GA5785@mew.dhcp4.washington.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Filipe David Manana <fdmanana@gmail.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On 2014/11/25 00:03, Omar Sandoval wrote:
> [snip]
>
> The snapshot issue is a little tricker to resolve. I see a few options:
>
> 1. Just do the COW and hope for the best
> 2. As part of btrfs_swap_activate, COW any shared extents. If a snapshot
> happens while a swap file is active, we'll fall back to 1.
> 3. Clobber any swap file extents which are in a snapshot, i.e., always use the
> existing extent.
>
> I'm partial to 3, as it's the simplest approach, and I don't think it makes
> much sense for a swap file to be in a snapshot anyways. I'd appreciate any
> comments that anyone might have.
>
Personally, 3 seems pragmatic - but not necessarily "correct". :-/

-- 
__________
Brendan Hide
http://swiftspirit.co.za/
http://www.webafrica.co.za/?AFF1E97

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
