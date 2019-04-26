Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED4F6C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 09:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EED02146E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 09:58:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K85URiHS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EED02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50A96B0005; Fri, 26 Apr 2019 05:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E00946B0006; Fri, 26 Apr 2019 05:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC6C46B0007; Fri, 26 Apr 2019 05:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED7F6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 05:58:08 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l1so2889321wme.1
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 02:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YJCStWT0dNYPW3ntuISaTY+7m2TzWui5U3rbJsecnt4=;
        b=LbPjTJc0RSEtB3m8qXlis68oebjVfZGoaGPL0I+df1JZ7TuSDgR8+KPBqDFii86EM9
         xH6/f7jHGscNth5W9PrYGTe6L0koC5ZOmnGU08+v4IWGGlbXUsW7YxsgjBMudmfFleea
         mJ8OLcVbLwwZ3Ta4/PVVCpxqIXmYm1wawYFQlBidgRyw0p/P4KK8ZPgZoFUxaqvDkkqG
         7RLUasRAY3AC0BqNF7Gp0kLHje3J0C1bx57+YFjeI+70cOGSb0Hqd77oPnWZwQNDgA8N
         wqev7ypj3NP9H5tAMFA8+tEqdzUhjj/JXrlE2Q8qDmWGvCM3E7AxtDYfNmGrJ4JMQxYi
         haig==
X-Gm-Message-State: APjAAAXP3hFEbxzOkRonIuX+gQj2uJPRHSrIy810E4geOAFzYa+Rib/o
	Vxgci1GQl3wVbxSawdokuWycpI8Tu0oxhRbu1qt6If2l0clHXIHWCQh2s37jPGr7nsZ0oZwzWKW
	SRSfY22zuTgNX+uKafoaeMkO8Pnt0jHSPsGVQLb4pDBHiES5YjoMcviintjx96zE=
X-Received: by 2002:adf:ec4e:: with SMTP id w14mr6623436wrn.53.1556272687851;
        Fri, 26 Apr 2019 02:58:07 -0700 (PDT)
X-Received: by 2002:adf:ec4e:: with SMTP id w14mr6623309wrn.53.1556272685868;
        Fri, 26 Apr 2019 02:58:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556272685; cv=none;
        d=google.com; s=arc-20160816;
        b=YUAqMw+6/L37JqY6jW8yZcNupL+ogZRkc9FixP3jBHzIe5fCQW5ZxF9pd87YbCaF56
         xs1wKVGIjaq30GBe0gK5ogVkOyvZcCjIgkU4lXIWqQLBmN6dzzJmpSd8IaBwDbmBvRgM
         UDgPGDo4C0xffppWabP5EGtL6mJMXCMY5YsiXiMpK5HO3rZZG0TO6RiTl3eWpC/Nyfao
         hCW/6UNy/DU77FZC4RzNztKxlTpn7clPrY5GakwRKA3NZPwlT9aTZCk56vh6HUt0Byxx
         h20Aw880v47efCo36MHObq5Hnp/G6lBtoYvQuOSjSmVoSVRkWfyy9GK8OEsaN5O6W3zI
         Jejw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=YJCStWT0dNYPW3ntuISaTY+7m2TzWui5U3rbJsecnt4=;
        b=OtUw9M02ZmmBsUMEmhYkGH63AiWPDJ6F3NCIL0xxg2UzVxTswl7od1h1Mwu+7Jxnto
         exrJzDPV115aRHV4GJltO+yyVoQv1sDdFP0xswyxwEyll+jE+Ejcu1HJaCcry3Z3rvkz
         IpfLdgEsw+efHQCWwYflOXi5lFYqpmRtAajch0Mt0r7nzItR6rTnswVHIcA07gINsDsg
         57XsBwn0giWyrU8JQFUO1z68dzG1VTP2OEQGlsJ7YcsgKTj6pEwSOvqZTlVwU0uRNYv9
         EyBBGfZYkXJ2hT99Gdr1wSJvzhWsH//h27wlfOWqq2qJ5ZyejED5XLlyBUgjTPYNydMo
         ju/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K85URiHS;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o67sor10869026wma.12.2019.04.26.02.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 02:58:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K85URiHS;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YJCStWT0dNYPW3ntuISaTY+7m2TzWui5U3rbJsecnt4=;
        b=K85URiHSmAJ1R+AeUwGYyucXzeBGpSgFJxfInaFSv6ntKK/zvtuQaZaAHMqosXdqCQ
         PSwdwnK8AfCbRsW/xqF3cWnqK+cd8FYKwm1lw4QCJH13elJblsFe8d0B4rJmiaypHx2V
         BPKTRORhHEpvy4fMFoXLQACGi5sY1E9IPfW7Gus8e0NvyirHI1shKtQemU1+usuMcDvY
         yN+f5fiDh8kXry7A7CVvtVKcIK+17pib8MkhZzdPsM+nfv/EpYuyK3O/gTwUr/EbM0oj
         VIpstDsdgthviqEU9Rm/RpgvIMDfui0KeJJYGLxqA7m8pSj8BmzEJj7hUPmI0hkzSEgV
         0w/Q==
X-Google-Smtp-Source: APXvYqxU4xRSO//2LeLOAQNJAxp8x2iYJV7YGaHBJl6zzDXEGkhWiOOILZ/XwIJJg56oj/prXk8sRw==
X-Received: by 2002:a1c:f204:: with SMTP id s4mr7232803wmc.51.1556272685405;
        Fri, 26 Apr 2019 02:58:05 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id 4sm20102389wmg.12.2019.04.26.02.58.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 02:58:04 -0700 (PDT)
Date: Fri, 26 Apr 2019 11:58:02 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org, x86@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190426095802.GA35515@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426083144.GA126896@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@kernel.org> wrote:

> I really don't like it where this is going. In a couple of years I 
> really want to be able to think of PTI as a bad dream that is mostly 
> over fortunately.
> 
> I have the feeling that compiler level protection that avoids 
> corrupting the stack in the first place is going to be lower overhead, 
> and would work in a much broader range of environments. Do we have 
> analysis of what the compiler would have to do to prevent most ROP 
> attacks, and what the runtime cost of that is?
> 
> I mean, C# and Java programs aren't able to corrupt the stack as long 
> as the language runtime is corect. Has to be possible, right?

So if such security feature is offered then I'm afraid distros would be 
strongly inclined to enable it - saying 'yes' to a kernel feature that 
can keep your product off CVE advisories is a strong force.

To phrase the argument in a bit more controversial form:

   If the price of Linux using an insecure C runtime is to slow down 
   system calls with immense PTI-alike runtime costs, then wouldn't it be 
   the right technical decision to write the kernel in a language runtime 
   that doesn't allow stack overflows and such?

I.e. if having Linux in C ends up being slower than having it in Java, 
then what's the performance argument in favor of using C to begin with? 
;-)

And no, I'm not arguing for Java or C#, but I am arguing for a saner 
version of C.

Thanks,

	Ingo

