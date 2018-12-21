Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C671C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:46:54 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id s64-v6so1923350lje.19
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:46:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2-v6sor16602776ljg.42.2018.12.21.10.46.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:46:53 -0800 (PST)
Subject: Re: [PATCH 01/12] x86_64: memset_user()
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
 <20181221182515.GF10600@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <f2661969-a0d8-45e1-4334-c9b74d08f143@gmail.com>
Date: Fri, 21 Dec 2018 20:46:48 +0200
MIME-Version: 1.0
In-Reply-To: <20181221182515.GF10600@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 21/12/2018 20:25, Matthew Wilcox wrote:
> On Fri, Dec 21, 2018 at 08:14:12PM +0200, Igor Stoppa wrote:
>> +unsigned long __memset_user(void __user *addr, int c, unsigned long size)
>> +{
>> +	long __d0;
>> +	unsigned long  pattern = 0;
>> +	int i;
>> +
>> +	for (i = 0; i < 8; i++)
>> +		pattern = (pattern << 8) | (0xFF & c);
> 
> That's inefficient.
> 
> 	pattern = (unsigned char)c;
> 	pattern |= pattern << 8;
> 	pattern |= pattern << 16;
> 	pattern |= pattern << 32;

ok, thank you

--
igor
