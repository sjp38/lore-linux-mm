Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46F626B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 20:13:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u144so2967604pgb.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 17:13:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l1sor11045371qtf.139.2017.10.03.17.13.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 17:13:39 -0700 (PDT)
Date: Tue, 3 Oct 2017 20:13:37 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
In-Reply-To: <20171003234801.GA1571@Big-Sky.local>
Message-ID: <nycvar.YSQ.7.76.1710032011070.5407@knanqh.ubzr>
References: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr> <20171003210540.GM3301751@devbig577.frc2.facebook.com> <nycvar.YSQ.7.76.1710031731130.5407@knanqh.ubzr> <20171003223642.GN3301751@devbig577.frc2.facebook.com>
 <20171003234801.GA1571@Big-Sky.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 3 Oct 2017, Dennis Zhou wrote:

> Hi Tejun,
> 
> On Tue, Oct 03, 2017 at 03:36:42PM -0700, Tejun Heo wrote:
> > > Subject: [PATCH] percpu: don't forget to free the temporary struct pcpu_alloc_info
> > 
> > So, IIRC, the error path is either boot fail or some serious bug in
> > arch code.  It really doesn't matter whether we free a page or not.
> >
> 
> In setup_per_cpu_area, a call to either pcpu_embed_first_chunk,
> pcpu_page_first_chunk, or pcpu_setup_first_chunk is made. The first two
> eventually call pcpu_setup_first_chunk with a pairing call to
> pcpu_free_alloc_info right after. This occurs in all implementations. It
> happens we don't have a pairing call to pcpu_free_alloc_info in the UP
> setup_per_cpu_area.

That was my conclusion too (albeit not stated as clearly) and what my 
second patch fixed.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
