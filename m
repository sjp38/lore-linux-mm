Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id A601982F64
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 05:27:27 -0400 (EDT)
Received: by wijq8 with SMTP id q8so120224337wij.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:27:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kw5si16296566wjb.201.2015.10.15.02.27.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Oct 2015 02:27:26 -0700 (PDT)
Subject: Re: [RFC v2 1/3] migrate: new struct migration and add it to struct
 page
References: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
 <1444900142-1996-2-git-send-email-zhuhui@xiaomi.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561F7173.3000900@suse.cz>
Date: Thu, 15 Oct 2015 11:27:15 +0200
MIME-Version: 1.0
In-Reply-To: <1444900142-1996-2-git-send-email-zhuhui@xiaomi.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

On 10/15/2015 11:09 AM, Hui Zhu wrote:
> I got that add function interfaces is really not a good idea.
> So I add a new struct migration to put all migration interfaces and add
> this struct to struct page as union of "mapping".

That's better, but not as flexible as the previously proposed approaches 
that Sergey pointed you at:

  http://lkml.iu.edu/hypermail/linux/kernel/1507.0/03233.html
  http://lkml.iu.edu/hypermail/linux/kernel/1508.1/00696.html

There the operations are reachable via mapping, so we can support the 
special operations migration also when mapping is otherwise needed; your 
patch excludes mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
