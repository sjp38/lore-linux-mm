Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB8D6B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 01:49:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k15so25478832wmh.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 22:49:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c40si35835717edb.70.2017.06.05.22.49.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 22:49:21 -0700 (PDT)
Date: Tue, 6 Jun 2017 07:49:18 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170606054917.GA1189@dhcp22.suse.cz>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605151541.avidrotxpoiekoy5@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Mon 05-06-17 11:15:41, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@suse.com> [170605 00:57]:
> > On Fri 02-06-17 20:54:13, Liam R. Howlett wrote:
> > > When the user specifies too many hugepages or an invalid
> > > default_hugepagesz the communication to the user is implicit in the
> > > allocation message.  This patch adds a warning when the desired page
> > > count is not allocated and prints an error when the default_hugepagesz
> > > is invalid on boot.
> > 
> > We do not warn when doing echo $NUM > nr_hugepages, so why should we
> > behave any different during the boot?
> 
> During boot hugepages will allocate until there is a fraction of the
> hugepage size left.  That is, we allocate until either the request is
> satisfied or memory for the pages is exhausted.  When memory for the
> pages is exhausted, it will most likely lead to the system failing with
> the OOM manager not finding enough (or anything) to kill (unless you're
> using really big hugepages in the order of 100s of MB or in the GBs).
> The user will most likely see the OOM messages much later in the boot
> sequence than the implicitly stated message.  Worse yet, you may even
> get an OOM for each processor which causes many pages of OOMs on modern
> systems.  Although these messages will be printed earlier than the OOM
> messages, at least giving the user errors and warnings will highlight
> the configuration as an issue.  I'm trying to point the user in the
> right direction by providing a more robust statement of what is failing.

Well, an oom report will tell us how much memory is eaten by hugetlb so
you would get a clue that something is misconfigured.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
