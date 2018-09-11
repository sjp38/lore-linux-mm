Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 377C68E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 19:01:55 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x204-v6so1705qka.6
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:01:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t127-v6si1362511qke.361.2018.09.11.16.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 16:01:54 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20180911223933.GA2638@alison-desk.jf.intel.com>
References: <20180911223933.GA2638@alison-desk.jf.intel.com> <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com> <cover.1536356108.git.alison.schofield@intel.com> <27768.1536703395@warthog.procyon.org.uk>
Subject: Re: [RFC 11/12] keys/mktme: Add a new key service type for memory encryption keys
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <31293.1536706911.1@warthog.procyon.org.uk>
Date: Wed, 12 Sep 2018 00:01:51 +0100
Message-ID: <31294.1536706911@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Alison Schofield <alison.schofield@intel.com> wrote:

> If a preparse routine handles all the above, then if any of the
> above failures occur, the key service has less backing out to do.
> Is that the point?

Yes.  Ideally, ->instantiate() would never fail.

> How do I make the connection between the preparse and the instantiate? 
> Do I just put what I need to remember about this key request in the
> payload.data during preparse, so I can examine it again during
> instantiate?

Have a look at user_preparse().  It attaches the contribution to the supplied
key_preparsed_payload struct, which is then passed to ->instantiate() and
->update() as appropriate.  generic_key_instantiate() is used by the user key
type.

David
