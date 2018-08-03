Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA1206B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 12:54:59 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e8-v6so4468636ioq.11
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 09:54:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k197-v6sor2076818ite.54.2018.08.03.09.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 09:54:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180803164337.GB4718@bombadil.infradead.org>
References: <cover.1529507994.git.andreyknvl@google.com> <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <CAAeHK+wJbbCZd+-X=9oeJgsqQJiq8h+Aagz3SQMPaAzCD+pvFw@mail.gmail.com>
 <CAAeHK+yWF05XoU+0iuJoXAL3cWgdtxbeLoBz169yP12W4LkcQw@mail.gmail.com>
 <20180801174256.5mbyf33eszml4nmu@armageddon.cambridge.arm.com>
 <CAAeHK+zb7vcehuX9=oxLUJVJr1ZcgmRTODQz7wsPy+rJb=3kbQ@mail.gmail.com>
 <CAAeHK+xTxPhfbVTNxcbsx7VdwQ21Bt-vo2ZU1tEM1_JX7uKnng@mail.gmail.com>
 <20180803150945.GC9297@kroah.com> <20180803164337.GB4718@bombadil.infradead.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 3 Aug 2018 18:54:57 +0200
Message-ID: <CAAeHK+zqVTOSFD5yZ0E5Z3HZPVn8KYQJMGjBvin8rEfugBdfag@mail.gmail.com>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Aug 3, 2018 at 6:43 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Aug 03, 2018 at 05:09:45PM +0200, Greg Kroah-Hartman wrote:
>> On Fri, Aug 03, 2018 at 04:59:18PM +0200, Andrey Konovalov wrote:
>> > Started looking at this. When I run sparse with default checks enabled
>> > (make C=1) I get countless warnings. Does anybody actually use it?
>>
>> Try using a more up-to-date version of sparse.  Odds are you are using
>> an old one, there is a newer version in a different branch on kernel.org
>> somewhere...
>
> That's not true.  Building the current version of sparse from
> git://git.kernel.org/pub/scm/devel/sparse/sparse.git leaves me with a
> thousand errors just building the mm/ directory.  A sample:

I'm running the one from https://github.com/lucvoo/sparse-dev which
seems to be even more up to date. Defconfig on x86 gives me ~3000
warnings:

https://gist.github.com/xairy/8adace989f64462e18ffb5cb7d096b73
