Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id CFA686B0078
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 21:11:26 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id u14so3210019lbd.12
        for <linux-mm@kvack.org>; Sat, 14 Sep 2013 18:11:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <523486E4.3000206@redhat.com>
References: <20130914115335.3AA33428001@webmail.sinamail.sina.com.cn>
	<523486E4.3000206@redhat.com>
Date: Sun, 15 Sep 2013 09:11:24 +0800
Message-ID: <CAJd=RBDhm5ZAQdi4K+JK3FZ-=jaNz6peyLtSxMrBGcGmKX=6qw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: numa: adjust hinting fault record if page is migrated
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: dhillf@sina.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hello Rik

On Sat, Sep 14, 2013 at 11:55 PM, Rik van Riel <riel@redhat.com> wrote:
> On 09/14/2013 07:53 AM, Hillf Danton wrote:
>> After page A on source node is migrated to page B on target node, hinting
>> fault is recorded on the target node for B. On the source node there is
>> another record for A, since a two-stage filter is used when migrating pages.
>>
>> Page A is no longer used after migration, so we have to erase its record.
>
> What kind of performance changes have you observed with this patch?
>
> What benchmarks have you run, and on what kind of systems?
>
Due to no NUMA box, I can not answer you now.
I will try best to borrow one next Monday.

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
