Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 59E7F6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 11:53:19 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so11220290pdj.37
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 08:53:19 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id cl3si29573273pad.214.2014.12.01.08.53.17
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 08:53:18 -0800 (PST)
Date: Mon, 1 Dec 2014 08:53:05 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/5] Refactor do_wp_page, no functional change
Message-ID: <20141201165305.GP10824@tassilo.jf.intel.com>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com


Looks good to me from a quick read.

Normally we try to keep the unlock in the same function, even
if it needs goto, but I guess it's ok to move it out in this
case.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
