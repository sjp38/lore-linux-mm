Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9873C6B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 22:18:47 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so15018423pac.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 19:18:47 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id a10si8601120pas.176.2015.08.05.19.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 19:18:46 -0700 (PDT)
Received: by pdco4 with SMTP id o4so25849350pdc.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 19:18:46 -0700 (PDT)
Date: Wed, 5 Aug 2015 19:18:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] smaps: fill missing fields for vma(VM_HUGETLB)
In-Reply-To: <20150804182158.GH14335@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1508051917430.4843@chino.kir.corp.google.com>
References: <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com> <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com> <20150728222654.GA28456@Sligo.logfs.org> <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org> <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com> <55B95FDB.1000801@oracle.com> <20150804025530.GA13210@hori1.linux.bs1.fc.nec.co.jp> <20150804051339.GA24931@hori1.linux.bs1.fc.nec.co.jp>
 <20150804182158.GH14335@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1446445883-1438827525=:4843"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1446445883-1438827525=:4843
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 4 Aug 2015, Jorn Engel wrote:

> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Subject: [PATCH] smaps: fill missing fields for vma(VM_HUGETLB)
> > 
> > Currently smaps reports many zero fields for vma(VM_HUGETLB), which is
> > inconvenient when we want to know per-task or per-vma base hugetlb usage.
> > This patch enables these fields by introducing smaps_hugetlb_range().
> > 
> > before patch:
> > 
> >   Size:              20480 kB
> >   Rss:                   0 kB
> >   Pss:                   0 kB
> >   Shared_Clean:          0 kB
> >   Shared_Dirty:          0 kB
> >   Private_Clean:         0 kB
> >   Private_Dirty:         0 kB
> >   Referenced:            0 kB
> >   Anonymous:             0 kB
> >   AnonHugePages:         0 kB
> >   Swap:                  0 kB
> >   KernelPageSize:     2048 kB
> >   MMUPageSize:        2048 kB
> >   Locked:                0 kB
> >   VmFlags: rd wr mr mw me de ht
> > 
> > after patch:
> > 
> >   Size:              20480 kB
> >   Rss:               18432 kB
> >   Pss:               18432 kB
> >   Shared_Clean:          0 kB
> >   Shared_Dirty:          0 kB
> >   Private_Clean:         0 kB
> >   Private_Dirty:     18432 kB
> >   Referenced:        18432 kB
> >   Anonymous:         18432 kB
> >   AnonHugePages:         0 kB
> >   Swap:                  0 kB
> >   KernelPageSize:     2048 kB
> >   MMUPageSize:        2048 kB
> >   Locked:                0 kB
> >   VmFlags: rd wr mr mw me de ht
> 
> Nice!
> 

Hmm, wouldn't this be confusing since VmRSS in /proc/pid/status doesn't 
match the rss shown in smaps, since hugetlb mappings aren't accounted in 
get_mm_rss()?

Not sure this is a good idea, I think consistency amongst rss values would 
be more important.
--397176738-1446445883-1438827525=:4843--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
