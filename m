Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE936B0073
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:19:21 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so5031683pdj.20
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:19:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id dp1si7475050pdb.139.2014.11.21.02.19.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 02:19:19 -0800 (PST)
Date: Fri, 21 Nov 2014 02:19:14 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 0/5] btrfs: implement swap file support
Message-ID: <20141121101914.GA380@infradead.org>
References: <cover.1416563833.git.osandov@osandov.com>
 <20141121101531.GB21814@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121101531.GB21814@mew>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

On Fri, Nov 21, 2014 at 02:15:31AM -0800, Omar Sandoval wrote:
> Sorry for the noise, looks like Christoph got back to me on the previous RFC
> just before I sent this out -- disregard this for now.

If the NFS people are fine with this version I'd certainly welcome it as
a first step.  Additional improvements are of course always welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
