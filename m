From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
Date: Fri, 1 Jul 2016 18:46:56 +0200
Message-ID: <20160701164656.GG4593@pd.tnic>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001210.AA77B917@viggo.jf.intel.com>
 <20160701092300.GD4593@pd.tnic>
 <CALCETrV+uq4fcgmUK_u6_Tu6Ex3FrYM0fQjDbjwy5KZ8f8OuHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrV+uq4fcgmUK_u6_Tu6Ex3FrYM0fQjDbjwy5KZ8f8OuHg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Michal Hocko <mhocko@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave@sr71.net>
List-Id: linux-mm.kvack.org

On Fri, Jul 01, 2016 at 09:30:37AM -0700, Andy Lutomirski wrote:
> I put the ifdef there to prevent anyone from accidentally using it in
> a 64-bit code path, not to save a bit.  We could put in the middle of
> the list to make the mistake much less likely to be repeated, I
> suppose.

Well, if someone does, someone will notice pretty soon, no?

I just don't see the reason to worry but maybe I'm missing it.

And we can call it X86_BUG_ESPFIX_X86_32 or so too...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
