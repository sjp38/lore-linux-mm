Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE6E6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 05:53:44 -0400 (EDT)
Received: by pabur7 with SMTP id ur7so884574pab.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:53:43 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id yn3si20430934pbb.6.2015.10.15.02.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 02:53:42 -0700 (PDT)
Received: by pabur7 with SMTP id ur7so884088pab.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:53:42 -0700 (PDT)
Date: Thu, 15 Oct 2015 18:53:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2 1/3] migrate: new struct migration and add it to struct
 page
Message-ID: <20151015095328.GA7001@bgram>
References: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
 <1444900142-1996-2-git-send-email-zhuhui@xiaomi.com>
 <561F7173.3000900@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561F7173.3000900@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hui Zhu <zhuhui@xiaomi.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Thu, Oct 15, 2015 at 11:27:15AM +0200, Vlastimil Babka wrote:
> On 10/15/2015 11:09 AM, Hui Zhu wrote:
> >I got that add function interfaces is really not a good idea.
> >So I add a new struct migration to put all migration interfaces and add
> >this struct to struct page as union of "mapping".
> 
> That's better, but not as flexible as the previously proposed
> approaches that Sergey pointed you at:
> 
>  http://lkml.iu.edu/hypermail/linux/kernel/1507.0/03233.html
>  http://lkml.iu.edu/hypermail/linux/kernel/1508.1/00696.html
> 
> There the operations are reachable via mapping, so we can support
> the special operations migration also when mapping is otherwise
> needed; your patch excludes mapping.
> 

Hello Hui,

FYI, I take over the work from Gioh and have a plan to improve the work.
So, Could you wait a bit? Of course, if you have better idea, feel free
to post it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
