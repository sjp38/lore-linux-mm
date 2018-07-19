Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19B8B6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 14:41:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q12-v6so4202220pgp.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:41:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id ce14-v6si6500851plb.391.2018.07.19.11.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 11:41:11 -0700 (PDT)
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for
 ZONE_DEVICE
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
 <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
 <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
 <20180717155006.GL7193@dhcp22.suse.cz>
 <CAA9_cmez_vrjBYvcpXT_5ziQ2CqRFzPbEWMO2kdmjW0rWhkaCA@mail.gmail.com>
 <20180718120529.GY7193@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3f43729d-fd4e-a488-e04d-026ef5a28dd9@intel.com>
Date: Thu, 19 Jul 2018 11:41:10 -0700
MIME-Version: 1.0
In-Reply-To: <20180718120529.GY7193@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>
Cc: pasha.tatashin@oracle.com, dalias@libc.org, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Matthew Wilcox <willy@infradead.org>, daniel.m.jordan@oracle.com, Ingo Molnar <mingo@redhat.com>, fenghua.yu@intel.com, Jerome Glisse <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On 07/18/2018 05:05 AM, Michal Hocko wrote:
> On Tue 17-07-18 10:32:32, Dan Williams wrote:
>> On Tue, Jul 17, 2018 at 8:50 AM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>>> Is there any reason that this work has to target the next merge window?
>>> The changelog is not really specific about that.
>>
>> Same reason as any other change in this space, hardware availability
>> continues to increase. These patches are a direct response to end user
>> reports of unacceptable init latency with current kernels.
> 
> Do you have any reference please?

Are you looking for the actual end-user reports?  This was more of a
case of the customer plugging in some persistent memory DIMMs, noticing
the boot delta and calling the folks who sold them the DIMMs (Intel).
We can get you more details if you'd like but there are no public
reports that we can share.

>>> There no numbers or
>>> anything that would make this sound as a high priority stuff.
>>
>> >From the end of the cover letter:
>>
>> "With this change an 8 socket system was observed to initialize pmem
>> namespaces in ~4 seconds whereas it was previously taking ~4 minutes."
> 
> Well, yeah, it sounds like a nice to have thing to me. 4 minutes doesn't
> sounds excesive for a single init time operation. Machines are booting
> tens of minutes these days...

It was excessive enough for the customer to complain. :)
