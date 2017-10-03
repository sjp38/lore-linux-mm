Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 697776B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:23:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i124so5046407wmf.7
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:23:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p49si998642eda.49.2017.10.03.08.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:23:19 -0700 (PDT)
Subject: Re: [PATCH v9 06/12] mm: zero struct pages during initialization
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-7-pasha.tatashin@oracle.com>
 <20171003130857.vohli6lnqj4tdmhl@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <73ea1215-7aa2-39e1-b820-30f58119183e@oracle.com>
Date: Tue, 3 Oct 2017 11:22:35 -0400
MIME-Version: 1.0
In-Reply-To: <20171003130857.vohli6lnqj4tdmhl@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com



On 10/03/2017 09:08 AM, Michal Hocko wrote:
> On Wed 20-09-17 16:17:08, Pavel Tatashin wrote:
>> Add struct page zeroing as a part of initialization of other fields in
>> __init_single_page().
>>
>> This single thread performance collected on: Intel(R) Xeon(R) CPU E7-8895
>> v3 @ 2.60GHz with 1T of memory (268400646 pages in 8 nodes):
>>
>>                          BASE            FIX
>> sparse_init     11.244671836s   0.007199623s
>> zone_sizes_init  4.879775891s   8.355182299s
>>                    --------------------------
>> Total           16.124447727s   8.362381922s
> 
> Hmm, this is confusing. This assumes that sparse_init doesn't zero pages
> anymore, right? So these number depend on the last patch in the series?

Correct, without the last patch sparse_init time won't change.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
