Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id BBDCC6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:15:28 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so5951802wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 23:15:28 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id xm4si2549782wib.90.2015.09.24.23.15.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 23:15:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so7878722wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 23:15:27 -0700 (PDT)
Date: Fri, 25 Sep 2015 08:15:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20150925061523.GA15753@gmail.com>
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

> > I.e. AFAICS pkeys could be used to create true '--x' permissions for executable 
> > (user-space) pages.
> 
> Just remember that all of the protections are dependent on the contents of PKRU.  
> If an attacker controls the Access-Disable bit in PKRU for the executable-only 
> region, you're sunk.

The same is true if the attacker can execute mprotect() calls.

> But, that either requires being able to construct and execute arbitrary code 
> *or* call existing code that sets PKRU to the desired values. Which, I guess, 
> gets harder to do if all of the the wrpkru's are *in* the execute-only area.

Exactly. True --x executable regions makes it harder to 'upgrade' limited attacks.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
