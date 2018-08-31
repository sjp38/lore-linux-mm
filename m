Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5FE86B573A
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 09:43:03 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j22-v6so8457198wre.7
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 06:43:03 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id a5-v6si7730308wrt.56.2018.08.31.06.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 06:43:02 -0700 (PDT)
Date: Fri, 31 Aug 2018 14:42:44 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180831134244.GB19965@ZenIV.linux.org.uk>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831081123.6mo62xnk54pvlxmc@ltop.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

On Fri, Aug 31, 2018 at 10:11:24AM +0200, Luc Van Oostenryck wrote:
> On Thu, Aug 30, 2018 at 01:41:16PM +0200, Andrey Konovalov wrote:
> > This patch adds __force annotations for __user pointers casts detected by
> > sparse with the -Wcast-from-as flag enabled (added in [1]).
> > 
> > [1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292
> 
> Hi,
> 
> It would be nice to have some explanation for why these added __force
> are useful.

	It would be even more useful if that series would either deal with
the noise for real ("that's what we intend here, that's what we intend there,
here's a primitive for such-and-such kind of cases, here we actually
ought to pass __user pointer instead of unsigned long", etc.) or left it
unmasked.

	As it is, __force says only one thing: "I know the code is doing
the right thing here".  That belongs in primitives, and I do *not* mean the
#define cast_to_ulong(x) ((__force unsigned long)(x))
kind.

	Folks, if you don't want to deal with that - leave the warnings be.
They do carry more information than "someone has slapped __force in that place".

Al, very annoyed by that kind of information-hiding crap...
