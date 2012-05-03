Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 74CAB6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 00:38:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 3 May 2012 10:08:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q434cOmI38993936
	for <linux-mm@kvack.org>; Thu, 3 May 2012 10:08:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q43A90V7017680
	for <linux-mm@kvack.org>; Thu, 3 May 2012 20:09:01 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
In-Reply-To: <CAP=VYLqgaCabQGDVgUXnCwKCZHtz0nWxpm_a6Cgz_ciMzGe9gQ@mail.gmail.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <CAP=VYLqgaCabQGDVgUXnCwKCZHtz0nWxpm_a6Cgz_ciMzGe9gQ@mail.gmail.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Thu, 03 May 2012 10:07:59 +0530
Message-ID: <87pqalhobc.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-next@vger.kernel.org

Paul Gortmaker <paul.gortmaker@windriver.com> writes:

> On Mon, Apr 16, 2012 at 6:44 AM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>
>> This patch implements a memcg extension that allows us to control HugeTLB
>> allocations via memory controller. The extension allows to limit the
>
> Hi Aneesh,
>
> This breaks linux-next on some arch because they don't have any
> HUGE_MAX_HSTATE in scope with the current #ifdef layout.
>
> The breakage is in sh4, m68k, s390, and possibly others.
>
> http://kisskb.ellerman.id.au/kisskb/buildresult/6228689/
> http://kisskb.ellerman.id.au/kisskb/buildresult/6228670/
> http://kisskb.ellerman.id.au/kisskb/buildresult/6228484/
>
> This is a commit in akpm's mmotm queue, which used to be here:
>
> http://userweb.kernel.org/~akpm/mmotm
>
> Of course the above is invalid since userweb.kernel.org is dead.
> I don't have a post-kernel.org break-in link handy and a quick
> search didn't give me one, but I'm sure you'll recognize the change.
>

Andrew have the below patch 

http://article.gmane.org/gmane.linux.kernel.commits.mm/71649

Does that fix the error ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
