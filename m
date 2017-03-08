Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23ED76B0396
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:25:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so42111560pgc.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:25:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s2si2274147plk.272.2017.03.07.22.25.20
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 22:25:21 -0800 (PST)
Date: Wed, 8 Mar 2017 15:25:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
Message-ID: <20170308062519.GE11206@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-2-git-send-email-minchan@kernel.org>
 <20170307141933.GA2779@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307141933.GA2779@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

Hi Kirill,

On Tue, Mar 07, 2017 at 05:19:33PM +0300, Kirill A. Shutemov wrote:
> On Thu, Mar 02, 2017 at 03:39:15PM +0900, Minchan Kim wrote:
> > SWAP_SUCCESS defined value 0 can be changed always so don't rely on
> > it. Instead, use explict macro.
> 
> I'm okay with this as long as it's prepartion for something meaningful.
> 0 as success is widely used. I don't think replacing it's with macro here
> has value on its own.

It's the prepartion for making try_to_unmap return bool type but strictly
speaking, it's not necessary but I wanted to replace it with SWAP_SUCCESS
in this chance because it has several *defined* return type so it would
make it clear if we use one of those defiend type, IMO.
However, my thumb rule is to keep author/maintainer's credit for trivial
case and it seems you don't like so I will drop in next spin.

Thanks.


> 
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
