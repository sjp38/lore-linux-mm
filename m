Received: by ug-out-1314.google.com with SMTP id s2so18721uge
        for <linux-mm@kvack.org>; Tue, 01 May 2007 02:17:41 -0700 (PDT)
Message-ID: <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
Date: Tue, 1 May 2007 12:17:28 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: 2.6.22 -mm merge plans
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, npiggin@suse.de, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On 5/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>  revoke-special-mmap-handling.patch

[snip]

> Hold.  This is tricky stuff and I don't think we've seen sufficient
> reviewing, testing and acking yet?

Agreed. While Peter and Nick have done some review of the patches, I
would really like VFS maintainers to review them before merge.
Christoph, have you had the chance to take a look at it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
