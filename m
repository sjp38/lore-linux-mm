Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 69A5F82905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 07:03:39 -0400 (EDT)
Received: by wevl61 with SMTP id l61so15450074wev.10
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 04:03:38 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id d7si10918934wiz.9.2015.03.12.04.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 04:03:37 -0700 (PDT)
Received: by wibbs8 with SMTP id bs8so46672969wib.0
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 04:03:37 -0700 (PDT)
Date: Thu, 12 Mar 2015 12:03:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] mtrr, mm, x86: Enhance MTRR checks for KVA huge page
 mapping
Message-ID: <20150312110333.GA6898@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
 <1426018997-12936-4-git-send-email-toshi.kani@hp.com>
 <20150311070216.GD29788@gmail.com>
 <1426092728.17007.380.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426092728.17007.380.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> > Did it perhaps want to be the other way around:
> > 
> >         if (mtrr_state.have_fixed && (start < 0x1000000)) {
> > 	...
> >                 } else if (start < 0x100000) {
> > 	...
> > 
> > or did it simply mess up the condition?
> 
> I think it was just paranoid to test the same condition twice...

Read the code again, it's _not_ the same condition ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
