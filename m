Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A05C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:31:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D405206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 08:31:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VkXjRe45"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D405206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0CA56B000A; Fri, 26 Apr 2019 04:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABD776B000C; Fri, 26 Apr 2019 04:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ADF56B000D; Fri, 26 Apr 2019 04:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF5F6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 04:31:49 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a18so2632391wrs.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/8yEHGmmpSB8zJvfnDs0qm8YJnL5/w4ezpyP4pzX7OU=;
        b=BpAcCRhggV7q2tXY3iLy1NMUOuMlQED1ni7d6hA47IByIh/IKuFABFgejPMr4MBRYG
         lkEjG/6YIz3gZHV+kxbRNsvMHsEBp7RWeDzaDLI4KeNa6JkpjDVT9j3WxA06qrcwRYXk
         1EYKUCV4USEbVsIC8gCr91GCxuoTyLS3RiPh4Hsoeq01Hldzfi2X2eHCIck0DWfihsPw
         bmBaFs+WTO91HkNiKfrBIDBZImnjNVV2lwScxwSeji5tufvqrlsmi/LNBaCPbCKyZl7N
         JZL9FbvwlK982WDgMEEaT/zsrWqkpTiXz6rCSWm37A4JW9xzhFxRP6PAWjYaF/rJHJ9i
         uMjw==
X-Gm-Message-State: APjAAAUT6TneL4YFg1mOQy1XpL7xPfvo0/olGDad6iLkCK5n1J/ViU1m
	Roige4DzasVeiC9rcNCPRsgRggTuyv3l3NB+Zzy+OAGyM5BMwmsAhBQY7cYxT4cyxpkNu5BOReV
	qeld2fT4rkrdqRjcXATC1am0ePmoIUisMgbDecZfQ8Yw/fzwSIMT8mo7kjiwSJAY=
X-Received: by 2002:adf:8062:: with SMTP id 89mr2626082wrk.107.1556267508802;
        Fri, 26 Apr 2019 01:31:48 -0700 (PDT)
X-Received: by 2002:adf:8062:: with SMTP id 89mr2626038wrk.107.1556267508079;
        Fri, 26 Apr 2019 01:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556267508; cv=none;
        d=google.com; s=arc-20160816;
        b=sjQ4yC6xKgq8RZZRLgFQJjCqezDMGPsZJJkXH5YEOt+mmURVvZpcPkKXS2MCOiGXXU
         s65ZKCPDotPGP5cLJxFLmQ+KNkR/D1FDgJgy48fqYuSGmrTOpo1YPEqLfBaMZQ2uoJzH
         EVotO8Fprc+uaRrqWXVKhY/ZJCaXWzH4d7b/J5uLEDWrZE4ahW66V9zpcpGvkUq/U2d+
         /aXy/jSV/81moNxuE6n91avTU8PIeJxcmyr7TjxUOLJ2aD0WpS3e7a1q0TXohMPoyQ+u
         54eHASmPuwX3uYFqJbDerc3jTtKc2qz9a8YqFXgEJ9ydQvHxZnccu1ld9bduymwSdEL5
         EWPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=/8yEHGmmpSB8zJvfnDs0qm8YJnL5/w4ezpyP4pzX7OU=;
        b=YnHZAzHAS3819wcw31sDPwgfmGk4lYQuW0GyB9vKLysVnoIynN7n6cSAP6eTvcVZM1
         Ft5w0vDjw6L3BXJv2vrxMjjSBdEUUkaqom0xWfiLLejJvuValGhTtZbQkOaQma6aWtXF
         DAjjlMZM8JJWY70ThfRtcpvPqPAU/ykH22hDk955MLy+JcHiIw2UEbdBo7O0P5vA1fNF
         yUQPQDHC1FyQ1O5UsGt2no7RtttcrJAC5BL+CUjrYafBa8FhrtYQmmajZ5dYrWIhshqA
         A7dWlA0DGPRh2my2Lej4qZeQ9MHd1roTJ+UM3eYqNMt5o9NEJmWFDNRnZpSeFn3YhSp/
         zYXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VkXjRe45;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor7231829wrl.38.2019.04.26.01.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 01:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VkXjRe45;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/8yEHGmmpSB8zJvfnDs0qm8YJnL5/w4ezpyP4pzX7OU=;
        b=VkXjRe45hyNXVj6ZfWoXHr6MTHjtWL9wxGXVZSzLMcje4P0FbuT/Q7Jd+vA1p9zEB/
         8RqkOkiJthWGtNBekTaSFZY4oXZh1GyFrxsJ68xk0BZzJnK06NtdNo3O+axMJWfCl1qE
         GyHF+8T/9FBm0+DjXetmbgG3M0v8zroVHiOtLPRpaT6MrSmy9XOu160qeULDV180k0xa
         kY+zWM78luJUpw4oMLsj3nAbD5QeSMjPf76uIIhHD82smYQ4sa2Gw/bOFqlaYzMnrmOq
         /DJvD0YVbwD+SffY8PXAy25ufW7lJrslVydjKCvITbMXQredlQKDjMDmHDbLgT49Ymtn
         CxwQ==
X-Google-Smtp-Source: APXvYqz7R4wqcBRnF5mLwlUAgAYn64tt07z4jLjy3OlElfpQAtlWfTSEl2f9ae5ADnCd69ZUlZdi4A==
X-Received: by 2002:a5d:654a:: with SMTP id z10mr3402530wrv.153.1556267507780;
        Fri, 26 Apr 2019 01:31:47 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id v16sm20304256wru.76.2019.04.26.01.31.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 01:31:46 -0700 (PDT)
Date: Fri, 26 Apr 2019 10:31:44 +0200
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
Message-ID: <20190426083144.GA126896@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Mike Rapoport <rppt@linux.ibm.com> wrote:

> When enabled, the system call isolation (SCI) would allow execution of 
> the system calls with reduced page tables. These page tables are almost 
> identical to the user page tables in PTI. The only addition is the code 
> page containing system call entry function that will continue 
> exectution after the context switch.
> 
> Unlike PTI page tables, there is no sharing at higher levels and all 
> the hierarchy for SCI page tables is cloned.
> 
> The SCI page tables are created when a system call that requires 
> isolation is executed for the first time.
> 
> Whenever a system call should be executed in the isolated environment, 
> the context is switched to the SCI page tables. Any further access to 
> the kernel memory will generate a page fault. The page fault handler 
> can verify that the access is safe and grant it or kill the task 
> otherwise.
> 
> The initial SCI implementation allows access to any kernel data, but it
> limits access to the code in the following way:
> * calls and jumps to known code symbols without offset are allowed
> * calls and jumps into a known symbol with offset are allowed only if that
> symbol was already accessed and the offset is in the next page
> * all other code access are blocked
> 
> After the isolated system call finishes, the mappings created during its
> execution are cleared.
> 
> The entire SCI page table is lazily freed at task exit() time.

So this basically uses a similar mechanism to the horrendous PTI CR3 
switching overhead whenever a syscall seeks "protection", which overhead 
is only somewhat mitigated by PCID.

This might work on PTI-encumbered CPUs.

While AMD CPUs don't need PTI, nor do they have PCID.

So this feature is hurting the CPU maker who didn't mess up, and is 
hurting future CPUs that don't need PTI ..

I really don't like it where this is going. In a couple of years I really 
want to be able to think of PTI as a bad dream that is mostly over 
fortunately.

I have the feeling that compiler level protection that avoids corrupting 
the stack in the first place is going to be lower overhead, and would 
work in a much broader range of environments. Do we have analysis of what 
the compiler would have to do to prevent most ROP attacks, and what the 
runtime cost of that is?

I mean, C# and Java programs aren't able to corrupt the stack as long as 
the language runtime is corect. Has to be possible, right?

Thanks,

	Ingo

