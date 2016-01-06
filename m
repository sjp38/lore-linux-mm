From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Wed, 6 Jan 2016 18:59:49 +0100
Message-ID: <20160106175948.GA16647@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Wed, Jan 06, 2016 at 09:54:19AM -0800, Andy Lutomirski wrote:
> I assume that this zero is to save the couple of bytes for the
> relocation entry on relocatable kernels?

I didn't want to touch all _ASM_EXTABLE() macro invocations by adding a
third param @handler which is redundant as we know which it is.

> > +       new_ip  = ex_fixup_addr(e);
> > +       handler = ex_fixup_handler(e);
> > +
> > +       if (!handler)
> > +               handler = ex_handler_default;
> 
> the !handler condition here will never trigger because the offset was
> already applied.

Actually, if I do "0 - .", that would overflow the int because current
location is virtual address and that's 64-bit. Or would gas simply
truncate it? Lemme check...

Anyway, what we should do instead is simply

	.long 0

to denote that the @handler is implicit.

Right?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
