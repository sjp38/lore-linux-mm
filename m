Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E13D6B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:32:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v25-v6so3615667pfm.11
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:32:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b5-v6sor1799275ple.5.2018.07.19.00.32.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 00:32:47 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:32:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 03/19] mm/ksm: Do not merge pages with different KeyIDs
Message-ID: <20180719073240.autom4g4cdm3jgd6@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-4-kirill.shutemov@linux.intel.com>
 <a6fc50f2-b0c2-32db-cbef-3de57d5e6b16@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6fc50f2-b0c2-32db-cbef-3de57d5e6b16@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 10:38:27AM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > Pages encrypted with different encryption keys are not allowed to be
> > merged by KSM. Otherwise it would cross security boundary.
> 
> Let's say I'm using plain AES (not AES-XTS).  I use the same key in two
> keyid slots.  I map a page with the first keyid and another with the
> other keyid.
> 
> Won't they have the same cipertext?  Why shouldn't we KSM them?

We compare plain text, not ciphertext. And for good reason.

Comparing ciphertext would only make KSM successful for AES-ECB that
doesn't dependent on physical address of the page.

MKTME only supports AES-XTS (no plans to support AES-ECB). It effectively
disables KSM if we go with comparing ciphertext.

-- 
 Kirill A. Shutemov
