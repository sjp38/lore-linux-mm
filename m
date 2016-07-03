From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
Date: Sun, 3 Jul 2016 20:44:18 +0200
Message-ID: <20160703184418.GC1781@pd.tnic>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001210.AA77B917@viggo.jf.intel.com>
 <20160701092300.GD4593@pd.tnic>
 <CALCETrV+uq4fcgmUK_u6_Tu6Ex3FrYM0fQjDbjwy5KZ8f8OuHg@mail.gmail.com>
 <20160701164656.GG4593@pd.tnic>
 <CALCETrXXTijS0pbd2n9Rh_1AMsaerbGxC06mDmXoYm8rCDKpvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXXTijS0pbd2n9Rh_1AMsaerbGxC06mDmXoYm8rCDKpvg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable <stable@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave@sr71.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>
List-Id: linux-mm.kvack.org

On Sun, Jul 03, 2016 at 07:36:30AM -0700, Andy Lutomirski wrote:
> Dunno.  ESPFIX was broken under KVM for years and no one notices.

Ah, so this really was the case already. :-\

> We could do that, too, I guess.  But the current solution is only two
> extra lines of code.  We could reorder the things so that it's in the
> middle instead of at the end, I suppose.

Yeah, sounds good. Especially if it was already broken - I missed that
fact.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
