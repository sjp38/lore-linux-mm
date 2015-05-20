Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 384F96B012E
	for <linux-mm@kvack.org>; Wed, 20 May 2015 12:06:14 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so5617858obb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 09:06:14 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id u83si10922904oia.138.2015.05.20.09.06.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 09:06:13 -0700 (PDT)
Message-ID: <1432136807.1440.0.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 20 May 2015 09:46:47 -0600
In-Reply-To: <20150520160414.GB3424@pd.tnic>
References: <20150518200114.GE23618@pd.tnic>
	 <1431980468.21019.11.camel@misato.fc.hp.com>
	 <20150518205123.GI23618@pd.tnic>
	 <1431985994.21526.12.camel@misato.fc.hp.com>
	 <20150519114437.GF4641@pd.tnic> <20150519132307.GG4641@pd.tnic>
	 <20150520115509.GA3489@gmail.com> <1432132451.700.4.camel@misato.fc.hp.com>
	 <20150520150114.GA19161@gmail.com>
	 <1432134143.908.12.camel@misato.fc.hp.com> <20150520160414.GB3424@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Wed, 2015-05-20 at 18:04 +0200, Borislav Petkov wrote:
> On Wed, May 20, 2015 at 09:02:23AM -0600, Toshi Kani wrote:
> > Boris, can you update the patch,
> 
> Done.

Thanks!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
