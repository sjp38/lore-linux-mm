Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 37E5F6B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:15:38 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so4559245pab.19
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:15:38 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id m2si7421061pdd.157.2014.11.21.02.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 02:15:36 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so4591186pab.4
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:15:35 -0800 (PST)
Date: Fri, 21 Nov 2014 02:15:31 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 0/5] btrfs: implement swap file support
Message-ID: <20141121101531.GB21814@mew>
References: <cover.1416563833.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>

Sorry for the noise, looks like Christoph got back to me on the previous RFC
just before I sent this out -- disregard this for now.

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
