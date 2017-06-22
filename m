Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF936B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:57:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 24so2298500lfr.10
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 01:57:48 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id z130si479264lfa.91.2017.06.22.01.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 01:57:46 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id h22so5862443lfk.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 01:57:46 -0700 (PDT)
Date: Thu, 22 Jun 2017 11:57:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 00/14] x86: 5-level paging enabling for v4.13, Part 4
Message-ID: <20170622085744.wetigtzctyzukbs5@node.shutemov.name>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 06, 2017 at 02:31:19PM +0300, Kirill A. Shutemov wrote:
> Please review and consider applying.

Hi Ingo,

I've noticed you haven't applied last two patches of the patchset.

Is there any problem with them? Or what is you plan here?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
