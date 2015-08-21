Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5894E6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:30:37 -0400 (EDT)
Received: by pacgz8 with SMTP id gz8so97115pac.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:30:37 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id sl6si13590855pac.192.2015.08.21.09.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 09:30:36 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so47574834pac.2
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:30:36 -0700 (PDT)
Date: Fri, 21 Aug 2015 09:30:33 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150821163033.GA4600@Sligo.logfs.org>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150821065321.GD23723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 21, 2015 at 08:53:21AM +0200, Michal Hocko wrote:
> On Thu 20-08-15 23:34:51, Naoya Horiguchi wrote:
> [...]
> > > Reading a single file is, of course, easier but is it really worth the
> > > additional code? I haven't really looked at the patch so I might be
> > > missing something but what would be an advantage over reading
> > > /proc/<pid>/smaps and extracting the information from there?
> > 
> > My first idea was just "users should feel it useful", but permission as David
> > commented sounds a good technical reason to me.
> 
> 9 files changed, 112 insertions(+), 1 deletion(-)
> 
> is quite a lot especially when it touches hot paths like fork so it
> better should have a good usecase. I have already asked in the other
> email but is actually anybody requesting this? Nice to have is not
> a good justification IMO.

I need some way to judge the real rss of a process, including huge
pages.  No strong opinion on implementation details, but something is
clearly needed.

If you have processes with 99% huge pages, you are currently reduced to
guesswork.

Jorn

--
Journalism is printing what someone else does not want printed;
everything else is public relations.
-- George Orwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
