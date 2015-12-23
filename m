Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 839DF6B02B4
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:46:22 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l126so161540421wml.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:46:22 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id v191si53320978wmd.52.2015.12.23.12.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 12:46:21 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id p187so30305105wmp.2
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:46:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gXDHGgiqfve_fP1RLXBGfyWarjWgUU3QPMhnFn_BbshA@mail.gmail.com>
References: <cover.1450283985.git.tony.luck@intel.com>
	<d560d03663b6fd7a5bbeae9842934f329a7dcbdf.1450283985.git.tony.luck@intel.com>
	<20151222111349.GB3728@pd.tnic>
	<CA+8MBbJ+T0Bkea48rivWEZRn8_iPiSvrPm5p22RfbS7V0_KyEA@mail.gmail.com>
	<20151223125853.GF30213@pd.tnic>
	<CAPcyv4gXDHGgiqfve_fP1RLXBGfyWarjWgUU3QPMhnFn_BbshA@mail.gmail.com>
Date: Wed, 23 Dec 2015 12:46:20 -0800
Message-ID: <CA+8MBbJX+3SW7CxqWT1ghzzbdV9pgVxXNejg4XC1=sDFY3Xgpw@mail.gmail.com>
Subject: Re: [PATCHV3 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Elliott@pd.tnic, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

> I know, memcpy returns the ptr to @dest like a parrot

Maybe I need to change the name to remove the
"memcpy" substring to avoid this confusion. How
about "mcsafe_copy()"? Perhaps with a "__" prefix
to point out it is a building block that will get various
wrappers around it??

Dan wants a copy_from_nvdimm() that either completes
the copy, or indicates where a machine check occurred.

I'm going to want a copy_from_user() that has two fault
options (user gave a bad address -> -EFAULT, or the
source address had an uncorrected error -> SIGBUS).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
