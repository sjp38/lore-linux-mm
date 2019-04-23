Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A1BAC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD69D20811
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:39:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kWZNVI2H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD69D20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70B776B0007; Tue, 23 Apr 2019 05:39:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 692616B000A; Tue, 23 Apr 2019 05:39:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5337B6B000C; Tue, 23 Apr 2019 05:39:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 185B86B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:39:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so9721135pge.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:39:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KZ1+LpzJjt1lQaO/zhhBXmd8ItG9I8H/NFkBPqdSKp4=;
        b=YImJh/DaiaGQvXk7pdGNVIgE6usxmcqoZAMrMYW9n104wH6r9NiKJoyDGhZWgEy2sI
         ND3IuAwAn1mw3NdB3wocdiLK8BmWKDHjTeVtjRxAdJHYr2uydwu3/W01z+orYQnwakST
         Jv+/wfAnIkf31ZKOKBremRRlJMHqQ8Zguxs+iAUcwEliVqFjvX2osCEdX5AwJJRjRye5
         K5xrJiSKN6losrWxNk/K5aQR574hsBYDF78BDjS9rbQ3CfRv11HWbCmrgfyFeqCeZH1u
         KXyzaZhV5O/2bB9MhE6zNC/vWzcPI8czSRU3TRVpbc8YBaL5Q1VSQ1iB/2dIu3TdwOTh
         GIXA==
X-Gm-Message-State: APjAAAW2PRlHD7+N0+b+rRYjNO7jNuESMtUPMxXOPDOoMTEuTR9j50Pa
	o2sAs6AyhjLiRD6MjdoPN/7DGW/jurNK2aSVfuHy0rOrjI+5e17K4mDxnayyxYj3hrFMI4U7UyE
	nkxl2EX7X46j086LR5wESKTOZk/0bAo9IXWTZvcfQxIDKvxyFhNZHP7b05wUYhxlY2A==
X-Received: by 2002:aa7:8282:: with SMTP id s2mr25553963pfm.7.1556012349706;
        Tue, 23 Apr 2019 02:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4IcasFcYjdzXv5liLZUZQyBW/EnZ9E/T7gh2hf3A/Vr/Hx6P1ihT+Pyylhy7qrIVVcX6Y
X-Received: by 2002:aa7:8282:: with SMTP id s2mr25553911pfm.7.1556012348991;
        Tue, 23 Apr 2019 02:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012348; cv=none;
        d=google.com; s=arc-20160816;
        b=WP1kVuyrkneJv8Dl4MRK+1PDikr18n+0es5aPTSgPkLF+V5kCOtWyWvXUCVjESQRvA
         YH/ZuE8jz8ofc2LiCbkpIMNWJGpMAakeAMY+1KXfVNdOiEhQt8jitxiO5IB1aRGpXj6O
         yp44YEv5bIURHQcTHR/zXQlLNI1JOBxb9DghY0DZ3WwKPphBhskFt1jY70uuOmOuf6Qj
         HbN+Pm5y8sOdijV869NtheWc/XXYenELiFken9j6L7Bl+I8xi9zNRnpp6tOOm0KoGrl3
         bQz6hbhC1w0mGaTrlMmhjydssGJwFjvd/MipwqoGWbCKu+YI2Ve8MSs1X42CNgxmbRgB
         PYAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KZ1+LpzJjt1lQaO/zhhBXmd8ItG9I8H/NFkBPqdSKp4=;
        b=zzj0W7XKopJCek7BOBW8C4OcAWXH+eDjwvZxki0tmLFgMWAww2XZvsATSAOnQtwV3s
         2fv0K20rUN8gVNZbyDlHefo5yrmWL5+4EcBgejSDsqUwmGVKX/vmGUUaSf7K32RWTQ6u
         XRHldpo1krHGwaNLcr+uIbwCCH12VF7zdFZmUfrGZ5TOpIwxBHJhDpA0hgwzup0KWXfn
         jRhZ4lss3JxTJxVwCTzlKlh8GRTwwRkB6Uu1nRtFR86NZEi5uoNcNloku7mLQoZEyykK
         +IFd6v3lD8ERf3wyUgG4JQ2VOLmQcDQ9SWLSdiVT1yGCaURTuSieIciZ2sy8Q60IRXGq
         TZtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kWZNVI2H;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y5si7264870pgh.553.2019.04.23.02.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 02:39:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kWZNVI2H;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KZ1+LpzJjt1lQaO/zhhBXmd8ItG9I8H/NFkBPqdSKp4=; b=kWZNVI2H88CgPB45rHhvEagQy
	YUXAwoj4UqliNhOdCXov/GLt6lWALi4JYUG0WNlU4GGG3JAvPyBRkffyWJOG+EG0Ur9Kx1yB1ZEA+
	crqGIkZ0RR5dJvoHX2bSDFkFQfGDGgb5JKkpIhgWbRSNdH1EQU51xgOLzcuH2d142hpvgjzx2md9s
	rcVXo+iDvqNoRr/AvulifTy23sAkOmmfbsKuOe7LAQCmEVmiq9pYQuCW4a42z6Hp8dQhMHJiCING8
	JI1Nlc06RH+pKcvLROVBIO1pkNJZOFlAGmkC/NPAI0mOHNypwGzvg0dMbMU4fZTqeqtbbpL0yyKJd
	YyIrsQdsw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIrt8-0003WC-3I; Tue, 23 Apr 2019 09:38:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6922229B47DCF; Tue, 23 Apr 2019 11:38:51 +0200 (CEST)
Date: Tue, 23 Apr 2019 11:38:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Michel Lespinasse <walken@google.com>
Cc: Laurent Dufour <ldufour@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	mpe@ellerman.id.au, Paul Mackerras <paulus@samba.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190423093851.GJ11158@hirez.programming.kicks-ass.net>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 02:29:16PM -0700, Michel Lespinasse wrote:
> The proposed spf mechanism only handles anon vmas. Is there a
> fundamental reason why it couldn't handle mapped files too ?
> My understanding is that the mechanism of verifying the vma after
> taking back the ptl at the end of the fault would work there too ?
> The file has to stay referenced during the fault, but holding the vma's
> refcount could be made to cover that ? the vm_file refcount would have
> to be released in __free_vma() instead of remove_vma; I'm not quite sure
> if that has more implications than I realize ?

IIRC (and I really don't remember all that much) the trickiest bit was
vs unmount. Since files can stay open past the 'expected' duration,
umount could be delayed.

But yes, I think I had a version that did all that just 'fine'. Like
mentioned, I didn't keep the refcount because it sucked just as hard as
the mmap_sem contention, but the SRCU callback did the fput() just fine
(esp. now that we have delayed_fput).

