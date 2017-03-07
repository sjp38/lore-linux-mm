Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69D026B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:41:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so225788662pgc.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:41:19 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id m24si20574729pfa.104.2017.03.06.16.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Mar 2017 16:41:18 -0800 (PST)
Date: Tue, 7 Mar 2017 11:41:15 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCHv4 00/33] 5-level paging
Message-ID: <20170307114115.768312f4@canb.auug.org.au>
In-Reply-To: <alpine.DEB.2.20.1703061935220.3771@nanos>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
	<CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
	<alpine.DEB.2.20.1703061935220.3771@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Thomas,

On Mon, 6 Mar 2017 19:42:05 +0100 (CET) Thomas Gleixner <tglx@linutronix.de> wrote:
>
> We probably need to split it apart:
> 
>    - Apply the mm core only parts to a branch which can be pulled into
>      Andrews mm-tree

Andrew's mm-tree is not a git tree it is a quilt series ...

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
