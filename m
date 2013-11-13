Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB726B00A8
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 01:24:52 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq2so5135631pbb.6
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 22:24:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id r6si979172paa.298.2013.11.12.22.24.50
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 22:24:51 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id q10so35554pdj.17
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 22:24:49 -0800 (PST)
Message-ID: <52831B2C.7090905@vflare.org>
Date: Tue, 12 Nov 2013 22:24:44 -0800
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
References: <20131107070451.GA10645@bbox> <20131112154137.GA3330@gmail.com> <20131113024252.GA1023@kroah.com>
In-Reply-To: <20131113024252.GA1023@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, riel@redhat.com, hughd@google.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Luigi Semenzato <semenzato@google.com>

On 11/12/13, 6:42 PM, Greg KH wrote:
> On Wed, Nov 13, 2013 at 12:41:38AM +0900, Minchan Kim wrote:
>> We spent much time with preventing zram enhance since it have been in staging
>> and Greg never want to improve without promotion.
>
> It's not "improve", it's "Greg does not want you adding new features and
> functionality while the code is in staging."  I want you to spend your
> time on getting it out of staging first.
>
> Now if something needs to be done based on review and comments to the
> code, then that's fine to do and I'll accept that, but I've been seeing
> new functionality be added to the code, which I will not accept because
> it seems that you all have given up on getting it merged, which isn't
> ok.
>

It's not that people have given up on getting it merged but every time 
patches are posted, there is really no response from maintainers perhaps 
due to their lack of interest in embedded, or perhaps they believe 
embedded folks are making a wrong choice by using zram. Either way, a 
final word, instead of just silence would be more helpful.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
