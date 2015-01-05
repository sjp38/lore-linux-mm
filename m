Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDA16B0088
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 18:17:16 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id z107so4895244qgd.4
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 15:17:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z3si28378283qaq.112.2015.01.05.15.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 15:17:15 -0800 (PST)
Date: Mon, 5 Jan 2015 18:08:30 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2] fs: proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
Message-ID: <20150105230829.GA28105@t510.redhat.com>
References: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
 <20150105133500.e0ce4b090e6b378c3edc9c56@linux-foundation.org>
 <20150105225504.GC1795@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150105225504.GC1795@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

On Mon, Jan 05, 2015 at 05:55:04PM -0500, Rafael Aquini wrote:
> > > +	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
> > 
> > This changes the format of the numa_maps file and can potentially break
> > existing parsers.  Please discuss.
> > 
> > I'd complain about the patch's failure to update the documentation,
> > except numa_maps appears to be undocumented.  Sigh.  What the heck is "N0"?
> >
> That's a nice opportunity to attempt to sharp my doc writing skills.
> Sorry for the total failure to identify it earlier.
> I just took it as a TODO note to send a patch to document this interface soon.
>

Or perhaps that's a sign we should move the numa node locality
information to /proc/$pid/smaps and start printing a deprecation warning
for /proc/$pid/numa_maps users preparing them for a future removal?

 
> Happy new year.
> -- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
