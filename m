Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 818866B0008
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 09:23:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c22so18030488pfj.2
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 06:23:37 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 63-v6si1442965plf.645.2018.02.01.06.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 06:23:36 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/sparse.c: Add nr_present_sections to change the
 mem_map allocation
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-3-bhe@redhat.com>
 <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
 <6def8374-2de2-a30c-69ff-2a49fb57dc9a@linux.intel.com>
 <20180201141934.GC1770@localhost.localdomain>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7494fba4-a769-67d4-4121-508bd26da4ba@linux.intel.com>
Date: Thu, 1 Feb 2018 06:23:34 -0800
MIME-Version: 1.0
In-Reply-To: <20180201141934.GC1770@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 02/01/2018 06:19 AM, Baoquan He wrote:
> 
> I suppose these functions changed here are only called during system
> bootup, namely in paging_init(). Hot-add memory goes in a different
> path, __add_section() -> sparse_add_one_section(), different called
> functions.

But does this keep those sections that were not present on boot from
being added later?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
