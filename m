Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 72C1D6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 18:03:08 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id b14so4324981wmb.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 15:03:08 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 3si1226751wmi.103.2016.01.04.15.03.06
        for <linux-mm@kvack.org>;
        Mon, 04 Jan 2016 15:03:06 -0800 (PST)
Date: Tue, 5 Jan 2016 00:02:46 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a
 bit)
Message-ID: <20160104230246.GU22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com>
 <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic>
 <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
 <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
 <20160104210228.GR22941@pd.tnic>
 <CALCETrVOF9P3YFKMeShp0FYX15cqppkWhhiOBi6pxfu6k+XDmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrVOF9P3YFKMeShp0FYX15cqppkWhhiOBi6pxfu6k+XDmA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@gmail.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 04, 2016 at 02:29:09PM -0800, Andy Lutomirski wrote:
> Josh will argue with you if he sees that :)

Except Josh doesn't need allyesconfigs. tinyconfig's __ex_table is 2K.

> We could maybe come up with a way to compress the table and get that
> space and more back, but maybe that should be a follow-up that someone
> else can do if they're inspired.

Yeah, one needs to look after ones' TODO list. :-)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
