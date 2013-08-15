Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id CC7606B0075
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 17:06:45 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id k18so1427352oag.40
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 14:06:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org>
References: <1376545589-32129-1-git-send-email-yinghai@kernel.org>
	<20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org>
Date: Thu, 15 Aug 2013 14:06:44 -0700
Message-ID: <CAE9FiQUyGpmMP0VPE5ZrvDMLB-sdb0DzajGvB_KDt-ZnoJZhPg@mail.gmail.com>
Subject: Re: [PATCH] memblock, numa: Binary search node id
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Russ Anderson <rja@sgi.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 15, 2013 at 1:43 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 Aug 2013 22:46:29 -0700 Yinghai Lu <yinghai@kernel.org> wrote:
>
>> Current early_pfn_to_nid() on arch that support memblock go
>> over memblock.memory one by one, so will take too many try
>> near the end.
>>
>> We can use existing memblock_search to find the node id for
>> given pfn, that could save some time on bigger system that
>> have many entries memblock.memory array.
>
> Looks nice.  I wonder how much difference it makes.

Russ said he would test on his 256 nodes system, but looks he never
got chance.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
