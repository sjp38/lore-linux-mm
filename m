Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD8F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 01:28:35 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so840742wiw.13
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 22:28:34 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id x6si1704869wif.15.2014.12.18.22.28.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 22:28:34 -0800 (PST)
Date: Fri, 19 Dec 2014 06:28:27 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141219062827.GV22149@ZenIV.linux.org.uk>
References: <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
 <20141217082437.GA9301@infradead.org>
 <20141217145832.GA3497@mew>
 <20141217185256.GA5657@infradead.org>
 <20141217220313.GK22149@ZenIV.linux.org.uk>
 <20141219062405.GA11486@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141219062405.GA11486@mew>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Dec 18, 2014 at 10:24:05PM -0800, Omar Sandoval wrote:
> +       swap_file = file_open_name(name, O_RDWR | O_LARGEFILE | O_DIRECT, 0);
> +       if (IS_ERR(swap_file) && PTR_ERR(swap_file) == -EINVAL)

ITYM if (swap_file == ERR_PTR(-EINVAL)) here...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
