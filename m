Date: Wed, 23 Mar 2005 09:23:58 -0500
From: Martin Hicks <mort@bork.org>
Subject: Re: [PATCH] min_free_kbytes limit
Message-ID: <20050323142358.GD19113@localhost>
References: <2c1942a7050323033448e3b26f@mail.gmail.com> <20050323140049.GC19113@localhost> <2c1942a705032306177b0a9ebe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c1942a705032306177b0a9ebe@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Levent Serinol <lserinol@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 23, 2005 at 04:17:32PM +0200, Levent Serinol wrote:
> init_per_zone_pages_min() function. The problem with min_free_kbytes
> is, it's integer and accepts signed values. There should be something
> to like this to avoid problems for example setting min_free_kbytes
> value to below zero.
> 

min_free_kbytes is limited to > 0 by the sysctl handler in
kernel/sysctl.c

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
