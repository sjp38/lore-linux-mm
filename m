Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4106B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:41:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e5so123172692pgk.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:41:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x4si5161001pfi.31.2017.03.16.20.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 20:41:36 -0700 (PDT)
Date: Thu, 16 Mar 2017 20:41:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 119/211] mm/migrate.c:2184:5: note: in expansion
 of macro 'MIGRATE_PFN_DEVICE'
Message-Id: <20170316204135.da11fb9a50d22c264404a30e@linux-foundation.org>
In-Reply-To: <201703170923.JOG5lvVO%fengguang.wu@intel.com>
References: <201703170923.JOG5lvVO%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 17 Mar 2017 09:46:30 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8276ddb3c638602509386f1a05f75326dbf5ce09
> commit: a6d9a210db7db40e98f7502608c6f1413c44b9b9 [119/211] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration

heh, I think the HMM patchset just scored the world record number of
build errors.  Thanks for doing this.

But why didn't we find out earlier than v18?  Don't you scoop patchsets
off the mailing list *before* someone merges them into an upstream
tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
