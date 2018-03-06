Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC6656B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 10:39:50 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b23so10587585oib.16
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 07:39:50 -0800 (PST)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id p205si4316393oia.533.2018.03.06.07.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 07:39:48 -0800 (PST)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id ed7d8832
	for <linux-mm@kvack.org>;
	Tue, 6 Mar 2018 15:21:33 +0000 (UTC)
Received: 
	by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 0f05bdeb (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
	for <linux-mm@kvack.org>;
	Tue, 6 Mar 2018 15:21:31 +0000 (UTC)
Received: by mail-ot0-f178.google.com with SMTP id l5so18697122otf.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 07:39:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de> <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl> <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <20180213085429.GB10278@kroah.com> <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 6 Mar 2018 16:39:43 +0100
Message-ID: <CAHmME9rntZnGBfN_yp5+zBBpXiinFJTU2RkuREa4a5DQGiMB7A@mail.gmail.com>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, WireGuard mailing list <wireguard@lists.zx2c4.com>

Hi Linus,

On Tue, Feb 13, 2018 at 6:25 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> So let's try to fix the iscsi and ipsec issues. Not that anybody sane
> should use that overly complex ipsec thing, and I think we should
> strive to merge WireGuard and get people moved over to that instead,
> but I haven't heard anything from davem about it since I last asked..
> I have some hope that it's slowly happening.

Sorry for missing this comment earlier. We're really quite close to a
point where we can post our v1 patchset. I'm headed on the road this
week, but will be back on the first of April, and I expect that
sometime in the spring we should begin to have the cycles of posting
patches and receiving reviews and getting this into shape for shipping
upstream.

So, fear not, we're still rolling ahead!

Regards,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
