Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 729A06B0038
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 02:34:12 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o20so12935298lfg.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 23:34:12 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id u63si5804923lja.19.2016.12.16.23.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 23:34:10 -0800 (PST)
Date: Sat, 17 Dec 2016 08:34:06 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 02/14] sparc64: add new fields to mmu context for
 shared context support
Message-ID: <20161217073406.GA23567@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike.

On Fri, Dec 16, 2016 at 10:35:25AM -0800, Mike Kravetz wrote:
> Add new fields to the mm_context structure to support shared context.
> Instead of a simple context ID, add a pointer to a structure with a
> reference count.  This is needed as multiple tasks will share the
> context ID.

What are the benefits with the shared_mmu_ctx struct?
It does not save any space in mm_context_t, and the CPU only
supports one extra context.
So it looks like over-engineering with all the extra administration
required to handle it with refcount, poitners etc.

what do I miss?

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
