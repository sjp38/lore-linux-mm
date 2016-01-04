Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BC7FE6B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 02:49:08 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b14so171849464wmb.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 23:49:08 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id za9si39561995wjc.56.2016.01.03.23.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jan 2016 23:49:07 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id f206so200612295wmf.0
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 23:49:07 -0800 (PST)
Date: Mon, 4 Jan 2016 08:49:03 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a
 bit)
Message-ID: <20160104074903.GA4227@gmail.com>
References: <cover.1451869360.git.tony.luck@intel.com>
 <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <CA+8MBbKuOHHwYeFHFePAts=DE=iR4aQUcfjDzGEg7u5ihTDmLg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+8MBbKuOHHwYeFHFePAts=DE=iR4aQUcfjDzGEg7u5ihTDmLg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>


* Tony Luck <tony.luck@gmail.com> wrote:

> On Wed, Dec 30, 2015 at 9:59 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> > This adds two bits of fixup class information to a fixup entry,
> > generalizing the uaccess_err hack currently in place.
> >
> > Forward-ported-from-3.9-by: Tony Luck <tony.luck@intel.com>
> > Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> 
> Crivens!  I messed up when "git cherrypick"ing this and "git
> format-patch"ing it.
> 
> I didn't mean to forge Andy's From line when sending this out (just to have a
> From: line to give him credit.for the patch).
> 
> Big OOPs ... this is "From:" me ... not Andy!

But in any case it's missing your SOB line.

If Andy is still the primary author (much of his original patch survived, you 
resolved conflicts or minor changes) then you can send this as:

 From: Tony Luck <tony.luck@intel.com>
 Subject: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)

 From: Andy Lutomirski <luto@amacapital.net>

 ... changelog ...

 Signed-off-by: Andy Lutomirski <luto@amacapital.net>
 [ Forward ported from a v3.9 version. ]
 Signed-off-by: Tony Luck <tony.luck@intel.com

This carries all the information, has a proper SOB chain, and preserves 
authorship. Also, it's clear from the tags that you made material changes, so any 
resulting breakage is yours (and mine), not Andy's! ;-)

If the changes to the patch are major, so that your new work is larger than Andy's 
original work, you can still credit him via a non-standard tag, like:

 From: Tony Luck <tony.luck@intel.com>
 Subject: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)

 This patch is based on Andy Lutomirski's patch sent against v3.9:

 ... changelog ...

 Originally-from: Andy Lutomirski <luto@amacapital.net>
 Signed-off-by: Tony Luck <tony.luck@intel.com

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
