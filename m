Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7456B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:45:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so316595177pgh.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 12:45:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q77si12325744pfi.41.2017.03.13.12.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 12:45:01 -0700 (PDT)
Date: Mon, 13 Mar 2017 12:45:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 09/10] mm: make rmap_one boolean function
Message-Id: <20170313124500.ffc91fa4d4077719928e3274@linux-foundation.org>
In-Reply-To: <1489365353-28205-10-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
	<1489365353-28205-10-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Mon, 13 Mar 2017 09:35:52 +0900 Minchan Kim <minchan@kernel.org> wrote:

> rmap_one's return value controls whether rmap_work should contine to
> scan other ptes or not so it's target for changing to boolean.
> Return true if the scan should be continued. Otherwise, return false
> to stop the scanning.
> 
> This patch makes rmap_one's return value to boolean.

"SWAP_AGAIN" conveys meaning to the reader, whereas the meaning of
"true" is unclear.  So it would be better to document the return value
of these functions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
