Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC9A6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:58:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e19-v6so3678501pgv.11
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:58:45 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k13-v6si6215700pgh.213.2018.07.19.06.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:58:44 -0700 (PDT)
Subject: Re: [PATCHv5 02/19] mm: Do not use zero page in encrypted pages
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-3-kirill.shutemov@linux.intel.com>
 <e09c67ab-38a7-5b76-29e6-a45627eec1e5@intel.com>
 <20180719071606.dkeq5btz5wlzk4oq@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d50d89d2-f93b-4b4b-bf8d-2f53cedebcd1@intel.com>
Date: Thu, 19 Jul 2018 06:58:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180719071606.dkeq5btz5wlzk4oq@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/19/2018 12:16 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 10:36:24AM -0700, Dave Hansen wrote:
>> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
>>> Zero page is not encrypted and putting it into encrypted VMA produces
>>> garbage.
>>>
>>> We can map zero page with KeyID-0 into an encrypted VMA, but this would
>>> be violation security boundary between encryption domains.
>> Why?  How is it a violation?
>>
>> It only matters if they write secrets.  They can't write secrets to the
>> zero page.
> I believe usage of zero page is wrong here. It would indirectly reveal
> content of supposedly encrypted memory region.
> 
> I can see argument why it should be okay and I don't have very strong
> opinion on this.

I think we should make the zero page work.  If folks are
security-sensitive, they need to write to guarantee it isn't being
shared.  That's a pretty low bar.

I'm struggling to think of a case where an attacker has access to the
encrypted data, the virt->phys mapping, *and* can glean something
valuable from the presence of the zero page.

Please spend some time and focus on your patch descriptions.  Use facts
that are backed up and are *precise* or tell the story of how your patch
was developed.  In this case, citing the "security boundary" is not
precise enough without explaining what the boundary is and how it is
violated.
