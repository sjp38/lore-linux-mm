Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAABD8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 10:31:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so12500220pgs.15
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 07:31:18 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w25-v6si19817585pfa.359.2018.09.11.07.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 07:31:17 -0700 (PDT)
Date: Tue, 11 Sep 2018 17:31:09 +0300
From: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
Subject: Re: [RFC 10/12] x86/pconfig: Program memory encryption keys on a
 system-wide basis
Message-ID: <20180911143108.GA9717@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <0947e4ad711e8b7c1f581a446e808f514620b49b.1536356108.git.alison.schofield@intel.com>
 <73c60d4f8a953476f1e29aaccbeb7f732c209190.camel@intel.com>
 <20180911024657.GC1732@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180911024657.GC1732@alison-desk.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "dhowells@redhat.com" <dhowells@redhat.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Mon, Sep 10, 2018 at 07:46:57PM -0700, Alison Schofield wrote:
> On Mon, Sep 10, 2018 at 11:24:20AM -0700, Sakkinen, Jarkko wrote:
> > On Fri, 2018-09-07 at 15:38 -0700, Alison Schofield wrote:
> > > The kernel manages the MKTME (Multi-Key Total Memory Encryption) Keys
> > > as a system wide single pool of keys. The hardware, however, manages
> > > the keys on a per physical package basis. Each physical package
> > > maintains a key table that all CPU's in that package share.
> > > 
> > > In order to maintain the consistent, system wide view that the kernel
> > > requires, program all physical packages during a key program request.
> > > 
> > > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > 
> > Just kind of checking that are you talking about multiple cores in
> > a single package or really multiple packages?
> 
> System wide pool.
> System has multiple packages.  
> Packages have multiple CPU's.
> 
> The hardware KEY TABLE is per package. I need that per package KEY TABLE
> to be the same in every package across the system. So, I pick one 'lead'
> CPU in each package to program that packages KEY TABLE.
> 
> (BTW - I'm going to look into Kai's suggestion to move the system wide view
> of this key programming into the key service. Not sure if that's a go.)

Thanks. I think could be perhaps a fair addition to the documentation?

/Jarkko
