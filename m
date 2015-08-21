Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE3F9003C7
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:53:24 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so7823538wic.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:53:23 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id sc17si13198987wjb.23.2015.08.20.23.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 23:53:23 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so7868227wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:53:22 -0700 (PDT)
Date: Fri, 21 Aug 2015 08:53:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150821065321.GD23723@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 20-08-15 23:34:51, Naoya Horiguchi wrote:
[...]
> > Reading a single file is, of course, easier but is it really worth the
> > additional code? I haven't really looked at the patch so I might be
> > missing something but what would be an advantage over reading
> > /proc/<pid>/smaps and extracting the information from there?
> 
> My first idea was just "users should feel it useful", but permission as David
> commented sounds a good technical reason to me.

9 files changed, 112 insertions(+), 1 deletion(-)

is quite a lot especially when it touches hot paths like fork so it
better should have a good usecase. I have already asked in the other
email but is actually anybody requesting this? Nice to have is not
a good justification IMO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
