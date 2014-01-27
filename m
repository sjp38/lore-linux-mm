Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id D15556B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:02:47 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so7913764qae.41
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:02:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x3si9550150qat.127.2014.01.27.13.02.46
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:02:47 -0800 (PST)
Date: Mon, 27 Jan 2014 16:02:36 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856556-dityfj6m-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-3-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-3-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 2/8] mm, hugetlb: region manipulation functions take
 resv_map rather list_head
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:20PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> To change a protection method for region tracking to find grained one,
> we pass the resv_map, instead of list_head, to region manipulation
> functions. This doesn't introduce any functional change, and it is just
> for preparing a next step.
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
