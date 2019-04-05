Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61688C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 07:19:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14B1E217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 07:19:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14B1E217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89BE26B000C; Fri,  5 Apr 2019 03:19:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84BE56B000D; Fri,  5 Apr 2019 03:19:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 713886B000E; Fri,  5 Apr 2019 03:19:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23BAC6B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 03:19:08 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x1so3485667wrd.15
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 00:19:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=aGWVvxFIrM1sPJnTyuXAQenffgQ11LTCNbKxnnC6SQk=;
        b=Qa4GBuDzpsbYTodvnhHDkQU+XJ3ZAJWFFR+IZ1wwesZ7TU7Q+9z4eUSmzvMBzqEBSV
         fF0BeG4Id+Iylp/8BBgv5HL1xKejlT5t8j0S9d/kdfJK21tiXKOCc7TWmBrLbwv/qcSa
         7EiG4/2F08hNxdX/JItpblc651JGMRd79JODbu1wON5ULTYvjA38T+w+SDSaCP71FAjh
         LsDI/dJ+Iv4NptM6uWvUtxWRz1P1uSMI51NY2amblMdb3K2BDhYGuj211YQdqtco9hyK
         M0i4GtA/ie1iynsCgFp9ZDh83Mo/KzHr1ezRwNYGYNPUhuXzTMCwFWbKQli00gNHT71r
         ecnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU6Eb+S9fsD67DtUhgCWnlHsfSfcolc/n8WW2FiwNSN0WkW4f0H
	zXQfIhGRWvszu3E066nstpZ6sswKlW8TahxxohldjJUQM+fX1BEp6UrXDeHgBKfNfDlahz5Xfmc
	Vw2YNql3BwS6bb0rqeECwKRMVqS7Ej69mwM/X3i/TeeEnlDWDOsMPFjfNLSDqOGFHeQ==
X-Received: by 2002:a1c:6587:: with SMTP id z129mr6910333wmb.84.1554448747526;
        Fri, 05 Apr 2019 00:19:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz67BYXjtNQWQ2pjECl+fUbt5IsmmuVWehhKLP7PgbiYIloojr0amG4XhJDDrIhntxHSsZU
X-Received: by 2002:a1c:6587:: with SMTP id z129mr6910273wmb.84.1554448746355;
        Fri, 05 Apr 2019 00:19:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554448746; cv=none;
        d=google.com; s=arc-20160816;
        b=gTeWZpVddDThQWVp+Gz2/6t2z5X29lAaTrUM7IXrvVe47i34RlmAf5IBZkJ5AObNb1
         7NyGc9nV4czCpLjjcrWTzj9L+Uw1K0BxuPgdJ4cjVtKl4bBBdArTWMX6qGvhix8w6nV9
         FtUj5DE4iYSsso0KQHU9n7vy6FzwoYC2m7zYk5rRv6qj/WneEayV1qy//psYfiddinSF
         XccXNrOwVfSucbtW62GpkpDw+BIbnHa5h0nqxGZJM1Spf6e74CyoA926B3hcgchcOOlm
         9EZtcjRc363vLNh/YPFuH64oMlcJA2pe5yqWrtMrwcoNcL6cIP2sOSybU9gwyUit7Vz4
         pa9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=aGWVvxFIrM1sPJnTyuXAQenffgQ11LTCNbKxnnC6SQk=;
        b=Tt2v6Bj/tvs28qHw50TR0Q3lrEhBieWjqjjA68+2cC192GYWVEpueBF879J8SxLib7
         rZIhOZZSPAF6SH728Ontn/UdmDw+auqzLStp9OBNonyLR8tJs4rrqA+KlEvi9x0JGh/O
         YItS9DbA5zCBhe+CAw1GH6bqzclBcfRJyiYD+JhmmKM25w9TntxITkaBToPC6YLE/iSD
         +3szzWVXhzRbmVbTmWPTPhOYwR+kA9Ic0D7YGHQ1PptAHugrRKaVR268IJ934KEfptBN
         Kp7ShjsOBPP9b/OUgPD0N9rPqoC2cEwuNiFh/0v7tCAJRkkFex2z75EkZ4xhfgaJ5eKA
         g9qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v3si14073420wri.171.2019.04.05.00.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Apr 2019 00:19:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5492e2fc.dip0.t-ipconnect.de ([84.146.226.252] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hCJ6F-0002zo-Pl; Fri, 05 Apr 2019 09:17:20 +0200
Date: Fri, 5 Apr 2019 09:17:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Khalid Aziz <khalid.aziz@oracle.com>
cc: Andy Lutomirski <luto@kernel.org>, Juerg Haefliger <juergh@gmail.com>, 
    Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
    Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com, 
    Kees Cook <keescook@google.com>, 
    Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
    deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, 
    Tyler Hicks <tyhicks@canonical.com>, 
    "Woodhouse, David" <dwmw@amazon.co.uk>, 
    Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
    Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
    Joao Martins <joao.m.martins@oracle.com>, 
    Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, 
    John Haxby <john.haxby@oracle.com>, 
    "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
    Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, 
    Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
    Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>, 
    Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com, 
    anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
    Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org, 
    Ben Hutchings <ben@decadent.org.uk>, 
    Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
    Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org, 
    Daniel Vetter <daniel.vetter@ffwll.ch>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>, 
    Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>, 
    Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>, 
    Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>, 
    Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
    Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com, 
    Mark Rutland <mark.rutland@arm.com>, 
    Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, 
    Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, 
    Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de, 
    "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, 
    pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>, 
    richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>, 
    David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>, 
    "Serge E. Hallyn" <serge@hallyn.com>, Steve Capper <steve.capper@arm.com>, 
    thymovanbeers@gmail.com, Vlastimil Babka <vbabka@suse.cz>, 
    Will Deacon <will.deacon@arm.com>, Matthew Wilcox <willy@infradead.org>, 
    yang.shi@linux.alibaba.com, yaojun8558363@gmail.com, 
    Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com, 
    iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>, 
    linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
    "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
    LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
    LSM List <linux-security-module@vger.kernel.org>, 
    Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
In-Reply-To: <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
Message-ID: <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com> <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019, Khalid Aziz wrote:
> When xpfo unmaps a page from physmap only (after mapping the page in
> userspace in response to an allocation request from userspace) on one
> processor, there is a small window of opportunity for ret2dir attack on
> other cpus until the TLB entry in physmap for the unmapped pages on
> other cpus is cleared. Forcing that to happen synchronously is the
> expensive part. A multiple of these requests can come in over a very
> short time across multiple processors resulting in every cpu asking
> every other cpusto flush TLB just to close this small window of
> vulnerability in the kernel. If each request is processed synchronously,
> each CPU will do multiple TLB flushes in short order. If we could
> consolidate these TLB flush requests instead and do one TLB flush on
> each cpu at the time of context switch, we can reduce the performance
> impact significantly. This bears out in real life measuring the system
> time when doing a parallel kernel build on a large server. Without this,
> system time on 96-core server when doing "make -j60 all" went up 26x.
> After this optimization, impact went down to 1.44x.
> 
> The trade-off with this strategy is, the kernel on a cpu is vulnerable
> for a short time if the current running processor is the malicious

The "short" time to next context switch on the other CPUs is how short
exactly? Anything from 1us to seconds- think NOHZ FULL - and even w/o that
10ms on a HZ=100 kernel is plenty of time to launch an attack.

> process. Is that an acceptable trade-off?

You are not seriously asking whether creating a user controllable ret2dir
attack window is a acceptable trade-off? April 1st was a few days ago.

Thanks,

	tglx

