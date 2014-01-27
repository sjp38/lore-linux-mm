Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id C7F8D6B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:04:34 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so8940553qcq.32
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:04:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e60si9539002qgf.182.2014.01.27.13.04.33
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:04:33 -0800 (PST)
Date: Mon, 27 Jan 2014 16:04:23 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856663-xenxk2ck-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-8-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-8-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 7/8] mm, hugetlb: mm, hugetlb: unify chg and avoid_reserve
 to use_reserve
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:25PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Currently, we have two variable to represent whether we can use reserved
> page or not, chg and avoid_reserve, respectively. With aggregating these,
> we can have more clean code. This makes no functional difference.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
