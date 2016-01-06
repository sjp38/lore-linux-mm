Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4016B0006
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:48:32 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id ik10so37049998igb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:48:32 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id o67si16554382ioi.5.2016.01.06.09.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 09:48:31 -0800 (PST)
Received: by mail-ig0-x232.google.com with SMTP id z14so15678354igp.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:48:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160106173515.GA25980@agluck-desk.sc.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
	<20160106123346.GC19507@pd.tnic>
	<20160106173515.GA25980@agluck-desk.sc.intel.com>
Date: Wed, 6 Jan 2016 09:48:31 -0800
Message-ID: <CA+55aFx7_sP_R+n6c3Ew=KVcwJwwgXhB57pSG9Kh24oiAqd+vw@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, the arch/x86 maintainers <x86@kernel.org>

On Wed, Jan 6, 2016 at 9:35 AM, Luck, Tony <tony.luck@intel.com> wrote:
>
> Linus, Peter, Ingo, Thomas: Can we head this direction? The code is cleaner
> and more flexible. Or should we stick with Andy's clever way to squeeze a
> couple of "class" bits into the fixup field of the exception table?

I'd rather not be clever in order to save just a tiny amount of space
in the exception table, which isn't really criticial for anybody.

So I think Borislav's patch has the advantage of being pretty
straightforward and allowing arbitrary fixups, in case we end up
having localized special cases..

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
