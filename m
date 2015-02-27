Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 642806B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:14:47 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so21361126obb.3
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:14:47 -0800 (PST)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id h2si1221930obe.68.2015.02.27.14.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:14:46 -0800 (PST)
Date: Fri, 27 Feb 2015 15:14:44 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] doc: add information about max_ptes_none
Message-ID: <20150227151444.05ce1b31@lwn.net>
In-Reply-To: <1424986476-6438-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1424986476-6438-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, mgorman@suse.de, hughd@google.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave@stgolabs.net, aulmcquad@gmail.com, sasha.levin@oracle.com, xemul@parallels.com, linux-kernel@vger.kernel.org

On Thu, 26 Feb 2015 23:34:36 +0200
Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:

> max_ptes_none specifies how many extra small pages (that are
> not already mapped) can be allocated when collapsing a group
> of small pages into one large page.
> 
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
> 
> A higher value leads to use additional memory for programs.
> A lower value leads to gain less thp performance. Value of
> max_ptes_none can waste cpu time very little, you can
> ignore it.

Applied to the docs tree, thanks.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
