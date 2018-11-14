Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDD516B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:54:00 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id s3so10846764otb.0
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:54:00 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b5si9855443otd.10.2018.11.14.00.53.59
        for <linux-mm@kvack.org>;
        Wed, 14 Nov 2018 00:53:59 -0800 (PST)
Subject: Re: [RFC][PATCH v1 02/11] mm: soft-offline: add missing error check
 of set_hwpoison_free_buddy_page()
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <9ea93154-4843-231d-d72b-bf12c8807c24@arm.com>
 <20181113001652.GA5945@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ffbc7a7e-58c3-742c-2bae-8cd4cf1e6aa8@arm.com>
Date: Wed, 14 Nov 2018 14:23:52 +0530
MIME-Version: 1.0
In-Reply-To: <20181113001652.GA5945@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/13/2018 05:46 AM, Naoya Horiguchi wrote:
> Hi Anshuman,
> 
> On Fri, Nov 09, 2018 at 03:50:41PM +0530, Anshuman Khandual wrote:
>>
>> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
>>> set_hwpoison_free_buddy_page() could fail, then the target page is
>>> finally not isolated, so it's better to report -EBUSY for userspace
>>> to know the failure and chance of retry.
>>>
>> IIUC set_hwpoison_free_buddy_page() could only fail if the page is not
>> free in the buddy. At least for soft_offline_huge_page() that wont be
>> the case otherwise dissolve_free_huge_page() would have returned non
>> zero -EBUSY. Is there any other reason set_hwpoison_free_buddy_page()
>> would not succeed ?
> There is a race window between page freeing (after successful soft-offline
> -> page migration case) and the containment by set_hwpoison_free_buddy_page().
> Or a target page can be allocated just after get_any_page() decided that
> the target page is a free page.
> So set_hwpoison_free_buddy_page() would safely fail in such cases.

Makes sense. Thanks.
