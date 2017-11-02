Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E75DA6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 12:38:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 15so74945pgc.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 09:38:52 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id o1si2397060plk.182.2017.11.02.09.38.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 09:38:51 -0700 (PDT)
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page
 tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos>
 <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
 <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com>
 <alpine.DEB.2.20.1711012316130.1942@nanos>
 <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com>
Date: Thu, 2 Nov 2017 09:38:50 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711021226020.2090@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/02/2017 04:33 AM, Thomas Gleixner wrote:
> So for the problem at hand, I'd suggest we disable the vsyscall stuff if
> CONFIG_KAISER=y and be done with it.

Just to be clear, are we suggesting to just disable
LEGACY_VSYSCALL_NATIVE if KAISER=y, and allow LEGACY_VSYSCALL_EMULATE?
Or, do we just force LEGACY_VSYSCALL_NONE=y?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
