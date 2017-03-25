From: Borislav Petkov <bp@alien8.de>
Subject: Re: Splat during resume
Date: Sat, 25 Mar 2017 23:39:27 +0100
Message-ID: <20170325223927.u5hxyufjq6wufsp6@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic>
 <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
 <20170325215012.v5vywew7pfi3qk5f@pd.tnic>
 <CA+55aFz+23dAey7FnSF3pRNSydEZEe59RUmhO_a=dqZdGm-sEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFz+23dAey7FnSF3pRNSydEZEe59RUmhO_a=dqZdGm-sEg@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, x86-ml <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Sat, Mar 25, 2017 at 03:05:41PM -0700, Linus Torvalds wrote:
> I think this is the same as the kexec issue that also hit -tip.
> 
> It's *probably* fixed by the final series to actually enable 5-level
> paging (which I don't think is in -tip yet), but even if that is the
> case this is obviously a nasty bisectability problem.

It being -tip only for now, I'm guessing that can still be addressed...?

> You migth want to verify, though. The second batch starts here:
> 
>   https://marc.info/?l=linux-mm&m=148977696117208&w=2
> 
> Hmm?
> 
> In the meantime, this is currently -tip only, so I will stack back
> from this thread unless you can reproduce it in mainline too.

I could try mainline, just in case and if you want me to but

* considering the patch which broke this is in tip only and
* after git-am'ing the 6 part-2 patches you and Kirill pointed me at, the resume issue is fixed,

it probably is not really needed.

Thanks guys.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
