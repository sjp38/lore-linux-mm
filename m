Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 74E299003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:03:34 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so100227602igb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:03:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d10si14172637igl.52.2015.07.22.15.03.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:03:34 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:03:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 03/10] mm/hugetlb: expose hugetlb fault mutex for use
 by fallocate
Message-Id: <20150722150332.9bf0735389f8dc57f720daf5@linux-foundation.org>
In-Reply-To: <1437502184-14269-4-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	<1437502184-14269-4-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 21 Jul 2015 11:09:37 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Minor name changes to
> be more consistent with other global hugetlb symbols.
> 
> ...
>
> -	kfree(htlb_fault_mutex_table);
> +	kfree(hugetlb_fault_mutex_table);

yay ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
