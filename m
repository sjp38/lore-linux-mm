Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 37EAA6B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:54:46 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so14287125pdj.25
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:54:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u7si117934pdn.82.2014.09.04.13.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 13:54:45 -0700 (PDT)
Message-ID: <5408D0A6.9040505@oracle.com>
Date: Thu, 04 Sep 2014 16:50:46 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmap: use pr_emerg when printing BUG related information
References: <1409855782-15089-1-git-send-email-sasha.levin@oracle.com> <20140904133058.37ca7aa2e46a607eed94df3b@linux-foundation.org>
In-Reply-To: <20140904133058.37ca7aa2e46a607eed94df3b@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: oleg@redhat.com, riel@redhat.com, kirill.shutemov@linux.intel.com, luto@amacapital.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/04/2014 04:30 PM, Andrew Morton wrote:
> On Thu,  4 Sep 2014 14:36:22 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> Make sure we actually see the output of validate_mm() and browse_rb()
>> before triggering a BUG(). pr_info isn't shown by default so the reason
>> for the BUG() isn't obvious.
>>
> 
> yup, I'll scoot that into 3.17.
> 
> 
> That code's actually pretty cruddy.  How does this look?

The patch looks good.

I've got sidetracked and started working on dump_mm()...


Thanks,
Sasha


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
