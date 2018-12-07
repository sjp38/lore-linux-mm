Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 806F48E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 06:47:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q64so3084507pfa.18
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 03:47:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor4849660pgq.18.2018.12.07.03.47.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 03:47:15 -0800 (PST)
Date: Fri, 7 Dec 2018 14:47:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 12/13] keys/mktme: Save MKTME data if kernel cmdline
 parameter allows
Message-ID: <20181207114709.kmrbghihyrht2l65@kshutemo-mobl1>
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
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Fri, Dec 07, 2018 at 02:14:03AM +0000, Huang, Kai wrote:
> Alternatively, we can choose to use per-socket keyID, but not to program
> keyID globally across all sockets, so you don't have to save key while
> still supporting CPU hotplug.

Per-socket KeyID approach would make things more complex. For instance
KeyID on its own will not be enough to refer a key. You will need a node
too. It will also require a way to track whether theirs an KeyID on other
node for the key.

It also makes memory management less flexible: runtime migration of the
memory between nodes will be limited and it can hurt memory availablity
for non-encrypted tasks too.

In general, I don't see per-socket KeyID handling very attractive. It
creates more problems than solves.

-- 
 Kirill A. Shutemov
