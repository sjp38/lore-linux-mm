Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E49CD8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:34:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f32-v6so11434330pgm.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:34:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v17-v6si18697864pgk.178.2018.09.10.17.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:34:00 -0700 (PDT)
Date: Mon, 10 Sep 2018 17:34:33 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 02/12] mm: Generalize the mprotect implementation to
 support extensions
Message-ID: <20180911003433.GA447@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <2dcbb08ed8804e02538a73ee05a4283c54180e36.1536356108.git.alison.schofield@intel.com>
 <0663b867003511f1ca652cef6acce589a5184a4b.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0663b867003511f1ca652cef6acce589a5184a4b.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

On Mon, Sep 10, 2018 at 01:12:31PM +0300, Jarkko Sakkinen wrote:
> On Fri, 2018-09-07 at 15:34 -0700, Alison Schofield wrote:
> > Today mprotect is implemented to support legacy mprotect behavior
> > plus an extension for memory protection keys. Make it more generic
> > so that it can support additional extensions in the future.
> > 
> > This is done is preparation for adding a new system call for memory
> > encyption keys. The intent is that the new encrypted mprotect will be
> > another extension to legacy mprotect.
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > ---
> >  mm/mprotect.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 68dc476310c0..56e64ef7931e 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -35,6 +35,8 @@
> >  
> >  #include "internal.h"
> >  
> > +#define NO_PKEY  -1
> 
> This commit does not make anything more generic but it does take
> away a magic number. The code change is senseful. The commit
> message is nonsense.

do_mprotect_ext() is intended to be the generic replacement for
do_mprotect_pkey() which was added for protection keys.

> 
> PS. Please use @linux.intel.com for LKML.
Is this a request to use your @linux.intel.com email address when I'm
posting to LKML's?

> 
> /Jarkko
