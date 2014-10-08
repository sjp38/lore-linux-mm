Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id D94F16B006E
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 03:10:16 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id hn18so7366874igb.3
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 00:10:16 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id hs7si1573320igb.22.2014.10.08.00.10.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 00:10:15 -0700 (PDT)
Date: Wed, 8 Oct 2014 02:10:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/5] mm: poison page struct
In-Reply-To: <5434630C.3070006@intel.com>
Message-ID: <alpine.DEB.2.11.1410080208410.9795@gentwo.org>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <1412041639-23617-6-git-send-email-sasha.levin@oracle.com> <5434630C.3070006@intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de

On Tue, 7 Oct 2014, Dave Hansen wrote:

> Does this break slub's __cmpxchg_double_slab trick?  I thought it
> required page->freelist and page->counters to be doubleword-aligned.

Sure that would be required for it to work.

> It's not like we really require this optimization when we're debugging,
> but trying to use it will unnecessarily slow things down.

Debugging by inserting more data into the page struct will already cause a
significant slow down because the cache footprint of key functions will
increase significantly. I would think that using the fallback functions
is reasonable in this scenario,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
