Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id CEEFD6B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 23:00:37 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id ds1so1517389wgb.2
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 20:00:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210181314380.26994@chino.kir.corp.google.com>
References: <1350555140-11030-1-git-send-email-lliubbo@gmail.com>
	<1350555140-11030-2-git-send-email-lliubbo@gmail.com>
	<alpine.DEB.2.00.1210181314380.26994@chino.kir.corp.google.com>
Date: Fri, 19 Oct 2012 11:00:36 +0800
Message-ID: <CAA_GA1djHQ1QRO9oi+NOdJo58VNGn=woz8mpvwzpdv5HqeLOkQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] thp: introduce hugepage_get_pmd()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, xiaoguangrong@linux.vnet.ibm.com, hughd@google.com, kirill.shutemov@linux.intel.com, Linux-MM <linux-mm@kvack.org>

On Fri, Oct 19, 2012 at 4:15 AM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 18 Oct 2012, Bob Liu wrote:
>
>> Introduce hugepage_get_pmd() to simple code.
>>
>
> I don't see this as simple just because you're removing more lines, I find
> pagetable walks to be harder to read when split up like this and the "get"
> part implies you're grabbing a reference on the pmd, which you're not.

There are really too much place(at least four) do pagetable walks in thp.

My original idea was putting them into one pagewalk fucntion together,
that would be
clearer and more readable.

But there are several different pmd checks, no better way found to
collect them currently.
i'll keep on working on that.

Thanks.
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
