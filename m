Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D3C1F6B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 16:00:49 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so4112917pdi.24
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:00:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bz6si3621188pad.70.2014.10.22.13.00.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 13:00:48 -0700 (PDT)
Date: Wed, 22 Oct 2014 13:00:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
Message-Id: <20141022130046.f4c7bb9cfc5805d2bef188a4@linux-foundation.org>
In-Reply-To: <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
	<1413986796-19732-1-git-send-email-pintu.k@samsung.com>
	<1413986796-19732-2-git-send-email-pintu.k@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

On Wed, 22 Oct 2014 19:36:35 +0530 Pintu Kumar <pintu.k@samsung.com> wrote:

> This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
> Currently, in a CMA enabled system, if somebody wants to know the
> total CMA size declared, there is no way to tell, other than the dmesg
> or /var/log/messages logs.
> With this patch we are showing the CMA info as part of meminfo, so that
> it can be determined at any point of time.
> This will be populated only when CMA is enabled.

Fair enough.

We should be pretty careful about what we put in meminfo - it's the
top-level, most-important procfs file and I expect that quite a lot of
userspace reads it with some frequency.  We don't want to clutter it
up.  /proc/vmstat is a suitable place for the less important info which
is more kernel developer oriented.

But CMATotal and CMAFree do pass the "should be in meminfo" test, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
