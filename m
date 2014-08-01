Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 483B06B003C
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 17:32:39 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rd18so6747292iec.0
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 14:32:39 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id db15si37147igc.19.2014.08.01.14.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 14:32:38 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id tr6so6454295ieb.7
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 14:32:38 -0700 (PDT)
Date: Fri, 1 Aug 2014 14:32:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/2] faultaround updates
In-Reply-To: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.02.1408011432100.11532@chino.kir.corp.google.com>
References: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Fri, 1 Aug 2014, Kirill A. Shutemov wrote:

> One fix and one tweak for faultaround code.
> 
> As alternative, we could just drop debugfs interface and make
> fault_around_bytes constant.
> 

If we can remove the debugfs interface, then it seems better than 
continuing to support it.  Any objections to removing it?

> Kirill A. Shutemov (2):
>   mm: close race between do_fault_around() and fault_around_bytes_set()
>   mm: mark fault_around_bytes __read_mostly
> 
>  mm/memory.c | 24 +++++++++---------------
>  1 file changed, 9 insertions(+), 15 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
