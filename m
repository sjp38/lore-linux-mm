Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 978506B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 18:38:59 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id x65so1722693pfb.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 15:38:59 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id uj7si632021pab.111.2016.02.09.15.38.58
        for <linux-mm@kvack.org>;
        Tue, 09 Feb 2016 15:38:58 -0800 (PST)
Date: Tue, 9 Feb 2016 15:38:57 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
Message-ID: <20160209233857.GA24348@agluck-desk.sc.intel.com>
References: <cover.1454618190.git.tony.luck@intel.com>
 <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
 <20160207171041.GG5862@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160207171041.GG5862@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

> > +	if (mca_cfg.recovery || (mca_cfg.ser &&
> > +		!strncmp(c->x86_model_id, "Intel(R) Xeon(R) CPU E7-", 24)))
> 
> Eeww, a model string check :-(
> 
> Lemme guess: those E7s can't be represented by a range of
> model/steppings, can they?

We use the same model number for E5 and E7 series. E.g. 63 for Haswell.
The model_id string seems to be the only way to tell ahead of time
whether you will get a recoverable machine check or die when you
touch uncorrected memory.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
