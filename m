Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 482A7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD98720700
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD98720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31D386B0005; Wed, 27 Mar 2019 12:04:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F2076B0006; Wed, 27 Mar 2019 12:04:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BA976B0007; Wed, 27 Mar 2019 12:04:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC1546B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 12:04:02 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n1so1620745qte.12
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:04:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xkANHdW3SZgCyTOuB9dqs4+xKMibzoCyoGHQbX8nmOs=;
        b=HbHYyZPwLYF7NF5URSCzMzGiQAmV8KewchkRkZVvMsPVVCTCsTsAK78hP+iNgIiKF8
         wd4Q337kaXL0tDLcOueDt7p6lBKKBJRdoZkxAp4whRX0lZzZ/qg1R29xZa/NpSqIn4X5
         lK51CPB2lfJQl4z7Zsw2GnaALt1/NScrXKHba02msZhgFapS/1+x5LFu05IJa2/bw1FM
         vl67CMPmhACTGUJgThGTs5PvAog2RXpM4yvlsdMB8IO4rD+b2zBA6lyAYsGpxrTBMXFx
         EaDqUhATE0gA/tyG6jA68H1gm+apFR4SqE/3RKKaJqvGm1vqhsymoFC4pReOPlg26j2W
         luYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMRzduPNbU6GVpiEu52iselKNec7mr02ZEhdy7M08yAdQLm0G9
	WxnwZqsxE4POcTfPzPxVcyDTX+ZpSB8qeLpX+LfSrLbq1iGC2p6zSDziOO6QISvpmUaEpfk6xrR
	4DHYvjU2CcDzr3FufsyEQ1AF9j4MboEh8mo1obSJvm37gwfVK5/F3yo72adVG+mAkdg==
X-Received: by 2002:a05:620a:165c:: with SMTP id c28mr22420137qko.199.1553702642650;
        Wed, 27 Mar 2019 09:04:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWJ7934vnesXALIq7hEyy3CR8U5Gir7LRrbIRqSFkDl3VM5nHu6J1Rh4vrPyM1ESPwH9X2
X-Received: by 2002:a05:620a:165c:: with SMTP id c28mr22420054qko.199.1553702641691;
        Wed, 27 Mar 2019 09:04:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553702641; cv=none;
        d=google.com; s=arc-20160816;
        b=u8k2QiuLR4YuHc3CwkrDmc8524xOCpd9aWrGm5ErnSRfJK0UVO6iZ7vElgmwGMEFdA
         K/qiu+Dem4mdDp3krw5VIseWvFBRoWLyF/cHF/LJWimL1BtApUuEUYsY8Od2S5Sn85hO
         TnSSw+JB3peH3HuN3UO0UsjokzMe3pw42dIS2jw7minVzvDeanVs81NOt6tfTckd8cZy
         m3gHv2sI6XD/FnQ2GBUklEVLvv/iHTSvyWa6hKZoKxJ2aYI+JOvb5lAibEYYkoEgf45b
         a9Rl0wWGFGOwA0HttB6eYnwBP+9lEoao/UjqGIkemEB38hLL5+wz/erbhsUwkmdOcDrY
         l0zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xkANHdW3SZgCyTOuB9dqs4+xKMibzoCyoGHQbX8nmOs=;
        b=SjSHOAK3/Cvvfd5cAAvsMhbyj9lK5pQuiqd8C/GxqZbHoLgz1sT7IKRiCm5Ur8Ca9S
         H7Hgr5qrkBPVVE2FiFGY5vt75iPGuC4q4dMmXA12lQFJZIizer7VS+CSAB5vygdD0yYG
         o68NHkkooZGKkbIon/BAuo05rxyDo/6p7CTvKDDwtVGsk3Xe8REcfE8s2aSTdyotgqxE
         hf/ctAlEiWjuNgZ/vjepilbXk16QNNjEq5a1WXOaqhm5FiVOGy//H/S1gqwocCfK1S2O
         G6jEHyIhNzFnSN1ik6WI93OOrJsgUd2TVyI+VQH67hMcXm3AmU8a1Wb1lxlmtvICN0y+
         Wr4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k37si866841qte.375.2019.03.27.09.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 09:04:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DAE746447D;
	Wed, 27 Mar 2019 16:03:56 +0000 (UTC)
Received: from [10.36.116.99] (ovpn-116-99.ams2.redhat.com [10.36.116.99])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 96357100164A;
	Wed, 27 Mar 2019 16:03:34 +0000 (UTC)
Subject: Re: [PATCH RFCv2 0/4] mm/memory_hotplug: Introduce memory block types
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-acpi@vger.kernel.org, devel@linuxdriverproject.org,
 xen-devel@lists.xenproject.org, x86@kernel.org,
 Andrew Banman <andrew.banman@hpe.com>,
 Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski
 <luto@kernel.org>, Arun KS <arunks@codeaurora.org>,
 Balbir Singh <bsingharora@gmail.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Boris Ostrovsky
 <boris.ostrovsky@oracle.com>, Christophe Leroy <christophe.leroy@c-s.fr>,
 Dan Williams <dan.j.williams@intel.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Dave Jiang
 <dave.jiang@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
 Ingo Molnar <mingo@redhat.com>, =?UTF-8?Q?Jan_H=2e_Sch=c3=b6nherr?=
 <jschoenh@amazon.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>,
 Logan Gunthorpe <logang@deltatee.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Mathieu Malaterre <malat@debian.org>, Matthew Wilcox <willy@infradead.org>,
 Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>,
 =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Nathan Fontenot <nfont@linux.vnet.ibm.com>,
 Nicholas Piggin <npiggin@gmail.com>, Oscar Salvador <osalvador@suse.com>,
 Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Rashmica Gupta <rashmica.g@gmail.com>, Rich Felker <dalias@libc.org>,
 Rob Herring <robh@kernel.org>, Stefano Stabellini <sstabellini@kernel.org>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Thomas Gleixner
 <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>,
 Wei Yang <richard.weiyang@gmail.com>, Greg KH <gregkh@linuxfoundation.org>
References: <20181130175922.10425-1-david@redhat.com>
 <1b4afb6a-5f91-407d-6e6e-6a89b8cf5d56@redhat.com>
 <20181220130832.GH9104@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <39ec8cea-46c7-1be3-92a0-5ab2ddb0bbea@redhat.com>
Date: Wed, 27 Mar 2019 17:03:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20181220130832.GH9104@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 27 Mar 2019 16:04:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.12.18 14:08, Michal Hocko wrote:
> On Thu 20-12-18 13:58:16, David Hildenbrand wrote:
>> On 30.11.18 18:59, David Hildenbrand wrote:
>>> This is the second approach, introducing more meaningful memory block
>>> types and not changing online behavior in the kernel. It is based on
>>> latest linux-next.
>>>
>>> As we found out during dicussion, user space should always handle onlining
>>> of memory, in any case. However in order to make smart decisions in user
>>> space about if and how to online memory, we have to export more information
>>> about memory blocks. This way, we can formulate rules in user space.
>>>
>>> One such information is the type of memory block we are talking about.
>>> This helps to answer some questions like:
>>> - Does this memory block belong to a DIMM?
>>> - Can this DIMM theoretically ever be unplugged again?
>>> - Was this memory added by a balloon driver that will rely on balloon
>>>   inflation to remove chunks of that memory again? Which zone is advised?
>>> - Is this special standby memory on s390x that is usually not automatically
>>>   onlined?
>>>
>>> And in short it helps to answer to some extend (excluding zone imbalances)
>>> - Should I online this memory block?
>>> - To which zone should I online this memory block?
>>> ... of course special use cases will result in different anwers. But that's
>>> why user space has control of onlining memory.
>>>
>>> More details can be found in Patch 1 and Patch 3.
>>> Tested on x86 with hotplugged DIMMs. Cross-compiled for PPC and s390x.
>>>
>>>
>>> Example:
>>> $ udevadm info -q all -a /sys/devices/system/memory/memory0
>>> 	KERNEL=="memory0"
>>> 	SUBSYSTEM=="memory"
>>> 	DRIVER==""
>>> 	ATTR{online}=="1"
>>> 	ATTR{phys_device}=="0"
>>> 	ATTR{phys_index}=="00000000"
>>> 	ATTR{removable}=="0"
>>> 	ATTR{state}=="online"
>>> 	ATTR{type}=="boot"
>>> 	ATTR{valid_zones}=="none"
>>> $ udevadm info -q all -a /sys/devices/system/memory/memory90
>>> 	KERNEL=="memory90"
>>> 	SUBSYSTEM=="memory"
>>> 	DRIVER==""
>>> 	ATTR{online}=="1"
>>> 	ATTR{phys_device}=="0"
>>> 	ATTR{phys_index}=="0000005a"
>>> 	ATTR{removable}=="1"
>>> 	ATTR{state}=="online"
>>> 	ATTR{type}=="dimm"
>>> 	ATTR{valid_zones}=="Normal"
>>>
>>>
>>> RFC -> RFCv2:
>>> - Now also taking care of PPC (somehow missed it :/ )
>>> - Split the series up to some degree (some ideas on how to split up patch 3
>>>   would be very welcome)
>>> - Introduce more memory block types. Turns out abstracting too much was
>>>   rather confusing and not helpful. Properly document them.
>>>
>>> Notes:
>>> - I wanted to convert the enum of types into a named enum but this
>>>   provoked all kinds of different errors. For now, I am doing it just like
>>>   the other types (e.g. online_type) we are using in that context.
>>> - The "removable" property should never have been named like that. It
>>>   should have been "offlinable". Can we still rename that? E.g. boot memory
>>>   is sometimes marked as removable ...
>>>
>>
>>
>> Any feedback regarding the suggested block types would be very much
>> appreciated!
> 
> I still do not like this much to be honest. I just didn't get to think
> through this properly. My fear is that this is conflating an actual API
> with the current implementation and as such will cause problems in
> future. But I haven't really looked into your patches closely so I might
> be wrong. Anyway I won't be able to look into it by the end of year.
> 

So I started to think about this again, and I guess somehow exposing an
identification of the device driver that added the memory section could
be sufficient.

E.g. "hyperv", "xen", "acpi", "sclp", "virtio-mem" ...

Via separate device driver interfaces, other information about the
memory could be exposed. (e.g. for ACPI: which memory devices belong to
one physical device). So stuff would not have to centered around
/sys/devices/system/memory/ , uglifying it for special cases.

We would have to write udev rules to deal with these values, should be
easy. If no DRIVER is given, it is simply memory detected and detected
during boot. ACPI changing the DRIVER might be tricky (from no DRIVER ->
ACPI), but I guess it could be done.

Now, the question would be how to get the DRIVER value in there. Adding
a bunch of fake device drivers would work, however this might get a
little messy ... and then there is unbining and rebinding which can be
triggered by userspace. Thinks to care about? Most probably not.

-- 

Thanks,

David / dhildenb

