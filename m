Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5468B6B6E17
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:50:16 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p15so13537554pfk.7
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:50:16 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z136si15561197pgz.28.2018.12.04.01.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:50:15 -0800 (PST)
Date: Tue, 4 Dec 2018 12:50:09 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC v2 11/13] keys/mktme: Program memory encryption keys on a
 system wide basis
Message-ID: <20181204095009.ehgyxvv4lcd7ztd7@black.fi.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <72dd5f38c1fdbc4c532f8caf2d2010f1ddfa8439.1543903910.git.alison.schofield@intel.com>
 <20181204092145.GR11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204092145.GR11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alison Schofield <alison.schofield@intel.com>, dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 09:21:45AM +0000, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:39:58PM -0800, Alison Schofield wrote:
> 
> > +struct mktme_hw_program_info {
> > +	struct mktme_key_program *key_program;
> > +	unsigned long status;
> > +};
> > +
> > +/* Program a KeyID on a single package. */
> > +static void mktme_program_package(void *hw_program_info)
> > +{
> > +	struct mktme_hw_program_info *info = hw_program_info;
> > +	int ret;
> > +
> > +	ret = mktme_key_program(info->key_program);
> > +	if (ret != MKTME_PROG_SUCCESS)
> > +		WRITE_ONCE(info->status, ret);
> 
> What's the purpose of that WRITE_ONCE()?

[I suggested the code to Alison.]

Yes, you're right. Simple assignment will do.

-- 
 Kirill A. Shutemov
