Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62A6E6B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 12:15:51 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d10-v6so691738pll.22
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 09:15:51 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a16-v6si7936120pgw.389.2018.07.23.09.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 09:15:50 -0700 (PDT)
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for
 ZONE_DEVICE
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
 <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
 <CAGM2reacO1HF91yH8OR5w5AdZwPgwfSFfjDNBsHbP66v1rEg=g@mail.gmail.com>
 <20180717155006.GL7193@dhcp22.suse.cz>
 <CAA9_cmez_vrjBYvcpXT_5ziQ2CqRFzPbEWMO2kdmjW0rWhkaCA@mail.gmail.com>
 <20180718120529.GY7193@dhcp22.suse.cz>
 <3f43729d-fd4e-a488-e04d-026ef5a28dd9@intel.com>
 <20180723110928.GC31229@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <510a1213-e391-bad6-4239-60fa477aaac0@intel.com>
Date: Mon, 23 Jul 2018 09:15:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180723110928.GC31229@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@oracle.com, dalias@libc.org, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Matthew Wilcox <willy@infradead.org>, daniel.m.jordan@oracle.com, Ingo Molnar <mingo@redhat.com>, fenghua.yu@intel.com, Jerome Glisse <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "Luck, Tony" <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On 07/23/2018 04:09 AM, Michal Hocko wrote:
> On Thu 19-07-18 11:41:10, Dave Hansen wrote:
>> Are you looking for the actual end-user reports?  This was more of a
>> case of the customer plugging in some persistent memory DIMMs, noticing
>> the boot delta and calling the folks who sold them the DIMMs (Intel).
> But this doesn't sound like something to rush a solution for in the
> upcoming merge windown, does it?

No, we should not rush it.  We'll try to rework it properly.
