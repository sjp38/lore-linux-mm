Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 16D8B6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 14:51:14 -0400 (EDT)
Received: by wgme6 with SMTP id e6so121953879wgm.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 11:51:13 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id gs3si20177100wib.29.2015.06.01.11.51.10
        for <linux-mm@kvack.org>;
        Mon, 01 Jun 2015 11:51:11 -0700 (PDT)
Date: Mon, 1 Jun 2015 20:51:05 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 4/4] x86/pat: Remove pat_enabled() checks
Message-ID: <20150601185105.GA17187@pd.tnic>
References: <20150531094655.GA20440@pd.tnic>
 <1433065686-20922-1-git-send-email-bp@alien8.de>
 <1433065686-20922-4-git-send-email-bp@alien8.de>
 <1433183189.23540.116.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1433183189.23540.116.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, x86-ml <x86@kernel.org>, yigal@plexistor.com

On Mon, Jun 01, 2015 at 12:26:29PM -0600, Toshi Kani wrote:
> I reviewed the 1/3-3/3 patchset in your "tip-mm-2" branch, which is
> different from this submitted patchset 1/4-4/4. So, my review-by
> applies to the 3 patches in the "tip-mm-2" branch.

That's fine, the 4 patches were broken due to xen using
pat_init_cache_modes() too. So the 3 are the right ones.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
