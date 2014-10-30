Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id DCDF99000B7
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 12:03:26 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id z107so4156124qgd.40
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 09:03:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a11si12888780qag.95.2014.10.30.09.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 09:03:25 -0700 (PDT)
Message-ID: <5452612C.5090609@oracle.com>
Date: Thu, 30 Oct 2014 12:02:52 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com> <20141030082712.GB4664@dhcp22.suse.cz> <54523DDE.9000904@oracle.com> <20141030141401.GA24520@phnom.home.cmpxchg.org> <54524A2F.5050907@oracle.com> <20141030150624.GA24818@phnom.home.cmpxchg.org>
In-Reply-To: <20141030150624.GA24818@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On 10/30/2014 11:06 AM, Johannes Weiner wrote:
>> You're using that value as soon as you are passing it to a function, it
>> > doesn't matter what happens inside that function.
> It's copied as part of the pass-by-value protocol, but we really don't
> do anything with it.  So why does it matter?

Because it's undefined behaviour, which gives your compiler a license to
do whatever it wants?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
