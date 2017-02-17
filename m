From: hpa@zytor.com
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Date: Fri, 17 Feb 2017 13:50:32 -0800
Message-ID: <31716333-7B8E-4D70-815F-6AABBFBA1A00@zytor.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com> <20170217141328.164563-34-kirill.shutemov@linux.intel.com> <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com> <ae493a75-138c-9c01-d4a1-90bcd01d560f@intel.com> <CA+55aFzVWHUNuhTSBKLyLjOd4UQ8s1-RhMWA7oVr=3G5euo7ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8BIT
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzVWHUNuhTSBKLyLjOd4UQ8s1-RhMWA7oVr=3G5euo7ZQ@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>
List-Id: linux-mm.kvack.org

On February 17, 2017 1:10:27 PM PST, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>On Fri, Feb 17, 2017 at 1:04 PM, Dave Hansen <dave.hansen@intel.com>
>wrote:
>>
>> Is this likely to break anything in practice?  Nah.  But it would
>nice
>> to avoid it.
>
>So I go the other way: what *I* would like to avoid is odd code that
>is hard to follow. I'd much rather make the code be simple and the
>rules be straightforward, and not introduce that complicated
>"different address limits" thing at all.
>
>Then, _if_ we ever find a case where it makes a difference, we could
>go the more complex route. But not first implementation, and not
>without a real example of why we shouldn't just keep things simple.
>
>              Linus

However, we already have different address limits for different threads and/or syscall interfaces - 3 GiB (32-bit with legacy flag), 4 GiB (32-bit or x32), or 128 TiB... and for a while we had a 512 GiB option, too.  In that sense an address cap makes sense and generalizes what we already have.

It would be pretty hideous for the user, long term, to be artificially restricted to a legacy address cap unless they manage the address space themselves.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
