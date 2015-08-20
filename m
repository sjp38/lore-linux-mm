Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 53CAA6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 15:50:03 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so17618456pdb.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:50:03 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id c2si8972025pdb.224.2015.08.20.12.50.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 12:50:02 -0700 (PDT)
Received: by pawq9 with SMTP id q9so34866988paw.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:50:01 -0700 (PDT)
Date: Thu, 20 Aug 2015 12:49:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <20150820110004.GB4632@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508201249010.27169@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20150820110004.GB4632@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 20 Aug 2015, Michal Hocko wrote:

> On Thu 20-08-15 08:26:27, Naoya Horiguchi wrote:
> > Currently there's no easy way to get per-process usage of hugetlb pages,
> 
> Is this really the case after your previous patch? You have both 
> HugetlbPages and KernelPageSize which should be sufficient no?
> 
> Reading a single file is, of course, easier but is it really worth the
> additional code? I haven't really looked at the patch so I might be
> missing something but what would be an advantage over reading
> /proc/<pid>/smaps and extracting the information from there?
> 

/proc/pid/smaps requires root, /proc/pid/status doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
