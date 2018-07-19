Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C55006B0266
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:02:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g11-v6so3724382pgs.13
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 07:02:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u11-v6si6646369plm.143.2018.07.19.07.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 07:02:43 -0700 (PDT)
Subject: Re: [PATCHv5 03/19] mm/ksm: Do not merge pages with different KeyIDs
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-4-kirill.shutemov@linux.intel.com>
 <a6fc50f2-b0c2-32db-cbef-3de57d5e6b16@intel.com>
 <20180719073240.autom4g4cdm3jgd6@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3045c925-f5a8-ae68-8f77-4cddaf040f9f@intel.com>
Date: Thu, 19 Jul 2018 07:02:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180719073240.autom4g4cdm3jgd6@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/19/2018 12:32 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 10:38:27AM -0700, Dave Hansen wrote:
>> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
>>> Pages encrypted with different encryption keys are not allowed to be
>>> merged by KSM. Otherwise it would cross security boundary.
>> Let's say I'm using plain AES (not AES-XTS).  I use the same key in two
>> keyid slots.  I map a page with the first keyid and another with the
>> other keyid.
>>
>> Won't they have the same cipertext?  Why shouldn't we KSM them?
> We compare plain text, not ciphertext. And for good reason.

What's the reason?  Probably good to talk about it for those playing
along at home.

> Comparing ciphertext would only make KSM successful for AES-ECB that
> doesn't dependent on physical address of the page.
> 
> MKTME only supports AES-XTS (no plans to support AES-ECB). It effectively
> disables KSM if we go with comparing ciphertext.

But what's the security boundary that is violated?  You are talking
about some practical concerns (KSM scanning inefficiency) which is a far
cry from being any kind of security issue.
