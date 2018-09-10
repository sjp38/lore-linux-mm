Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A16F8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 15:06:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b8-v6so28548206oib.4
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 12:06:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h189-v6sor16405450oif.19.2018.09.10.12.06.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 12:06:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180724072937.GD28386@dhcp22.suse.cz>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
 <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
 <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
 <20180717155006.GL7193@dhcp22.suse.cz> <CAA9_cmez_vrjBYvcpXT_5ziQ2CqRFzPbEWMO2kdmjW0rWhkaCA@mail.gmail.com>
 <20180718120529.GY7193@dhcp22.suse.cz> <3f43729d-fd4e-a488-e04d-026ef5a28dd9@intel.com>
 <20180723110928.GC31229@dhcp22.suse.cz> <510a1213-e391-bad6-4239-60fa477aaac0@intel.com>
 <20180724072937.GD28386@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 10 Sep 2018 12:06:04 -0700
Message-ID: <CAPcyv4hZUgoMvUTcQLVQWvpvHnJYoPaet4b2VE-qPLtUPDgSaQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Rich Felker <dalias@libc.org>, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Alexander Duyck <alexander.h.duyck@intel.com>

[ adding Alex ]

On Tue, Jul 24, 2018 at 12:29 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 23-07-18 09:15:32, Dave Hansen wrote:
>> On 07/23/2018 04:09 AM, Michal Hocko wrote:
>> > On Thu 19-07-18 11:41:10, Dave Hansen wrote:
>> >> Are you looking for the actual end-user reports?  This was more of a
>> >> case of the customer plugging in some persistent memory DIMMs, noticing
>> >> the boot delta and calling the folks who sold them the DIMMs (Intel).
>> > But this doesn't sound like something to rush a solution for in the
>> > upcoming merge windown, does it?
>>
>> No, we should not rush it.  We'll try to rework it properly.
>
> Thanks a lot Dave! I definitely do not mean to block this at all. I just
> really do not like to have the code even more cluttered than we have
> now.

Hi Michal,

I'm back from vacation. I owe you an apology I was entirely too
prickly on this thread, and the vacation cool-off-time was much
needed.

I come back to see that Alex has found a trove of low hanging fruit to
speed up ZONE_DEVICE init and ditch most of the complication I was
pushing. I'll let him chime in on the direction he wants to take this.
