Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26FA96B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:34:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g8so17758779wmg.7
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:34:19 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u199si14340512wmu.140.2017.03.14.01.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Mar 2017 01:34:17 -0700 (PDT)
Date: Tue, 14 Mar 2017 09:33:20 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
In-Reply-To: <20170314082409.gjhefteglqbfb2gy@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1703140932310.3619@nanos>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com> <20170314074729.GA23151@gmail.com> <20170314082409.gjhefteglqbfb2gy@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Mar 2017, Kirill A. Shutemov wrote:
> On Tue, Mar 14, 2017 at 08:47:29AM +0100, Ingo Molnar wrote:
> > I've also applied the GUP patch, with the assumption that you'll address Linus's 
> > request to switch x86 over to the generic version.
> 
> Okay, I'll do this.
> 
> I just want to make priorities clear here: is it okay to finish with the
> rest of 5-level paging patches first before moving to GUP_fast switch?

I think moving it first is the preferred way to do it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
