Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E41036B0032
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 13:42:44 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so56297084wib.1
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 10:42:44 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id ex6si30880908wjc.35.2015.06.21.10.42.42
        for <linux-mm@kvack.org>;
        Sun, 21 Jun 2015 10:42:43 -0700 (PDT)
Date: Sun, 21 Jun 2015 20:42:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 1/3] mm: add tracepoint for scanning pages
Message-ID: <20150621174204.GA6611@node.dhcp.inet.fi>
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-2-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434799686-7929-2-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Sat, Jun 20, 2015 at 02:28:04PM +0300, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.
> 
> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
