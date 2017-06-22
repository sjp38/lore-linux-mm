Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14F186B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:04:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z1so2764383wrz.10
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:04:28 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id t18si933754wrb.195.2017.06.22.02.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 02:04:26 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id k67so2983889wrc.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:04:26 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:04:22 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 00/14] x86: 5-level paging enabling for v4.13, Part 4
Message-ID: <20170622090422.wbbaw6pm457i7cbr@gmail.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
 <20170622085744.wetigtzctyzukbs5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622085744.wetigtzctyzukbs5@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Jun 06, 2017 at 02:31:19PM +0300, Kirill A. Shutemov wrote:
> > Please review and consider applying.
> 
> Hi Ingo,
> 
> I've noticed you haven't applied last two patches of the patchset.
> 
> Is there any problem with them? Or what is you plan here?

As they change/extend the Linux ABI I still need to think about them some more.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
