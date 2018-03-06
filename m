Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEA2A6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:56:10 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w22-v6so2201383pll.2
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:56:10 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s6-v6si11285692plq.382.2018.03.06.06.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 06:56:09 -0800 (PST)
Subject: Re: [RFC, PATCH 21/22] x86/mm: Introduce page_keyid() and
 page_encrypted()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
 <61041640-435e-1a67-177f-a75791130514@intel.com>
 <20180306085751.tvozsfe6hogh37pd@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <91d27559-3f28-d53c-9fd9-d16e015a3f59@intel.com>
Date: Tue, 6 Mar 2018 06:56:08 -0800
MIME-Version: 1.0
In-Reply-To: <20180306085751.tvozsfe6hogh37pd@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2018 12:57 AM, Kirill A. Shutemov wrote:
> On Mon, Mar 05, 2018 at 09:08:53AM -0800, Dave Hansen wrote:
>> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
>>> +static inline bool page_encrypted(struct page *page)
>>> +{
>>> +	/* All pages with non-zero KeyID are encrypted */
>>> +	return page_keyid(page) != 0;
>>> +}
>>
>> Is this true?  I thought there was a KEYID_NO_ENCRYPT "Do not encrypt
>> memory when this KeyID is in use."  Is that really only limited to key 0.
> 
> Well, it depends on what we mean by "encrypted". For memory management
> pruposes we care if the page is encrypted with KeyID different from
> default one. All pages with non-default KeyID threated the same by memory
> management.

Doesn't it really mean "am I able to use the direct map to get this
page's contents?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
