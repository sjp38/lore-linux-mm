Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC7366B72C2
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:42:12 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so10447733pgc.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:42:12 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w12si18302900pgl.122.2018.12.04.21.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:42:11 -0800 (PST)
Date: Tue, 4 Dec 2018 21:44:45 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 11/13] keys/mktme: Program memory encryption keys on a
 system wide basis
Message-ID: <20181205054444.GF18596@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <72dd5f38c1fdbc4c532f8caf2d2010f1ddfa8439.1543903910.git.alison.schofield@intel.com>
 <20181204092145.GR11614@hirez.programming.kicks-ass.net>
 <20181204095009.ehgyxvv4lcd7ztd7@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204095009.ehgyxvv4lcd7ztd7@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 12:50:09PM +0300, Kirill A. Shutemov wrote:
> On Tue, Dec 04, 2018 at 09:21:45AM +0000, Peter Zijlstra wrote:
> > On Mon, Dec 03, 2018 at 11:39:58PM -0800, Alison Schofield wrote:
> > 
> > > +struct mktme_hw_program_info {
> > > +	struct mktme_key_program *key_program;
> > > +	unsigned long status;
> > > +};
> > > +
> > > +/* Program a KeyID on a single package. */
> > > +static void mktme_program_package(void *hw_program_info)
> > > +{
> > > +	struct mktme_hw_program_info *info = hw_program_info;
> > > +	int ret;
> > > +
> > > +	ret = mktme_key_program(info->key_program);
> > > +	if (ret != MKTME_PROG_SUCCESS)
> > > +		WRITE_ONCE(info->status, ret);
> > 
> > What's the purpose of that WRITE_ONCE()?
> 
> [I suggested the code to Alison.]
> 
> Yes, you're right. Simple assignment will do.
Will do. Thanks!

> 
> -- 
>  Kirill A. Shutemov
