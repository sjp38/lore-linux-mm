Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9916B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 22:14:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so789640pab.21
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 19:14:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fn9si2941582pab.203.2013.12.13.19.13.57
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 19:13:59 -0800 (PST)
Date: Fri, 13 Dec 2013 19:13:56 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC][PATCH 6/7] mm: slub: remove 'struct page' alignment
 restrictions
Message-ID: <20131214031356.GS22695@tassilo.jf.intel.com>
References: <20131213235903.8236C539@viggo.jf.intel.com>
 <20131213235911.79AA177D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213235911.79AA177D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

> helps performance, presumably because of that 14% fewer
> cacheline effect.  A 30GB dd to a ramfs file:
> 
> 	dd if=/dev/zero of=bigfile bs=$((1<<30)) count=30
> 
> is sped up by about 4.4% in my testing.

Impressive result!

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
