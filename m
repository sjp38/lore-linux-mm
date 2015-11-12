Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D7B0A6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:15:10 -0500 (EST)
Received: by padhx2 with SMTP id hx2so56519345pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:15:10 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id nn10si18094798pbc.131.2015.11.11.23.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 23:15:10 -0800 (PST)
Received: by pasz6 with SMTP id z6so58370510pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:15:09 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V2] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151105085033.GB7614@node.shutemov.name>
Date: Thu, 12 Nov 2015 15:15:01 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <50393110-D4AD-4FAE-B3A6-63C2DE0730CC@gmail.com>
References: <1445855960-28677-1-git-send-email-yalin.wang2010@gmail.com> <20151029003551.GB12018@node.shutemov.name> <563B0F72.5030908@suse.cz> <20151105085033.GB7614@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, Ebru Akagunduz <ebru.akagunduz@gmail.com>, willy@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ok
i will send a V3 patch.
> On Nov 5, 2015, at 16:50, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
> On Thu, Nov 05, 2015 at 09:12:34AM +0100, Vlastimil Babka wrote:
>> On 10/29/2015 01:35 AM, Kirill A. Shutemov wrote:
>>>> @@ -2605,9 +2603,9 @@ out_unmap:
>>>> 		/* collapse_huge_page will return with the mmap_sem =
released */
>>>> 		collapse_huge_page(mm, address, hpage, vma, node);
>>>> 	}
>>>> -out:
>>>> -	trace_mm_khugepaged_scan_pmd(mm, page_to_pfn(page), writable, =
referenced,
>>>> -				     none_or_zero, result, unmapped);
>>>> +	trace_mm_khugepaged_scan_pmd(mm, pte_present(pteval) ?
>>>> +			pte_pfn(pteval) : -1, writable, referenced,
>>>> +			none_or_zero, result, unmapped);
>>>=20
>>> maybe passing down pte instead of pfn?
>>=20
>> Maybe just pass the page, and have tracepoint's fast assign check for =
!NULL and
>> do page_to_pfn itself? That way the complexity and overhead is only =
in the
>> tracepoint and when enabled.
>=20
> Agreed.
>=20
> --=20
> Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
