Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 753546B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 21:36:48 -0500 (EST)
Received: by mail-oa0-f42.google.com with SMTP id i7so7711544oag.15
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 18:36:48 -0800 (PST)
Received: from g1t0028.austin.hp.com (g1t0028.austin.hp.com. [15.216.28.35])
        by mx.google.com with ESMTPS id rk9si5543074obb.12.2014.01.27.18.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 18:36:47 -0800 (PST)
Message-ID: <1390876601.27421.20.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 5/8] mm, hugetlb: use vma_resv_map() map types
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 27 Jan 2014 18:36:41 -0800
In-Reply-To: <1390856607-psfeyzze-mutt-n-horiguchi@ah.jp.nec.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
	 <1390794746-16755-6-git-send-email-davidlohr@hp.com>
	 <1390856607-psfeyzze-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-01-27 at 16:03 -0500, Naoya Horiguchi wrote:
> On Sun, Jan 26, 2014 at 07:52:23PM -0800, Davidlohr Bueso wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Util now, we get a resv_map by two ways according to each mapping type.
> > This makes code dirty and unreadable. Unify it.
> > 
> > Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> There are a few small nitpicking below ...

Will update, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
