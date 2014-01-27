Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 89BDA6B0038
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:03:25 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so8767321qcz.17
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:03:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ew5si8156064qab.135.2014.01.27.13.03.23
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:03:24 -0800 (PST)
Date: Mon, 27 Jan 2014 16:03:08 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856588-jyjp0cd0-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-5-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-5-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 4/8] mm, hugetlb: remove resv_map_put
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:22PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> This is a preparation patch to unify the use of vma_resv_map() regardless
> of the map type. This patch prepares it by removing resv_map_put(), which
> only works for HPAGE_RESV_OWNER's resv_map, not for all resv_maps.
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
