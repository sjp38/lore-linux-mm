Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABD36B0037
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 03:28:10 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so6910115pbb.24
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 00:28:10 -0700 (PDT)
Message-ID: <525B9CEC.5000903@huawei.com>
Date: Mon, 14 Oct 2013 15:27:40 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Fix calculation of cpu slabs
References: <522E9569.9060104@huawei.com> <0000014109b29246-61170b4a-7ab7-41f0-a887-a1cd62603196-000000@email.amazonses.com>
In-Reply-To: <0000014109b29246-61170b4a-7ab7-41f0-a887-a1cd62603196-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Pekka,

could you pick up this patch?

On 2013/9/11 5:06, Christoph Lameter wrote:
> On Tue, 10 Sep 2013, Li Zefan wrote:
> 
>> We should use page->pages instead of page->pobjects when calculating
>> the number of cpu partial slabs. This also fixes the mapping of slabs
>> and nodes.
> 
> True.
> 
>> As there's no variable storing the number of total/active objects in
>> cpu partial slabs, and we don't have user interfaces requiring those
>> statistics, I just add WARN_ON for those cases.
> 
> 
> Well that is not strictly required but it does not hurt either.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
