Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D57996B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:46:31 -0400 (EDT)
Received: by wgin8 with SMTP id n8so9347407wgi.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 00:46:31 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id ls4si12458461wjb.83.2015.04.23.00.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 00:46:30 -0700 (PDT)
Received: by widdi4 with SMTP id di4so205403283wid.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 00:46:29 -0700 (PDT)
Message-ID: <5538A352.2050503@suse.cz>
Date: Thu, 23 Apr 2015 09:46:26 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
References: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>	<alpine.DEB.2.10.1504091235500.11370@chino.kir.corp.google.com>	<20150410100849.56b9d677@thinkpad> <20150410133859.fc79985a9514eb1e4d1dcde7@linux-foundation.org>
In-Reply-To: <20150410133859.fc79985a9514eb1e4d1dcde7@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 04/10/2015, 10:38 PM, Andrew Morton wrote:
> hm.  I think I'll make it
> 
> Fixes: 61f77eda "mm/hugetlb: reduce arch dependent code around follow_huge_*"

+1. This is the best tag to work with.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
