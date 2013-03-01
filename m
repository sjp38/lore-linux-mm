Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 26D0B6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 20:28:40 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id h1so4895483oag.3
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:28:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130228155419.cf412612.akpm@linux-foundation.org>
References: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
 <1362029107-3908-2-git-send-email-kosaki.motohiro@gmail.com> <20130228155419.cf412612.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 28 Feb 2013 20:28:19 -0500
Message-ID: <CAHGf_=rF2-2CBzEFg1am1+X0k4vDN2-jaR3bXWruSWeKHOK5iQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mempolicy: fix typo
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>

On Thu, Feb 28, 2013 at 6:54 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 28 Feb 2013 00:25:07 -0500
> kosaki.motohiro@gmail.com wrote:
>
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Currently, n_new is wrongly initialized. start and end parameter
>> are inverted. Let's fix it.
>>
>> ...
>>
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2390,7 +2390,7 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
>>
>>                               *mpol_new = *n->policy;
>>                               atomic_set(&mpol_new->refcnt, 1);
>> -                             sp_node_init(n_new, n->end, end, mpol_new);
>> +                             sp_node_init(n_new, end, n->end, mpol_new);
>>                               n->end = start;
>>                               sp_insert(sp, n_new);
>>                               n_new = NULL;
>
> huh.  What were the runtime effects of this problem?

I think passed policy don't effect correctly. No big issue because nobody
uses route except Dave Jones testcase. (remember, until very recently,
this route has kernel crash bug and nobody have been hit.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
