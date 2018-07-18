Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD006B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:38:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u4-v6so2325388pgr.2
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 10:38:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 62-v6si3904477pfg.224.2018.07.18.10.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 10:38:30 -0700 (PDT)
Subject: Re: [PATCHv5 03/19] mm/ksm: Do not merge pages with different KeyIDs
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-4-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a6fc50f2-b0c2-32db-cbef-3de57d5e6b16@intel.com>
Date: Wed, 18 Jul 2018 10:38:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> Pages encrypted with different encryption keys are not allowed to be
> merged by KSM. Otherwise it would cross security boundary.

Let's say I'm using plain AES (not AES-XTS).  I use the same key in two
keyid slots.  I map a page with the first keyid and another with the
other keyid.

Won't they have the same cipertext?  Why shouldn't we KSM them?
