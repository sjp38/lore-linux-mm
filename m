Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C73676B0262
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:34:57 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ib6so225136884pad.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:34:57 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id u3si609931pay.67.2016.07.11.07.34.56
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 07:34:57 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5783AE8F.3@sr71.net>
Date: Mon, 11 Jul 2016 07:34:55 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 07/10/2016 09:25 PM, Andy Lutomirski wrote:
> 2. When thread A allocates a pkey, how does it lock down thread B?
> 
> #2 could be addressed by using fully-locked-down as the initial state
> post-exec() and copying the state on clone().  Dave, are there any
> cases in practice where one thread would allocate a pkey and want
> other threads to immediately have access to the memory with that key?

The only one I can think of is a model where pkeys are used more in a
"denial" mode rather than an "allow" mode.

For instance, perhaps you don't want to modify your app to use pkeys,
except for a small routine where you handle untrusted user data.  You
would, in that routine, deny access to a bunch of keys, but otherwise
allow access to all so you didn't have to change any other parts of the app.

Should we instead just recommend to userspace that they lock down access
to keys by default in all threads as a best practice?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
