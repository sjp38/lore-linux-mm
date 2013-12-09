Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id C1D236B0098
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 08:34:31 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so2567036yha.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 05:34:31 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id n44si10118942yhn.140.2013.12.09.05.34.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 05:34:30 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id w10so5255101pde.7
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 05:34:29 -0800 (PST)
Message-ID: <52A5C6E1.8020406@gmail.com>
Date: Mon, 09 Dec 2013 21:34:25 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <52A5935A.4040709@imgtec.com> <52A5973A.7020509@gmail.com> <52A5990E.2080808@imgtec.com> <52A5A7B5.2040904@gmail.com> <52A5AC11.8050802@imgtec.com>
In-Reply-To: <52A5AC11.8050802@imgtec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/09/2013 07:40 PM, James Hogan wrote:
> On 09/12/13 11:21, Chen Gang wrote:
>> Oh, I tried gcc 4.6.3-2 rhel version, get the same result as yours (do
>> not report warning), but for me, it is still a compiler's bug, it
>> *should* report a warning for it, we can try below:
> 
> Not necessarily. You can't expect the compiler to detect and warn about
> more complex bugs the programmer writes, so you have to draw the line
> somewhere.
> 

Yeah, we can not only depend on compiler to help us finding bugs.


> IMO missing some potential bugs is better than warning about code that
> isn't buggy since that just makes people ignore the warnings or
> carelessly try to silence them.
> 

I can understand, every members have their own taste, so this patch is
depended on related maintainers' taste (so kernel provided
"EXTRA_CFLAGS=-W" to satisfy some of guys taste -- e.g. me).  ;-)


Thanks
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
