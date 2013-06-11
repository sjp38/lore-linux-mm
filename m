Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D45236B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 18:20:12 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so3028695pdi.27
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 15:20:12 -0700 (PDT)
Date: Tue, 11 Jun 2013 15:20:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
In-Reply-To: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
Message-ID: <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue, 11 Jun 2013, Alex Thorlton wrote:

> This patch adds the ability to control THPs on a per cpuset basis.  Please see
> the additions to Documentation/cgroups/cpusets.txt for more information.
> 

What's missing from both this changelog and the documentation you point to 
is why this change is needed.

I can understand how you would want a subset of processes to not use thp 
when it is enabled.  This is typically where MADV_NOHUGEPAGE is used with 
some type of malloc hook.

I don't think we need to do this on a cpuset level, so unfortunately I 
think this needs to be reworked.  Would it make sense to add a per-process 
tunable to always get MADV_NOHUGEPAGE behavior for all of its sbrk() and 
mmap() calls?  Perhaps, but then you would need to justify why it can't be 
done with a malloc hook in userspace.

This seems to just be working around a userspace issue or for a matter of 
convenience, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
