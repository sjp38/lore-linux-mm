Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA3C56B0390
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:06:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y51so51850811wry.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:06:28 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id p43si5822395wrb.39.2017.03.14.10.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 10:06:27 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id l37so24623525wrc.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:06:27 -0700 (PDT)
Date: Tue, 14 Mar 2017 20:06:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2,6/7] mm: convert generic code to 5-level paging
Message-ID: <20170314170625.gwlfjlxooij3elsd@node.shutemov.name>
References: <20170309142408.2868-7-kirill.shutemov@linux.intel.com>
 <2565467.lozgIVsiVn@diego>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2565467.lozgIVsiVn@diego>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko =?iso-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Mar 14, 2017 at 05:14:22PM +0100, Heiko Stubner wrote:
> [added arm64 maintainers and arm list to recipients]
> 
> Hi,
> 
> Am Donnerstag, 9. Marz 2017, 17:24:07 CET schrieb Kirill A. Shutemov:
> > Convert all non-architecture-specific code to 5-level paging.
> > 
> > It's mostly mechanical adding handling one more page table level in
> > places where we deal with pud_t.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> This breaks (at least) arm64 Rockchip platforms it seems.
> 
> 4.11-rc1 worked just fine, while 4.11-rc2 kills the systems and I've bisected 
> it down to this one commit.

Have you tried current Linus' tree? There is important fix:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ce70df089143c49385b4f32f39d41fb50fbf6a7c

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
