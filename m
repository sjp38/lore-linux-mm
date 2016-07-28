Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B813E6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 19:56:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so25193562lfe.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 16:56:27 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id fc10si15872565wjc.189.2016.07.28.16.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 16:56:26 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id o80so129216505wme.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 16:56:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160728134142.GA12516@thunk.org>
References: <20160727071400.GA3912@osiris> <20160728034601.GC20032@thunk.org>
 <20160728055548.GA3942@osiris> <20160728072408.GB3942@osiris> <20160728134142.GA12516@thunk.org>
From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 28 Jul 2016 16:56:24 -0700
Message-ID: <CA+8MBbKDpuuN4FCPnCGXei2v+z2PvLS_vGscP6H32NcGM1xhhw@mail.gmail.com>
Subject: Re: [BUG -next] "random: make /dev/urandom scalable for silly
 userspace programs" causes crash
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jul 28, 2016 at 6:41 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Thu, Jul 28, 2016 at 09:24:08AM +0200, Heiko Carstens wrote:
>>
>> Oh, I just realized that Linus pulled your changes. Actually I was hoping
>> we could get this fixed before the broken code would be merged.
>> Could you please make sure the bug fix gets included as soon as possible?
>
> Yes, I'll send the pull request to ASAP.

Also broke ia64.  Same fix works for me.

Tested-by: Tony Luck <tony.luck@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
