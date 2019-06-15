Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3440EC31E47
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:07:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD8E921848
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="CFZCdvS6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD8E921848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 125FC6B0003; Sat, 15 Jun 2019 04:07:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FDAF6B0005; Sat, 15 Jun 2019 04:07:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013238E0001; Sat, 15 Jun 2019 04:07:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAAAD6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 04:07:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e6so2065690wrv.20
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 01:07:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1p6s1wDC21lFcLrW9LHAqnn+cIQAnQKI/I9iSnqTFsU=;
        b=Ryc4baz1baaTjZ24frjnblNwYzy9ql3vavr0tNYlZE9a9uCPXxeljDHhX/vFlgwC2Q
         PvOp5ERy6tNbKBsp66nbFaMU6C/7l7S/LCwP4+78z17e8BPb19wfCsWEzoNHgtliGKg4
         qSI7zKhBNb0HQGfXB1fX0Sg2c7xTNY9gREojg3Z/3O2ME0a3TmVN0n+oNWPeBB6x/o2p
         KRXpiy9kOV3KrlxBXVDJRN426gp7LVfd5q3f3M62pLdtBcw6cAI2zh5rv918n6ufO5+s
         rkZ+0SpnB59afTRQEi7KPbKCfUBeWfN3lYH/chILS75Dl1gi9kSlm2A50w3i6aw4Xp0P
         /T5g==
X-Gm-Message-State: APjAAAVDC+A4YKP93jIpjnt9ATw1kbMF/KnEc0HmX9WcOuEudyB2QC13
	+yAP+5+KZHCJ9s34FZUmfSjoHA+szFAPSGrn9oRPpDfCe09DJhGQ6dBxKPf5a+95ps+gTvDSa1O
	ZEC5wmgFPdFZe5LKvn6ZfynbQmmsoH6Lh93W9aam/R9LAfJrC+nkX4RGjMS+Y1W6GKQ==
X-Received: by 2002:a1c:63d7:: with SMTP id x206mr11017776wmb.19.1560586021122;
        Sat, 15 Jun 2019 01:07:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwS8MlPXXblmJ9e7y6Y8qxHEr3W7cHkfBaJop5Fl19xADRRZ8HYKrUDKVPmre2QOvd6XBH1
X-Received: by 2002:a1c:63d7:: with SMTP id x206mr11017723wmb.19.1560586020163;
        Sat, 15 Jun 2019 01:07:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560586020; cv=none;
        d=google.com; s=arc-20160816;
        b=keetAS/NMdaCzNrE4sLYN+BYB4WPvnl1sx7E49oj/sTq3DaIjKiTGM0R37a2klWvo3
         PiL4yz7BkRcDBAs1yqssBE0mNcMkJatCvOtuiQLwSG6iDJOVmzVQVrKg5/l8UGqF9dto
         LnAV8YcanTp//N4pQRuhQYhPbJg+crn1W0ATghLP2oXvAr1K19WaJY34k+2XMgW8DQ/E
         RVHW3AoteqmT66d1lULLe+Lsgu0bt8amSNJLLhtxBZwhlkYPzRJthccrnjeDL6h4x95h
         pi2ezsnhrAHYvHzNjg98VHhK0EbIj2SW7hp1uJKtFZ/kMWjz1kHye52PmVSwdD6JIHjJ
         ATnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1p6s1wDC21lFcLrW9LHAqnn+cIQAnQKI/I9iSnqTFsU=;
        b=PCO2BCjSSqbpNu0DzHXWWunXhdFmag95o2ZqJ6zpF8xj7oiTGcNf/VxbiZe8IL47hF
         VnkMXSmSphuNNGr3GoJe5FPKHcTpwS3abAS6wrXixeNzq3MgAfl7JZ3Dvi352TbPocDy
         /NyXlcbCc4BMbQW5A0zO/j360A7lm2Y3HcWRe5oPauVVBQ+Q3jTJ87JoVkRsy9URdzAg
         81i0I+vmokIC2NKr0xahU1FnPSdmV/bPPQ+HNld64nR5z+dItG2xj7audKared2eveXP
         j8ZnZSK9l4G6aGLIQGcNbwn7l57kDR8F5NpTSZeY2J8NUXAcqu6bb5KxmLoIC76Ze1A7
         tIxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=CFZCdvS6;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id g8si2818221wrb.386.2019.06.15.01.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 01:07:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=CFZCdvS6;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 45QqnX6hxKz9v0F9;
	Sat, 15 Jun 2019 10:06:56 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=CFZCdvS6; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id hc2rOByaNF3V; Sat, 15 Jun 2019 10:06:56 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 45QqnX5Gqkz9v0F8;
	Sat, 15 Jun 2019 10:06:56 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1560586016; bh=1p6s1wDC21lFcLrW9LHAqnn+cIQAnQKI/I9iSnqTFsU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=CFZCdvS6Gn44Gms6CdPAgtpa9H53SYlJJFfS68xOIrkZxayPk64IgDJI88xDV354W
	 YUTg0/LxuR+UPAdtUprz+7sTpVdF78EI+TcFZzuJjZLj1OU2Oi01DPmjcAOipLL3Gq
	 9wjMJkVHKam+/9rCfdG+6q/sqIpKw2+fLOUwJHCI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BA5A58B7B3;
	Sat, 15 Jun 2019 10:06:57 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id FwFmC_wRUTFQ; Sat, 15 Jun 2019 10:06:57 +0200 (CEST)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 96D348B77A;
	Sat, 15 Jun 2019 10:06:56 +0200 (CEST)
Subject: Re: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
To: Andrew Morton <akpm@linux-foundation.org>,
 David Hildenbrand <david@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>,
 Mel Gorman <mgorman@techsingularity.net>, Baoquan He <bhe@redhat.com>,
 linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org,
 Wei Yang <richard.weiyang@gmail.com>, linux-acpi@vger.kernel.org,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Arun KS <arunks@codeaurora.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 Dan Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org,
 Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>
References: <20190614100114.311-1-david@redhat.com>
 <20190614100114.311-2-david@redhat.com>
 <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <701e8feb-cbf8-04c1-758c-046da9394ac1@c-s.fr>
Date: Sat, 15 Jun 2019 10:06:54 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 14/06/2019 à 21:00, Andrew Morton a écrit :
> On Fri, 14 Jun 2019 12:01:09 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>> We are using a mixture of "int" and "unsigned long". Let's make this
>> consistent by using "unsigned long" everywhere. We'll do the same with
>> memory block ids next.
>>
>> ...
>>
>> -	int i, ret, section_count = 0;
>> +	unsigned long i;
>>
>> ...
>>
>> -	unsigned int i;
>> +	unsigned long i;
> 
> Maybe I did too much fortran back in the day, but I think the
> expectation is that a variable called "i" has type "int".
> 
> This?
> 
> 
> 
> s/unsigned long i/unsigned long section_nr/

 From my point of view you degrade readability by doing that.

section_nr_to_pfn(mem->start_section_nr + section_nr);

Three times the word 'section_nr' in one line, is that worth it ? Gives 
me headache.

Codying style says the following, which makes full sense in my opinion:

LOCAL variable names should be short, and to the point.  If you have
some random integer loop counter, it should probably be called ``i``.
Calling it ``loop_counter`` is non-productive, if there is no chance of it
being mis-understood.

What about just naming it 'nr' if we want to use something else than 'i' ?

Christophe


> 
> --- a/drivers/base/memory.c~mm-section-numbers-use-the-type-unsigned-long-fix
> +++ a/drivers/base/memory.c
> @@ -131,17 +131,17 @@ static ssize_t phys_index_show(struct de
>   static ssize_t removable_show(struct device *dev, struct device_attribute *attr,
>   			      char *buf)
>   {
> -	unsigned long i, pfn;
> +	unsigned long section_nr, pfn;
>   	int ret = 1;
>   	struct memory_block *mem = to_memory_block(dev);
>   
>   	if (mem->state != MEM_ONLINE)
>   		goto out;
>   
> -	for (i = 0; i < sections_per_block; i++) {
> -		if (!present_section_nr(mem->start_section_nr + i))
> +	for (section_nr = 0; section_nr < sections_per_block; section_nr++) {
> +		if (!present_section_nr(mem->start_section_nr + section_nr))
>   			continue;
> -		pfn = section_nr_to_pfn(mem->start_section_nr + i);
> +		pfn = section_nr_to_pfn(mem->start_section_nr + section_nr);
>   		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
>   	}
>   
> @@ -695,12 +695,12 @@ static int add_memory_block(unsigned lon
>   {
>   	int ret, section_count = 0;
>   	struct memory_block *mem;
> -	unsigned long i;
> +	unsigned long section_nr;
>   
> -	for (i = base_section_nr;
> -	     i < base_section_nr + sections_per_block;
> -	     i++)
> -		if (present_section_nr(i))
> +	for (section_nr = base_section_nr;
> +	     section_nr < base_section_nr + sections_per_block;
> +	     section_nr++)
> +		if (present_section_nr(section_nr))
>   			section_count++;
>   
>   	if (section_count == 0)
> @@ -823,7 +823,7 @@ static const struct attribute_group *mem
>    */
>   int __init memory_dev_init(void)
>   {
> -	unsigned long i;
> +	unsigned long section_nr;
>   	int ret;
>   	int err;
>   	unsigned long block_sz;
> @@ -840,9 +840,9 @@ int __init memory_dev_init(void)
>   	 * during boot and have been initialized
>   	 */
>   	mutex_lock(&mem_sysfs_mutex);
> -	for (i = 0; i <= __highest_present_section_nr;
> -		i += sections_per_block) {
> -		err = add_memory_block(i);
> +	for (section_nr = 0; section_nr <= __highest_present_section_nr;
> +		section_nr += sections_per_block) {
> +		err = add_memory_block(section_nr);
>   		if (!ret)
>   			ret = err;
>   	}
> _
> 

