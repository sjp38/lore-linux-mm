From: hpa@zytor.com
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Date: Fri, 17 Feb 2017 15:11:52 -0800
Message-ID: <86524164-94F0-44D6-8B1A-6858E23F66B5@zytor.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com> <20170217141328.164563-34-kirill.shutemov@linux.intel.com> <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com> <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com> <CA+55aFxu0p90nz6-VPFLCLBSpEVx7vNFGP_M8j=YS-Dk-zfJGg@mail.gmail.com> <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>
List-Id: linux-mm.kvack.org

On February 17, 2017 3:02:33 PM PST, Andy Lutomirski <luto@amacapital.net> wrote:
>On Fri, Feb 17, 2017 at 1:01 PM, Linus Torvalds
><torvalds@linux-foundation.org> wrote:
>> On Fri, Feb 17, 2017 at 12:12 PM, Andy Lutomirski
><luto@amacapital.net> wrote:
>>>
>>> At the very least, I'd want to see
>>> MAP_FIXED_BUT_DONT_BLOODY_UNMAP_ANYTHING.  I *hate* the current
>>> interface.
>>
>> That's unrelated, but I guess w could add a MAP_NOUNMAP flag, and
>then
>> you can use MAP_FIXED | MAP_NOUNMAP or something.
>>
>> But that has nothing to do with the 47-vs-56 bit issue.
>>
>>> How about MAP_LIMIT where the address passed in is interpreted as an
>>> upper bound instead of a fixed address?
>>
>> Again, that's a unrelated semantic issue. Right now - if you don't
>> pass in MAP_FIXED at all, the "addr" argument is used as a starting
>> value for deciding where to find an unmapped area. But there is no
>way
>> to specify the end. That would basically be what the process control
>> thing would be (not per-system-call, but per-thread ).
>>
>
>What I'm trying to say is: if we're going to do the route of 48-bit
>limit unless a specific mmap call requests otherwise, can we at least
>have an interface that doesn't suck?

Let's not, please.

But we really want this interface anyway.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
