Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 919266B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:16:49 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so9452992wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:16:49 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id cu5si2813314wib.72.2015.09.25.00.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 00:16:48 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so9452593wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:16:48 -0700 (PDT)
Date: Fri, 25 Sep 2015 09:16:45 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20150925071645.GA17385@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <CALCETrVd+wgGvRcKhz6wHYqYi+9=MSddqxOkWucW=DT9kQ=8Jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVd+wgGvRcKhz6wHYqYi+9=MSddqxOkWucW=DT9kQ=8Jg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave@sr71.net>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> This may mean that we want to have a way for binaries to indicate that they want 
> their --x segments to be loaded with a particular protection key.  The right way 
> to do that might be using an ELF note, and I also want to use ELF notes to allow 
> turning off vsyscalls, so maybe it's time to write an ELF note parser in the 
> kernel.

That would be absolutely lovely for many other reasons as well, and we should also 
add a tool to tools/ to edit/expand/shrink those ELF notes on existing systems.

I.e. make it really easy to augment security policies on an existing distro, using 
any filesystem (not just ACL capable ones) and using the binary only. Linux 
binaries could carry capabilities information, etc. etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
