Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07E006B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 10:04:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id k17so1993374pfj.10
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 07:04:16 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x6-v6si11180349pln.708.2018.03.06.07.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 07:04:15 -0800 (PST)
Subject: Re: [RFC, PATCH 21/22] x86/mm: Introduce page_keyid() and
 page_encrypted()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
 <61041640-435e-1a67-177f-a75791130514@intel.com>
 <20180306085751.tvozsfe6hogh37pd@node.shutemov.name>
 <91d27559-3f28-d53c-9fd9-d16e015a3f59@intel.com>
 <20180306145806.ejg5kzaqqmncgqi7@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <945b233a-e596-6426-b51d-f9a3ab2be94b@intel.com>
Date: Tue, 6 Mar 2018 07:04:13 -0800
MIME-Version: 1.0
In-Reply-To: <20180306145806.ejg5kzaqqmncgqi7@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2018 06:58 AM, Kirill A. Shutemov wrote:
>> Doesn't it really mean "am I able to use the direct map to get this
>> page's contents?"
> Yes.
> 
> Any proposal for better helper name?

Let's see how it gets used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
