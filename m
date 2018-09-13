Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF8E8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 18:41:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so3490178pff.12
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 15:41:31 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id w126-v6si5402918pfb.232.2018.09.13.15.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 15:41:30 -0700 (PDT)
Date: Thu, 13 Sep 2018 16:41:27 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v3 3/3] docs: core-api: add memory allocation guide
Message-ID: <20180913164127.4e44045f@lwn.net>
In-Reply-To: <20180912103305.GC6719@rapoport-lnx>
References: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1534517236-16762-4-git-send-email-rppt@linux.vnet.ibm.com>
	<20180911115555.5fce5631@lwn.net>
	<20180912103305.GC6719@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 12 Sep 2018 13:33:06 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> How about:
> 
>     ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
>     will be directly accessible by the kernel and implies that the
>     data is movable.
> 
>     ``GFP_HIGHUSER`` means that the allocated memory is not movable,
>     but it is not required to be directly accessible by the kernel. An
>     example may be a hardware allocation that maps data directly into
>     userspace but has no addressing limitations.
> 
>     ``GFP_USER`` means that the allocated memory is not movable and it
>     must be directly accessible by the kernel

Sounds good to me.

Thanks,

jon
