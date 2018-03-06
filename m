Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC96B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 08:52:47 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x6so6270873pfx.16
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 05:52:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c1si9798869pga.513.2018.03.06.05.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 05:52:46 -0800 (PST)
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
 <20180306085412.vkgheeya24dze53t@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <64d11e65-76b7-4e70-553c-009263b50a1c@intel.com>
Date: Tue, 6 Mar 2018 05:52:44 -0800
MIME-Version: 1.0
In-Reply-To: <20180306085412.vkgheeya24dze53t@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/06/2018 12:54 AM, Kirill A. Shutemov wrote:
>> Have you measured how slow this is?
> No, I have not.

It would be handy to do this.  I *think* you can do it on normal
hardware, even if it does not have "real" support for memory encryption.
 Just don't set the encryption bits in the PTEs but go through all the
motions of cache flushing.

I think that will help tell us whether this is a really specialized
thing a la hugetlbfs or whether it's something we really want to support
as a first-class citizen in the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
