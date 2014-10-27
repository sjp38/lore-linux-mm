Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A0436900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:15:45 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so4680209pad.25
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:15:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a12si11578993pdm.124.2014.10.27.16.15.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 16:15:44 -0700 (PDT)
Date: Mon, 27 Oct 2014 16:15:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
Message-Id: <20141027161544.8955c1df4c01c48e22283692@linux-foundation.org>
In-Reply-To: <xa1tk33p2zvq.fsf@mina86.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
	<1413986796-19732-1-git-send-email-pintu.k@samsung.com>
	<1413986796-19732-2-git-send-email-pintu.k@samsung.com>
	<xa1tk33p2zvq.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Pintu Kumar <pintu.k@samsung.com>, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

On Fri, 24 Oct 2014 18:31:21 +0200 Michal Nazarewicz <mina86@mina86.com> wrote:

> On Wed, Oct 22 2014, Pintu Kumar <pintu.k@samsung.com> wrote:
> > This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
> > Currently, in a CMA enabled system, if somebody wants to know the
> > total CMA size declared, there is no way to tell, other than the dmesg
> > or /var/log/messages logs.
> > With this patch we are showing the CMA info as part of meminfo, so that
> > it can be determined at any point of time.
> > This will be populated only when CMA is enabled.
> >
> > Below is the sample output from a ARM based device with RAM:512MB and CMA:16MB.
> >
> > MemTotal:         471172 kB
> > MemFree:          111712 kB
> > MemAvailable:     271172 kB
> > .
> > .
> > .
> > CmaTotal:          16384 kB
> > CmaFree:            6144 kB
> >
> > This patch also fix below checkpatch errors that were found during these changes.
> 
> As already mentioned, this should be in separate patch.

Yes, in theory.  But a couple of little whitespace fixes aren't really
worth a resend.  As long as they don't make the patch harder to read
and to backport I usually just let them through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
