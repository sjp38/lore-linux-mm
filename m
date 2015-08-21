Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 476536B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:32:37 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so7537815wid.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:32:36 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id bg1si2536460wib.99.2015.08.20.23.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 23:32:35 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so10867712wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:32:35 -0700 (PDT)
Date: Fri, 21 Aug 2015 08:32:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150821063233.GB23723@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508201249010.27169@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508201249010.27169@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 20-08-15 12:49:59, David Rientjes wrote:
> On Thu, 20 Aug 2015, Michal Hocko wrote:
> 
> > On Thu 20-08-15 08:26:27, Naoya Horiguchi wrote:
> > > Currently there's no easy way to get per-process usage of hugetlb pages,
> > 
> > Is this really the case after your previous patch? You have both 
> > HugetlbPages and KernelPageSize which should be sufficient no?
> > 
> > Reading a single file is, of course, easier but is it really worth the
> > additional code? I haven't really looked at the patch so I might be
> > missing something but what would be an advantage over reading
> > /proc/<pid>/smaps and extracting the information from there?
> > 
> 
> /proc/pid/smaps requires root, /proc/pid/status doesn't.

Both mmotm and linus tree have
        REG("smaps",      S_IRUGO, proc_pid_smaps_operations),

and opening the file requires PTRACE_MODE_READ. So I do not see any
requirement for root here. Or did you mean that you need root to examine
all processes? That would be true but I am wondering why would be a regular
user interested in this break out numbers. Hugetlb management sounds
pretty much like an administrative or very specialized thing.

>From my understanding of the discussion there is no usecase to have this
information world readable. Is this correct?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
