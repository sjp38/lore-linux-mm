Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACFB6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 23:27:17 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so105887263pab.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 20:27:17 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 12si5576824pfa.14.2015.11.26.20.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 20:27:16 -0800 (PST)
Subject: Re: [PATCHv12 32/37] thp: reintroduce split_huge_page()
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-33-git-send-email-kirill.shutemov@linux.intel.com>
 <564CA63C.8090800@oracle.com> <20151118190536.GA26376@node.shutemov.name>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5657DB81.1080705@oracle.com>
Date: Thu, 26 Nov 2015 23:26:41 -0500
MIME-Version: 1.0
In-Reply-To: <20151118190536.GA26376@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/18/2015 02:05 PM, Kirill A. Shutemov wrote:
> Hm. This looks like THP leak. I fixed one with this patch:
> 
> http://lkml.kernel.org/g/1447236567-68751-1-git-send-email-kirill.shutemov@linux.intel.com
> 
> It's in -mm tree, but there wasn't any releases since it's applied. It's
> not in -next for this reason.
> 
> There's one more patch with the same status:
> 
> http://lkml.kernel.org/g/1447236557-68682-1-git-send-email-kirill.shutemov@linux.intel.com

I still see it in -next, with these two patches in.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
