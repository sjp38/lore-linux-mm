Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D5DA56B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 09:43:45 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wp18so1029187obc.35
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 06:43:45 -0700 (PDT)
Received: from mail-oa0-x230.google.com (mail-oa0-x230.google.com [2607:f8b0:4003:c02::230])
        by mx.google.com with ESMTPS id dq4si2490062oeb.34.2014.03.13.06.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 06:43:45 -0700 (PDT)
Received: by mail-oa0-f48.google.com with SMTP id m1so1039475oag.21
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 06:43:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <532136C1.5020502@samsung.com>
References: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
 <532136C1.5020502@samsung.com>
From: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>
Date: Thu, 13 Mar 2014 19:13:23 +0530
Message-ID: <CAA6Yd9UxYg7SMyW2HtNREM7AtkQjQ67kerFoHday5L8+CjE-tQ@mail.gmail.com>
Subject: Re: cma: alloc_contig_range test_pages_isolated .. failed
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: linux-mm@kvack.org

Hello

On Thu, Mar 13, 2014 at 10:10 AM, Heesub Shin <heesub.shin@samsung.com> wrote:
>
> On 03/11/2014 11:02 PM, Ramakrishnan Muthukrishnan wrote:
>>
>> [   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
>> [   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
>> [   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
>> [   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed
>
>
> "memory-hotplug: fix pages missed by race rather than failing" by Minchan
> Kim (435b405) would also help you, which was merged after v3.4.

Yes, I tried that and the associated parent patches as well but
unfortunately that too didn't help.

-- 
  Ramakrishnan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
