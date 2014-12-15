Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 873206B006E
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 01:17:41 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so7828651wid.11
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 22:17:41 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id x18si15307230wiv.98.2014.12.14.22.17.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 22:17:40 -0800 (PST)
Date: Mon, 15 Dec 2014 06:17:34 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 6/8] nfs: don't dirty ITER_BVEC pages read through direct
 I/O
Message-ID: <20141215061734.GU22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <e5240b33c30d147588d0cdd285d8d95463b3de18.1418618044.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e5240b33c30d147588d0cdd285d8d95463b3de18.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Dec 14, 2014 at 09:27:00PM -0800, Omar Sandoval wrote:
> As with the generic blockdev code, kernel pages shouldn't be dirtied by
> the direct I/O path.

This really asks for an inlined helper (iter_is_bvec(iter) or something like
that)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
