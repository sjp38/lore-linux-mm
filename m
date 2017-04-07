Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCC36B03A5
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:20:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e195so670626wmf.20
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:20:48 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id x15si5508872wme.101.2017.04.07.09.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 09:20:46 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id g19so68748647wrb.0
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:20:46 -0700 (PDT)
Date: Fri, 7 Apr 2017 19:20:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above
 47-bits
Message-ID: <20170407162044.ntn4w6ukpxhi2ei2@node.shutemov.name>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-9-kirill.shutemov@linux.intel.com>
 <8d68093b-670a-7d7e-2216-bf64b19c7a48@linux.vnet.ibm.com>
 <20170407155945.7lyapjbwacg3ikw6@node.shutemov.name>
 <2A1F4E56-9374-4C41-876C-6E6CBD16DB22@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2A1F4E56-9374-4C41-876C-6E6CBD16DB22@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <dsafonov@virtuozzo.com>

On Fri, Apr 07, 2017 at 09:09:27AM -0700, hpa@zytor.com wrote:
> >I think the reasonable way for an application to claim it's 63-bit
> >clean
> >is to make allocations with (void *)-1 as hint address.
> 
> You realize that people have said that about just about every memory

Any better solution?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
