Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A38806B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:03:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so2939530pfd.6
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:03:51 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i14si1639423pgn.69.2017.11.29.10.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 10:03:50 -0800 (PST)
Subject: Re: [PATCH 0/6] more KAISER bits
References: <20171129103301.131535445@infradead.org>
 <alpine.DEB.2.20.1711291523340.1825@nanos>
 <alpine.DEB.2.20.1711291701360.1825@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1d4ac626-1e5d-8a5c-653a-9a3265c5c255@linux.intel.com>
Date: Wed, 29 Nov 2017 10:03:49 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711291701360.1825@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 11/29/2017 08:02 AM, Thomas Gleixner wrote:
> Current pile at:
> 
> 	https://tglx.de/~tglx/patches.tar

I don't see any show stoppers in there.  The biggest change is Peter's
rework of the user asid flushing, but that all looks OK to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
