Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13F316B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 22:21:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so4893343qte.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 19:21:30 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h205si58294ybc.321.2016.07.11.19.21.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 19:21:29 -0700 (PDT)
Message-ID: <5784540F.1030509@huawei.com>
Date: Tue, 12 Jul 2016 10:21:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the
 page table
References: <1468218961-11018-1-git-send-email-zhongjiang@huawei.com> <1468218961-11018-2-git-send-email-zhongjiang@huawei.com> <20160711132550.75728ddb05317565ef7724d6@linux-foundation.org>
In-Reply-To: <20160711132550.75728ddb05317565ef7724d6@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/7/12 4:25, Andrew Morton wrote:
> On Mon, 11 Jul 2016 14:36:01 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when image is loaded into kernel, we need set up page table for it.
>> and all valid pfn also set up new mapping. it will set up a pmd huge
>> entry if pud_present is true.  relocate_kernel points to code segment
>> can locate in the pmd huge entry in init_transtion_pgtable. therefore,
>> we need to take the situation into account.
> Sorry, I just don't understand this changelog.  The second sentence is
> particularly hard.
>
> So can you please have another attempt at preparing the changelog text?
> The resend the patches and this time be sure to Cc the kexec
> maintainers.  I suggest this list:
>
> Cc: kexec@lists.infradead.org
> Cc: Eric Biederman <ebiederm@xmission.com>
> Cc: Dave Young <dyoung@redhat.com>
> Cc: Vivek Goyal <vgoyal@redhat.com>
> Cc: Simon Horman <horms@verge.net.au>
>
>
> .
>
 ok ,  I will modify the changelog and resend to this list. thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
