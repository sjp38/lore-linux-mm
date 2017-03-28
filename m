Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D381A6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 18:47:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x124so1544717wmf.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 15:47:23 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id r128si4916970wmf.16.2017.03.28.15.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 15:47:22 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id u132so2138743wmg.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 15:47:22 -0700 (PDT)
Date: Wed, 29 Mar 2017 01:47:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/8] x86/mm: Define virtual memory map for 5-level paging
Message-ID: <20170328224720.7ir7godugb6eqzm5@node.shutemov.name>
References: <20170327162925.16092-1-kirill.shutemov@linux.intel.com>
 <20170327162925.16092-4-kirill.shutemov@linux.intel.com>
 <1ae86ad3-deae-1b27-d7a9-ea6b20edc039@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ae86ad3-deae-1b27-d7a9-ea6b20edc039@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 28, 2017 at 03:21:39PM -0700, H. Peter Anvin wrote:
> On 03/27/17 09:29, Kirill A. Shutemov wrote:
> > +fffe000000000000 - fffe007fffffffff (=39 bits) %esp fixup stacks
> 
> Why move this?

You're right. There's no reason to.

It's accident due to ESPFIX_BASE_ADDR being defined using PGDIR_SHIFT.
We should use P4D_SHIFT instead to produce consistent result across
paging modes.

I'll update the patch tomorrow. Thanks for noticing this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
