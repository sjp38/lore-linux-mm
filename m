Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9E16B027D
	for <linux-mm@kvack.org>; Tue,  8 May 2018 08:53:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a125so23709469qkd.4
        for <linux-mm@kvack.org>; Tue, 08 May 2018 05:53:23 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id e39-v6si991163qtb.302.2018.05.08.05.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 05:53:22 -0700 (PDT)
Date: Tue, 8 May 2018 07:53:21 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node
 information
In-Reply-To: <a61bc7b6-ed98-045d-95c0-b6c91fc8d1da@oracle.com>
Message-ID: <alpine.DEB.2.21.1805080747480.1849@nuc-kabylake>
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com> <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake> <c80ee329-084b-367f-1937-3175c178e978@oracle.com> <alpine.DEB.2.21.1805040955550.10847@nuc-kabylake> <98e34010-d55a-5f2d-7d98-cba424de2e74@oracle.com>
 <alpine.DEB.2.21.1805070945200.21162@nuc-kabylake> <a61bc7b6-ed98-045d-95c0-b6c91fc8d1da@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com

On Mon, 7 May 2018, prakash.sangappa wrote:

> > each address for each page? Length of the VMA segment?
> > Physical address?
>
> Need numa node information for each virtual address with pages mapped.
> No need of physical address.

You need per page information? Note that there can only be one page
per virtual address. Or are we talking about address ranges?

https://www.kernel.org/doc/Documentation/vm/pagemap.txt ?

Also the move_pages syscall has the ability to determine the location of
individual pages.
