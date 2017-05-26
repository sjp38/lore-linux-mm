Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4EE96B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:23:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e131so23971466pfh.7
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:23:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t64si1737322pfg.350.2017.05.26.12.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 12:23:34 -0700 (PDT)
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level
 paging
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
 <20170526130057.t7zsynihkdtsepkf@node.shutemov.name>
 <CA+55aFw2HDHRZTYss2xbSTRAZuS1qAFmKrAXsiMp34ngNapTiw@mail.gmail.com>
 <83F4880B-5D1F-4576-A9B6-7DDF4173E2E5@zytor.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <40d58ba7-277c-6f4e-a4d7-15425d675dbf@intel.com>
Date: Fri, 26 May 2017 12:23:18 -0700
MIME-Version: 1.0
In-Reply-To: <83F4880B-5D1F-4576-A9B6-7DDF4173E2E5@zytor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 05/26/2017 11:24 AM, hpa@zytor.com wrote:
> The only case where that even has any utility is for an application
> to want more than 128 TiB address space on a machine with no more
> than 64 TiB of RAM.  It is kind of a narrow use case, I think.

Doesn't more address space increase the effectiveness of ASLR?  I
thought KASLR, especially, was limited in its effectiveness because of a
lack of address space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
