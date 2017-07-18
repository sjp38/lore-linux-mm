Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 432B16B02F4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 20:00:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p10so5412639pgr.6
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:00:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y16si420993pfi.434.2017.07.17.17.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 17:00:20 -0700 (PDT)
Date: Mon, 17 Jul 2017 17:00:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/3] mm:hugetlb:  Define system call hugetlb size
 encodings in single file
Message-ID: <20170718000018.GD14983@bombadil.infradead.org>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-2-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500330481-28476-2-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Mon, Jul 17, 2017 at 03:27:59PM -0700, Mike Kravetz wrote:
> +#define HUGETLB_FLAG_ENCODE_512KB	(19 << MAP_HUGE_SHIFT
> +#define HUGETLB_FLAG_ENCODE_1MB		(20 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_2MB		(21 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_8MB		(23 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_16MB	(24 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_1GB		(30 << MAP_HUGE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE__16GB	(34 << MAP_HUGE_SHIFT)

The __ seems like a mistake?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
