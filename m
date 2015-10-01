Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9326F82F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:17:23 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so24606703wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:17:23 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id w8si3103865wiz.62.2015.10.01.04.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 04:17:22 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so28010641wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:17:22 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:17:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151001111718.GA25333@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56044A88.7030203@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>


* Dave Hansen <dave@sr71.net> wrote:

> > If yes then this could be a significant security feature / usecase for pkeys: 
> > executable sections of shared libraries and binaries could be mapped with pkey 
> > access disabled. If I read the Intel documentation correctly then that should 
> > be possible.
> 
> Agreed.  I've even heard from some researchers who are interested in this:
> 
> https://www.infsec.cs.uni-saarland.de/wp-content/uploads/sites/2/2014/10/nuernberger2014ccs_disclosure.pdf

So could we try to add an (opt-in) kernel option that enables this transparently 
and automatically for all PROT_EXEC && !PROT_WRITE mappings, without any 
user-space changes and syscalls necessary?

Beyond the security improvement, this would enable this hardware feature on most 
x86 Linux distros automatically, on supported hardware, which is good for testing.

Assuming it boots up fine on a typical distro, i.e. assuming that there are no 
surprises where PROT_READ && PROT_EXEC sections are accessed as data.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
