Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D69616B0292
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 13:49:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c52so24249388wra.12
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:49:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 193si8455030wmm.48.2017.06.12.10.49.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 10:49:14 -0700 (PDT)
Date: Mon, 12 Jun 2017 19:49:11 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170612174911.GA23493@dhcp22.suse.cz>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612172829.bzjfmm7navnobh4t@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Mon 12-06-17 13:28:30, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@suse.com> [170606 02:01]:
[..]
> > And just to be more clear. I do not _object_ to the warning I just
> > _think_ it is not very useful actually. If somebody misconfigure so
> > badly that hugetlb allocations fail during the boot then it will be
> > very likely visible. But if somebody misconfigures slightly less to not
> > fail the system is very likely to not work properly and there will be no
> > warning that this might be the source of problems. So is it worth adding
> > more code with that limited usefulness?
> 
> I think telling the user that something failed is very useful.  This
> obviously does not cover off all failure cases as you have pointed out,
> but it is certainly better than silently continuing as is the case
> today.
> 
> Are you suggesting that the error message be provided if the failure
> happens after boot as well?

No, I am just suggesting that the warning as proposed is not useful and
it is worth the additional (aleit little) code. It doesn't cover many
other miscofigurations which might be even more serious because there
would be still _some_ memory left while the system would crawl to death.

My objections are not hard enough to give a right NAK I just think this
is a pointless code which won't help the current situation much.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
