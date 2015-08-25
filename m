Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6376B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 19:23:37 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so65830338pac.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:23:37 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id v2si35412211pdl.59.2015.08.25.16.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 16:23:36 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so5522738pac.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:23:36 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:23:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <20150824085127.GB17078@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20150820110004.GB4632@dhcp22.suse.cz> <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz> <20150821163033.GA4600@Sligo.logfs.org> <20150824085127.GB17078@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, 24 Aug 2015, Michal Hocko wrote:

> The current implementation makes me worry. Is the per hstate break down
> really needed? The implementation would be much more easier without it.
> 

Yes, it's needed.  It provides a complete picture of what statically 
reserved hugepages are in use and we're not going to change the 
implementation when it is needed to differentiate between variable hugetlb 
page sizes that risk breaking existing userspace parsers.

> If you have 99% of hugetlb pages then your load is rather specific and I
> would argue that /proc/<pid>/smaps (after patch 1) is a much better way to
> get what you want.
> 

Some distributions change the permissions of smaps, as already stated, for 
pretty clear security reasons since it can be used to defeat existing 
protection.  There's no reason why hugetlb page usage should not be 
exported in the same manner and location as memory usage.

Sheesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
