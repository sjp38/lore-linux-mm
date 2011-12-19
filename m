Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 32D966B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 00:20:21 -0500 (EST)
Received: by iacb35 with SMTP id b35so7910960iac.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 21:20:20 -0800 (PST)
Message-ID: <4EEEC988.2060309@gmail.com>
Date: Mon, 19 Dec 2011 13:20:08 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy.c: use enum value MPOL_REBIND_ONCE instead
 of 0 in mpol_rebind_policy
References: <4EE8A461.2080406@gmail.com> <alpine.DEB.2.00.1112141840550.27595@chino.kir.corp.google.com> <4EEC9D54.502@gmail.com> <alpine.DEB.2.00.1112181444530.1364@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112181444530.1364@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2011a1'12ae??19ae?JPY 06:45, David Rientjes wrote:
> 
> On Sat, 17 Dec 2011, Wang Sheng-Hui wrote:
> 
>>> Tip: when proposing patches, it's helpful to run scripts/get_maintainer.pl 
>>> on your patch file from git to determine who should be cc'd on the email.
>>
>> Thanks for your tip.
>> I have tried the script with option -f, and only get the mm, kernel mailing
>> lists, no specific maintainer provided. So here I just posted the patch to 
>> these 2 lists.
>>
> 
> $ ./scripts/get_maintainer.pl -f mm/mempolicy.c
> Andrew Morton <akpm@linux-foundation.org> (commit_signer:19/23=83%)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (commit_signer:8/23=35%)
> Stephen Wilson <wilsons@start.ca> (commit_signer:6/23=26%)
> Andrea Arcangeli <aarcange@redhat.com> (commit_signer:5/23=22%)
> Johannes Weiner <hannes@cmpxchg.org> (commit_signer:3/23=13%)
> linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> linux-kernel@vger.kernel.org (open list)
> 
> All of those people should be cc'd on patches touching mm/mempolicy.c.
Got it. Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
