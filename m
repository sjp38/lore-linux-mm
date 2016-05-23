Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFC306B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 14:42:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so15514252wme.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:42:48 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gt6si45960637wjc.167.2016.05.23.11.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 11:42:47 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so17688595wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:42:47 -0700 (PDT)
Date: Mon, 23 May 2016 20:42:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
Message-ID: <20160523184246.GE32715@dhcp22.suse.cz>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> Currently khugepaged makes swapin readahead under
> down_write. This patch supplies to make swapin
> readahead under down_read instead of down_write.

You are still keeping down_write. Can we do without it altogether?
Blocking mmap_sem of a remote proces for write is certainly not nice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
