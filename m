Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004E56B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 18:26:11 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k188so1090806itd.11
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 15:26:10 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id d124si5798059ioe.237.2017.03.28.15.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 15:26:10 -0700 (PDT)
Subject: Re: [PATCH 3/8] x86/mm: Define virtual memory map for 5-level paging
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-4-kirill.shutemov@linux.intel.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <1ae86ad3-deae-1b27-d7a9-ea6b20edc039@zytor.com>
Date: Tue, 28 Mar 2017 15:21:39 -0700
MIME-Version: 1.0
In-Reply-To: <20170327162925.16092-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/27/17 09:29, Kirill A. Shutemov wrote:
> +fffe000000000000 - fffe007fffffffff (=39 bits) %esp fixup stacks

Why move this?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
