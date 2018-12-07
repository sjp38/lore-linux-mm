Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA4916B7E05
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 22:39:50 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so2152791pfq.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 19:39:50 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l17si669762pfd.236.2018.12.06.19.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 19:39:49 -0800 (PST)
Date: Thu, 6 Dec 2018 19:42:17 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 12/13] keys/mktme: Save MKTME data if kernel cmdline
 parameter allows
Message-ID: <20181207034217.GA13388@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c2668d6d260bff3c88440ad097eb1445ea005860.1543903910.git.alison.schofield@intel.com>
 <1544148839.28511.28.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1544148839.28511.28.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "dhowells@redhat.com" <dhowells@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Thu, Dec 06, 2018 at 06:14:03PM -0800, Huang, Kai wrote:
> On Mon, 2018-12-03 at 23:39 -0800, Alison Schofield wrote:

8< ------------

> >    Add an 'mktme_vault' where key data is stored.
> > 
> >    Add 'mktme_savekeys' kernel command line parameter that directs
> >    what key data can be stored. If it is not set, kernel does not
> >    store users data key or tweak key.
> > 
> >    Add 'mktme_bitmap_user_type' to track when USER type keys are in
> >    use. If no USER type keys are currently in use, a physical package
> >    may be brought online, despite the absence of 'mktme_savekeys'.
> 
> Overall, I am not sure whether saving key is good idea, since it breaks coldboot attack IMHO. We
> need to tradeoff between supporting CPU hotplug and security. I am not sure whether supporting CPU
> hotplug is that important, since for some other features such as SGX, we don't support CPU hotplug
> anyway.

Yes, saving the key data exposes it in a cold boot attack.

Here we have 2 conflicting requirements. Do not save the data and
support CPU hotplug. I don't think CPU hotplug support is budging!
If the risk of offering the mktme_savekeys option is too dangerous,
then we can't have user type keys.
Is mktme_savekeys options too risky to offer?
(That's not just a question for you Kai ;). I'll pursue too.)
> 
> Alternatively, we can choose to use per-socket keyID, but not to program keyID globally across all
> sockets, so you don't have to save key while still supporting CPU hotplug.

An alternative, with a lot of impact to the core linux support for
MKTME.  I don't think we need to go there. I'll leave this thought for
a Kirill or Dave to perhaps elaborate on. 

Alison 
> 
> Thanks,
> -Kai
