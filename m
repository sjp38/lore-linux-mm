Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FABB6B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 10:04:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n14-v6so1581745wmh.1
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 07:04:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8-v6sor7435019wro.7.2018.07.02.07.04.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 07:04:42 -0700 (PDT)
Date: Mon, 2 Jul 2018 16:04:40 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Message-ID: <20180702140440.GA10207@techadventures.net>
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702020417.21281-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

On Sun, Jul 01, 2018 at 10:04:17PM -0400, Pavel Tatashin wrote:
> Change sprase_init() to only find the pnum ranges that belong to a specific
> node and call sprase_init_nid() for that range from sparse_init().
> 
> Delete all the code that became obsolete with this change.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
 
This looks like an improvement to me.
It also makes the code much easier to follow and to understand.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
