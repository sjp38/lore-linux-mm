Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26FAF6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:31:06 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so39603266pdn.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:31:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id aw6si5108786pbd.238.2015.03.25.13.31.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 13:31:05 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:31:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 401/458] fs/adfs/super.c:471 adfs_fill_super()
 error: potential null dereference 'asb->s_map'.  (adfs_read_map returns
 null)
Message-Id: <20150325133104.e073e529cc25dfd721860e69@linux-foundation.org>
In-Reply-To: <201503250918.zQGxJL4r%fengguang.wu@intel.com>
References: <201503250918.zQGxJL4r%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Sanidhya Kashyap <sanidhya.gatech@gmail.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 25 Mar 2015 09:40:22 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   e077e8e0158533bb824f3e2d9c0eaaaf4679b0ca
> commit: 4c21b0fd037c3174eeb5a9fbf620063c0192a369 [401/458] adfs: return correct return values
> 
> fs/adfs/super.c:471 adfs_fill_super() error: potential null dereference 'asb->s_map'.  (adfs_read_map returns null)
> 

The report seems bogus - adfs_read_map() cannot return NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
