Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 83CDD6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:02:46 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so8740218qcv.19
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:02:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 8si8194371qav.178.2014.01.27.13.02.44
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:02:45 -0800 (PST)
Date: Mon, 27 Jan 2014 16:02:19 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856539-4i40zgqy-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-2-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-2-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 1/8] mm, hugetlb: unify region structure handling
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:19PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Currently, to track reserved and allocated regions, we use two different
> ways, depending on the mapping. For MAP_SHARED, we use address_mapping's
> private_list and, while for MAP_PRIVATE, we use a resv_map.
> 
> Now, we are preparing to change a coarse grained lock which protect a
> region structure to fine grained lock, and this difference hinder it.
> So, before changing it, unify region structure handling, consistently
> using a resv_map regardless of the kind of mapping.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> [Updated changelog]
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
