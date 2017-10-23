Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 322BA6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:48:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s66so2033787wmf.14
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:48:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r30sor3379565edb.49.2017.10.23.05.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 05:48:13 -0700 (PDT)
Date: Mon, 23 Oct 2017 15:48:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <20171020081853.lmnvaiydxhy5c63t@gmail.com>
 <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
 <20171020152346.f6tjybt7i5kzbhld@gmail.com>
 <20171020162349.3kwhdgv7qo45w4lh@node.shutemov.name>
 <20171023115658.geccs22o2t733np3@gmail.com>
 <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023124014.mtklgmydspnvfcvg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 23, 2017 at 02:40:14PM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > > Making a variable that 'looks' like a constant macro dynamic in a rare Kconfig 
> > > scenario is asking for trouble.
> > 
> > We expect boot-time page mode switching to be enabled in kernel of next
> > generation enterprise distros. It shoudn't be that rare.
> 
> My point remains even with not-so-rare Kconfig dependency.

I don't follow how introducing new variable that depends on Kconfig option
would help with the situation.

We would end up with inverse situation: people would use MAX_PHYSMEM_BITS
where the new variable need to be used and we will in the same situation.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
