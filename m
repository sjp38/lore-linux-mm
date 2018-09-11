Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1958E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:19:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v9-v6so10682015ply.13
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:19:10 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id p15-v6si18598087pgh.281.2018.09.10.17.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:19:09 -0700 (PDT)
Date: Mon, 10 Sep 2018 17:19:42 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
Message-ID: <20180911001942.GC31868@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
 <437f79cf2512f3aef200f7d0bfba4c99a1834eff.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <437f79cf2512f3aef200f7d0bfba4c99a1834eff.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "dhowells@redhat.com" <dhowells@redhat.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Mon, Sep 10, 2018 at 10:32:20AM -0700, Sakkinen, Jarkko wrote:
> On Fri, 2018-09-07 at 15:34 -0700, Alison Schofield wrote:
> > Document the API's used for MKTME on Intel platforms.
> > MKTME: Multi-KEY Total Memory Encryption
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > ---
> >  Documentation/x86/mktme-keys.txt | 153
> > +++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 153 insertions(+)
> >  create mode 100644 Documentation/x86/mktme-keys.txt
> > 
> > diff --git a/Documentation/x86/mktme-keys.txt b/Documentation/x86/mktme-
> > keys.txt
> > new file mode 100644
> > index 000000000000..2dea7acd2a17
> > --- /dev/null
> > +++ b/Documentation/x86/mktme-keys.txt
> > @@ -0,0 +1,153 @@
> > +MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> > +memory encryption on Intel platforms. Whereas TME (Total Memory Encryption)
> > +allows encryption of the entire system memory using a single key, MKTME
> > +allows multiple encryption domains, each having their own key. The main use
> > +case for the feature is virtual machine isolation. The API's introduced here
> > +are intended to offer flexibility to work in a wide range of uses.
> > +
> > +The externally available Intel Architecture Spec:
> > +https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-
> > Memory-Encryption-Spec.pdf
> > +
> > +============================  API Overview  ============================
> > +
> > +There are 2 MKTME specific API's that enable userspace to create and use
> > +the memory encryption keys:
> 
> This is like saying that they are different APIs to do semantically the
> same exact thing. Is that so?

No. 
The API's used to create and use memory encryption keys are described below:

> 
> /Jarkko
