Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84B926B0006
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 10:11:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h12-v6so1554826wrq.2
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 07:11:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f23-v6si4087790edd.346.2018.06.05.07.11.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 07:11:06 -0700 (PDT)
Date: Tue, 5 Jun 2018 16:11:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Message-ID: <20180605141104.GF19202@dhcp22.suse.cz>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604124031.GP19202@dhcp22.suse.cz>
 <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon 04-06-18 07:31:25, Dan Williams wrote:
[...]
> I'm trying to solve this real world problem when real poison is
> consumed through a dax mapping:
> 
>         mce: Uncorrected hardware memory error in user-access at af34214200
>         {1}[Hardware Error]: It has been corrected by h/w and requires
> no further action
>         mce: [Hardware Error]: Machine check events logged
>         {1}[Hardware Error]: event severity: corrected
>         Memory failure: 0xaf34214: reserved kernel page still
> referenced by 1 users
>         [..]
>         Memory failure: 0xaf34214: recovery action for reserved kernel
> page: Failed
>         mce: Memory error not recovered
> 
> ...i.e. currently all poison consumed through dax mappings is
> needlessly system fatal.

Thanks. That should be a part of the changelog. It would be great to
describe why this cannot be simply handled by hwpoison code without any
ZONE_DEVICE specific hacks? The error is recoverable so why does
hwpoison code even care?

-- 
Michal Hocko
SUSE Labs
