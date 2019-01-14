Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB3308E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:42:02 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id v3so1099965itf.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:42:02 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b9si1055679itb.70.2019.01.14.15.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:42:01 -0800 (PST)
Date: Mon, 14 Jan 2019 15:40:42 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH] mm, swap: Potential NULL dereference in
 get_swap_page_of_type()
Message-ID: <20190114234042.cx6rjovpf2osaili@ca-dmjordan1.us.oracle.com>
References: <20190111095919.GA1757@kadam>
 <20190111174128.oak64htbntvp7j6y@ca-dmjordan1.us.oracle.com>
 <20190114084310.GD4504@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190114084310.GD4504@kadam>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Omar Sandoval <osandov@fb.com>, Tejun Heo <tj@kernel.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, andrea.parri@amarulasolutions.com

On Mon, Jan 14, 2019 at 11:43:10AM +0300, Dan Carpenter wrote:
> I'm really terribly ignorant when it comes to things like this...  To me
> it looked like the barrier in alloc_swap_info() was enough but when so
> many smarter people disagree then I must be wrong.  I'd like to help,
> but I sort of feel unqualified.
> 
> Could someone else take care of it?

I'm not the most qualified person either, but I gave it a try anyway.  Patch to
follow.
