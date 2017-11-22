Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF4C96B026F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:54:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i123so17502969pgd.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:54:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a12si14533633pls.398.2017.11.22.14.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:54:32 -0800 (PST)
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193112.6A962D6A@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711201518490.1734@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <63daa6c0-76de-ee67-6a77-fef601a22943@linux.intel.com>
Date: Wed, 22 Nov 2017 14:54:29 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711201518490.1734@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 09:21 AM, Thomas Gleixner wrote:
>> +page tables are switched to the full "kernel" copy.  When the
>> +system switches back to user mode, the user/shadow copy is used.
>> +
>> +The minimalistic kernel portion of the user page tables try to
>> +map only what is needed to enter/exit the kernel such as the
>> +entry/exit functions themselves and the interrupt descriptor
>> +table (IDT).
> s/try to//

Actually, they do _aspire_ "to map only what is needed".  But, there
*is* some non-necessary cruft (like the first C function in an
interrupt).  So, removing this language actually makes the description
less precise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
