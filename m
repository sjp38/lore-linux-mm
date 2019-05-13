Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94E11C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 07:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4593F206BF
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 07:49:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4593F206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3D136B0005; Mon, 13 May 2019 03:49:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6886B0006; Mon, 13 May 2019 03:49:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3FD66B0007; Mon, 13 May 2019 03:49:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 817BB6B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 03:49:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q32so13615164qtk.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 00:49:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xe+ARmEtb8xBh8MUVAlBnTfA466DDi1Opi/EgdkU/n0=;
        b=r4voSbWGYcXwB8MJ39iIEeLP5c9+AvagpkqlsYZ1Lqx9PxzqmFYW5efGw9mepBapIY
         evurUtGFvsfWIh0j6TgelxOVfIj2Av5kV4pjrEek7wL1KJX0pOSnKAD7aaQEKvcMwuyc
         HPg0ZWzS7J8mTYt6JmUs/RGVe27Yo8ssv/ikLntAx5dAL/eJJpC2iewnVw125x6YE2j6
         hg8l5Cz69YS6PNNA2uezmiD5oMewzXRZn6GS8fHB0O2/NFo3XLza991tY6//XCy1zfW1
         Ni+AGpGg1OniEIRHWAR2t70TO/huuw2KYZeXK8Y8TpNejbIIxvkm6CNX5zuUGG3lfaeV
         QiVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZWJyIv4B0+Z+1VIyTuSIqvAmJC0ixH+igJlcnhrFwrZ74Iuib
	bC0evzhylvNwUBrEA3u2VVYTGFz7udtacoVcS0IEYDmsQKl3dE91Hhxk15p6GzWKqfJXFFmM4Mv
	GtXmLPWEoL4WIqU+4EBzyqTHto7yxCO0F5aPoAb98DEgZKH1NrFML0axZ0+UdbtjaWw==
X-Received: by 2002:ac8:18d4:: with SMTP id o20mr22788838qtk.185.1557733783318;
        Mon, 13 May 2019 00:49:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYTMKx1JkK5WX7liYX1JajWm56bFK5hQZu4a7qTcDoJFRedTxrbVipNcIJOXj7sED5640h
X-Received: by 2002:ac8:18d4:: with SMTP id o20mr22788804qtk.185.1557733782673;
        Mon, 13 May 2019 00:49:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557733782; cv=none;
        d=google.com; s=arc-20160816;
        b=Q2CeajxARmz/lztof7voOkKvqPBnsCZC3dBKXuPxi3yr1OGVQZsh8KUltN1yOua4Wl
         bndT1P/FGUhcxyoZgGnnayCpvB7Wwwy/mNFf1SWZ+M+1+xt4Pynu/cQp6ye0lZHT/idF
         OLdUYnSB2IRm+UEUv3QumQ7JU84pXdC9s6QFz2bt/Vj1HDHxrJn48ww2AMxNWodm8EwL
         QmrI1V4RcgQwVoUX6enWn3D62P72ZPDIj4hUUmw6E7fs4rPc+sZNDqQLTrx/sStGwYOz
         PtNfNn3a6wInlN2cdFdrezR7Lo9Jk6KavTKvZKW+rToE7wObN0YnO7PoLcmfleO/bfDF
         lxgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xe+ARmEtb8xBh8MUVAlBnTfA466DDi1Opi/EgdkU/n0=;
        b=P2VAu+7iySFbAighWCsP6xkjSw6flXKvZFtbKilU7AJHhQAjQLZZ8v9Z4JyVYu57Ii
         8lY+Q8d8DY4t33HWQSR8+RFP3xFOZDWaR3QuCO3w8J15hanL9bRIvlBu0WmRbYDZSuCk
         G20UvlFkdx+Cpue6D+FpCQE9eDm5GZynef+THMm59od8lCIwCefDAVZTKEEcwTL34jKW
         qjzWEOq6CB3E9YPreG9eVAbBM86mbnRhiyFrpwVoN9rLg9SpcVY+20tG5rAUV3W1kSFk
         OOHWCtFN9BH07c6gMKagCNVCn5MH0qbcZa/+nFdfJIDgAXrdqxNuvLxxt/vw7MtSj9QG
         lSXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 40si2038991qvi.197.2019.05.13.00.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 00:49:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A29043091753;
	Mon, 13 May 2019 07:49:40 +0000 (UTC)
Received: from [10.36.117.84] (ovpn-117-84.ams2.redhat.com [10.36.117.84])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 28AF060856;
	Mon, 13 May 2019 07:49:30 +0000 (UTC)
Subject: Re: [PATCH v2 3/8] mm/memory_hotplug: arch_remove_memory() and
 __remove_pages() with CONFIG_MEMORY_HOTPLUG
To: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Nicholas Piggin <npiggin@gmail.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Rob Herring <robh@kernel.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Andrew Banman <andrew.banman@hpe.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>,
 Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-4-david@redhat.com>
 <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c027a782-1cef-a076-92a3-3ce36140f3f2@redhat.com>
Date: Mon, 13 May 2019 09:48:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jpnKjeP3QEvF3_9CzdZhtFXN2nMU7P-Ee7y06J3bGZ0A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 13 May 2019 07:49:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 23:02, Dan Williams wrote:
> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> Let's prepare for better error handling while adding memory by allowing
>> to use arch_remove_memory() and __remove_pages() even if
>> CONFIG_MEMORY_HOTREMOVE is not set. CONFIG_MEMORY_HOTREMOVE effectively
>> covers
>> - Offlining of system ram (memory block devices) - offline_pages()
>> - Unplug of system ram - remove_memory()
>> - Unplug/remap of device memory - devm_memremap()
>>
>> This allows e.g. for handling like
>>
>> arch_add_memory()
>> rc = do_something();
>> if (rc) {
>>         arch_remove_memory();
>> }
>>
>> Whereby do_something() will for example be memory block device creation
>> after it has been factored out.
> 
> What's left after this? Can we just get rid of CONFIG_MEMORY_HOTREMOVE
> option completely when CONFIG_MEMORY_HOTPLUG is enabled? It's not
> clear to me why there was ever the option to compile out the remove
> code when the add code is included.
> 

If there are no other comments, I will go ahead and rip out
CONFIG_MEMORY_HOTREMOVE completely, gluing the functionality to
CONFIG_MEMORY_HOTPLUG.

-- 

Thanks,

David / dhildenb

