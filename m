Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CC41E6B0032
	for <linux-mm@kvack.org>; Thu, 14 May 2015 16:24:15 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so100283599pab.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 13:24:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v9si4661121pdm.107.2015.05.14.13.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 13:24:14 -0700 (PDT)
Date: Thu, 14 May 2015 13:24:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/11] mm: debug: formatting memory management structs
Message-Id: <20150514132413.2a56b25489e0c644e68229bb@linux-foundation.org>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Thu, 14 May 2015 13:10:03 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> This patch series adds knowledge about various memory management structures
> to the standard print functions.
> 
> In essence, it allows us to easily print those structures:
> 
> 	printk("%pZp %pZm %pZv", page, mm, vma);
> 
> This allows us to customize output when hitting bugs even further, thus
> we introduce VM_BUG() which allows printing anything when hitting a bug
> rather than just a single piece of information.
> 
> This also means we can get rid of VM_BUG_ON_* since they're now nothing
> more than a format string.

A good set of example output would help people understand this proposal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
