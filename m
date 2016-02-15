Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 729A26B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 01:09:47 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ho8so81255678pac.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 22:09:47 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id p84si41152963pfi.134.2016.02.14.22.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 22:09:46 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id e127so7080890pfe.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 22:09:46 -0800 (PST)
Message-ID: <1455516578.16012.27.camel@gmail.com>
Subject: Re: [PATCH 01/33] mm: introduce get_user_pages_remote()
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 15 Feb 2016 17:09:38 +1100
In-Reply-To: <20160212210154.3F0E51EA@viggo.jf.intel.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
	 <20160212210154.3F0E51EA@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On Fri, 2016-02-12 at 13:01 -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> For protection keys, we need to understand whether protections
> should be enforced in software or not.A A In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "remote" operations.
> 
> This patch introduces a new get_user_pages() variant:
> 
> A A A A A A A A get_user_pages_remote()
> 
> Which is a replacement for when get_user_pages() is called on
> non-current tsk/mm.
> 

In summary then get_user_pages_remote() do not enforce protections?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
