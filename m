Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A44026B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 12:39:02 -0400 (EDT)
Received: by pdob1 with SMTP id b1so28380694pdo.2
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:39:02 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ps2si13595984pbb.193.2015.08.21.09.39.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 09:39:01 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so10599249pad.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 09:39:01 -0700 (PDT)
Date: Fri, 21 Aug 2015 09:38:58 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150821163858.GB4600@Sligo.logfs.org>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508201249010.27169@chino.kir.corp.google.com>
 <20150821063233.GB23723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150821063233.GB23723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 21, 2015 at 08:32:33AM +0200, Michal Hocko wrote:
> 
> Both mmotm and linus tree have
>         REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
> 
> and opening the file requires PTRACE_MODE_READ. So I do not see any
> requirement for root here. Or did you mean that you need root to examine
> all processes? That would be true but I am wondering why would be a regular
> user interested in this break out numbers. Hugetlb management sounds
> pretty much like an administrative or very specialized thing.
> 
> From my understanding of the discussion there is no usecase to have this
> information world readable. Is this correct?

Well, tools like top currently display rss.  Once we have some
interface, I would like a version of top that displays the true rss
including hugepages (hrss maybe?).

If we make such a tool impossible today, someone will complain about it
in the future and we created a new mess for ourselves.  I think it is
trouble enough to deal with the old one.

Jorn

--
Denying any reality for any laudable political goal is a bad strategy.
When the facts come out, the discovery of the facts will undermine the
laudable political goals.
-- Jared Diamond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
