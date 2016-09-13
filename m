Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 242C36B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:08:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so426905520pfb.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:08:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id vv2si27564556pab.2.2016.09.13.06.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 06:08:48 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8DD4N7p050487
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:08:47 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25e0b24n9h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:08:46 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Tue, 13 Sep 2016 07:08:44 -0600
Subject: Re: [RFC] mm: Change the data type of huge page size from unsigned
 long to u64
References: <1473758765-13673-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <20160913093257.GA31186@node>
 <09ab7941-07fa-0003-46d8-9fa5c07eba2d@linux.vnet.ibm.com>
 <20160913114001.GB31186@node>
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Date: Tue, 13 Sep 2016 21:08:33 +0800
MIME-Version: 1.0
In-Reply-To: <20160913114001.GB31186@node>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <cc71f567-918d-ea01-e262-0a4458b5cfee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gang <chengang@emindsoft.com.cn>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, hejianet@linux.vnet.ibm.com

On 9/13/16 7:40 PM, Kirill A. Shutemov wrote:
> On Tue, Sep 13, 2016 at 07:21:07PM +0800, Rui Teng wrote:
>> On 9/13/16 5:32 PM, Kirill A. Shutemov wrote:
>>> On Tue, Sep 13, 2016 at 05:26:05PM +0800, Rui Teng wrote:
>>>> The huge page size could be 16G(0x400000000) on ppc64 architecture, and it will
>>>> cause an overflow on unsigned long data type(0xFFFFFFFF).
>>>
>>> Huh? ppc64 is 64-bit system and sizeof(void *) is equal to
>>> sizeof(unsigned long) on Linux (LP64 model).
>>>
>>> So where your 0xFFFFFFFF comes from?
>>>
>> The size of unsigned long data type is 4 bytes
>
> No, it's not.
>
Sorry, my fault!
I print the unsigned long with "%ul" instead of "%lu" and got the wrong
result. Sorry!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
