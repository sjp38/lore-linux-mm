Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE5296B7F05
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 20:12:01 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d23so3937467plj.22
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 17:12:01 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id k16si4137421pls.124.2018.12.07.17.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 17:12:00 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
 <1544147742.28511.18.camel@intel.com>
 <CALCETrWHqE-H1jTJY-ApuuLt5cyZ3N1UdgH+szgYm+7mUMZ2pg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5862ff39-e4ab-2a04-95be-84d2e8b67120@intel.com>
Date: Fri, 7 Dec 2018 17:11:58 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrWHqE-H1jTJY-ApuuLt5cyZ3N1UdgH+szgYm+7mUMZ2pg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, kai.huang@intel.com
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, James Morris <jmorris@namei.org>, Peter Zijlstra <peterz@infradead.org>, keyrings@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, LSM List <linux-security-module@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, Borislav Petkov <bp@alien8.de>, Alison Schofield <alison.schofield@intel.com>, Jun Nakajima <jun.nakajima@intel.com>

On 12/7/18 3:53 PM, Andy Lutomirski wrote:
> The third problem is the real show-stopper, though: this scheme
> requires that the ciphertext go into predetermined physical
> addresses, which would be a giant mess.

There's a more fundamental problem than that.  The tweak fed into the
actual AES-XTS operation is determined by the firmware, programmed into
the memory controller, and is not visible to software.  So, not only
would you need to put stuff at a fixed physical address, the tweaks can
change from boot-to-boot, so whatever you did would only be good for one
boot.
