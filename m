Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06FC16B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:30:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so14320485wrd.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:30:10 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id a25si6646937eda.16.2017.08.14.07.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 07:30:09 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id q189so14725962wmd.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:30:09 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:30:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/14] Boot-time switching between 4- and 5-level paging
Message-ID: <20170814143007.oowwgfkhrppa25hk@node.shutemov.name>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 08, 2017 at 03:54:01PM +0300, Kirill A. Shutemov wrote:
> The basic idea is to implement the same logic as pgtable-nop4d.h provides,
> but at runtime.
> 
> Runtime folding is only implemented for CONFIG_X86_5LEVEL=y case. With the
> option disabled, we do compile-time folding as before..
> 
> Initially, I tried to fold pgd instread. I've got to shell, but it
> required a lot of hacks as kernel threats pgd in a special way.
> 
> Please review and consider applying.

Ingo, any feedback on this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
