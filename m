Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1AA4E6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:27:39 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id aq17so286800iec.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 18:27:38 -0700 (PDT)
Message-ID: <51E4A181.2030707@gmail.com>
Date: Tue, 16 Jul 2013 09:27:29 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] mm, hugetlb: clean-up and possible bug fix
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com> <871u6zkj7b.fsf@linux.vnet.ibm.com> <20130716011054.GC2430@lge.com>
In-Reply-To: <20130716011054.GC2430@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/16/2013 09:10 AM, Joonsoo Kim wrote:
> On Mon, Jul 15, 2013 at 07:40:16PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>>
>>> First 5 patches are almost trivial clean-up patches.
>>>
>>> The others are for fixing three bugs.
>>> Perhaps, these problems are minor, because this codes are used
>>> for a long time, and there is no bug reporting for these problems.
>>>
>>> These patches are based on v3.10.0 and
>>> passed sanity check of libhugetlbfs.
>> does that mean you had run with libhugetlbfs test suite ?
> Yes! I can't find any reggression on libhugetlbfs test suite.

Where can get your test case?

>
>>   
>> -aneesh
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
