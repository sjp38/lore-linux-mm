Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8450C6B00B7
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:46:58 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id e89so5794908qgf.5
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:46:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c5si8323934qgc.117.2014.03.11.10.46.57
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 10:46:58 -0700 (PDT)
Message-ID: <531F4128.8020109@redhat.com>
Date: Tue, 11 Mar 2014 13:00:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
References: <5318E4BC.50301@oracle.com> <20140306173137.6a23a0b2@cuia.bos.redhat.com> <5318FC3F.4080204@redhat.com> <20140307140650.GA1931@suse.de> <20140307150923.GB1931@suse.de> <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de> <531F3F15.8050206@oracle.com>
In-Reply-To: <531F3F15.8050206@oracle.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On 03/11/2014 12:51 PM, Sasha Levin wrote:
> On 03/11/2014 12:28 PM, Mel Gorman wrote:
>> On Fri, Mar 07, 2014 at 06:27:45PM +0000, Mel Gorman wrote:
>>>> This is a completely untested prototype. It rechecks pmd_trans_huge
>>>> under the lock and falls through if it hit a parallel split. It's not
>>>> perfect because it could decide to fall through just because there was
>>>> no prot_numa work to do but it's for illustration purposes. Secondly,
>>>> I noted that you are calling invalidate for every pmd range. Is that
>>>> not
>>>> a lot of invalidations? We could do the same by just tracking the
>>>> address
>>>> of the first invalidation.
>>>>
>>>
>>> And there were other minor issues. This is still untested but Sasha,
>>> can you try it out please? I discussed this with Rik on IRC for a bit
>>> and
>>> reckon this should be sufficient if the correct race has been
>>> identified.
>>>
>>
>> Any luck with this patch Sasha? It passed basic tests here but I had not
>> seen the issue trigger either.
>>
>
> Sorry, I've been stuck in my weekend project of getting lockdep to work
> with page locks :)
>
> It takes a moment to test, so just to be sure - I should have only this
> last patch applied?
> Without the one in the original mail?

Indeed, only this patch should do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
