Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7301B6B000C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:07:57 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so8490351plv.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:07:57 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j2si8707724pgp.759.2018.03.05.11.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:07:56 -0800 (PST)
Subject: Re: [RFC, PATCH 18/22] x86/mm: Handle allocation of encrypted pages
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6551765a-5926-8445-d867-8f7c6bf343b4@intel.com>
Date: Mon, 5 Mar 2018 11:07:55 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-19-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> kmap_atomic_keyid() would map the page with the specified KeyID.
> For now it's dummy implementation that would be replaced later.

I think you need to explain the tradeoffs here.  We could just change
the linear map around, but you don't.  Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
