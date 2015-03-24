Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 21C6E6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:10:37 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so6836567pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:10:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f6si682524pdn.231.2015.03.24.15.10.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:10:36 -0700 (PDT)
Date: Tue, 24 Mar 2015 15:10:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v7 2/2] mm: swapoff prototype: frontswap handling added
Message-Id: <20150324151034.ade239edc6386c206a311d82@linux-foundation.org>
In-Reply-To: <20150319105545.GA8156@kelleynnn-virtual-machine>
References: <20150319105545.GA8156@kelleynnn-virtual-machine>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On Thu, 19 Mar 2015 03:55:45 -0700 Kelley Nielsen <kelleynnn@gmail.com> wrote:

> The prototype of the new swapoff (without the quadratic complexity)
> presently ignores the frontswap case. Pass the count of
> pages_to_unuse down the page table walks in try_to_unuse(),
> and return from the walk when the desired number of pages
> has been swapped back in.

Does this fix the "TODO" in [1/2]?

Do you think this patchset is ready for testing (while Hugh reviews it
:)), or is there some deeper reason behind the "RFC"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
