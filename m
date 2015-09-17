Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 67AB66B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:13:31 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so28386977wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:13:30 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id w4si4707236wju.16.2015.09.17.08.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 08:13:30 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so31808421wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:13:29 -0700 (PDT)
Date: Thu, 17 Sep 2015 18:13:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v5 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-ID: <20150917151327.GA31549@node.dhcp.inet.fi>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1442259105-4420-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1442259105-4420-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Sep 14, 2015 at 10:31:45PM +0300, Ebru Akagunduz wrote:
> This patch makes swapin readahead to improve thp collapse rate.
> When khugepaged scanned pages, there can be a few of the pages
> in swap area.
> 
> With the patch THP can collapse 4kB pages into a THP when
> there are up to max_ptes_swap swap ptes in a 2MB range.
> 
> The patch was tested with a test program that allocates
> 400B of memory, writes to it, and then sleeps. I force
> the system to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area.
> 
> Without the patch, system did not swap in readahead.
> THP rate was %65 of the program of the memory, it
> did not change over time.
> 
> With this patch, after 10 minutes of waiting khugepaged had
> collapsed %99 of the program's memory.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>

[ resend with correct TO/CC lists]
