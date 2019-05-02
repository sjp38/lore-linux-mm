Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BF65C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C8C320652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:14:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C8C320652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD8176B0003; Thu,  2 May 2019 12:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88A46B0006; Thu,  2 May 2019 12:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A52896B0007; Thu,  2 May 2019 12:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59C736B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:14:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r8so1301964edd.21
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:14:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LnnOv3aRMVZ1aGLeMtne5s6UdQUnb4SMTI9kNOJYmqo=;
        b=TSDGib2TjUqyowjdts4XFnbQ0dJRLIBvSWttDr5OgcjfgZISJ8nuwiZlWE6o45rfYY
         HhKE9dDkqrHsv7dUOBFh2l0eTIGoYUOaoTGmmFVtvLjEVicz96W/P8tv9XnDHPD5ngsl
         JN+skG568WF5xFfhjkW9mwc1iSTD+hJKj19U5h21b8w1oO14rMo40cwfs40lLCeisRU4
         jtcNWOs1V5V0jzDrAOb9H6dOm9G0zC1RMz+nkpBjrraWJgtcxJRucmOuaRMs2SKtLtpS
         2oNayA70VLDr48R99tPLvw5GNZbHRoldjPxrMxu8T9qithdGNGt610reARwWznkLlDl/
         gR5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAX6JEEX7c6QqY1H1jocIoizME7XBq4jXubgrY12eJYaIs12hedx
	VllxqdXYeZmvrvKUE7COYq2zleWTHmulTp0IU61f2tF0+00WDglwABswkftCgRI4KGMx2OMvzCh
	VmhRjU23MqnRr+DjIQ6NorosSYuDV+AX6dWRW/b0CpO5xSj9gtLh3wGBtK8MGTAeC1A==
X-Received: by 2002:aa7:db50:: with SMTP id n16mr3078027edt.108.1556813674863;
        Thu, 02 May 2019 09:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwilJdRAIDiDjItVsV2fmF8U1Mu1xC+9EQP7zpfOlXp+eS2NL5r7fmJEXEAAcQo2A7kJQve
X-Received: by 2002:aa7:db50:: with SMTP id n16mr3077971edt.108.1556813673923;
        Thu, 02 May 2019 09:14:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556813673; cv=none;
        d=google.com; s=arc-20160816;
        b=RExJV9EVuvl6PEJbJ+RO17FB0YSWAb273TpKeUS8EoQL/Yyi4mr2K/MMX5FxMoB+0C
         tmJzcFaNixaQy2xR+L7gNWwQFt16KHHwUNJsCQGEKH5VN/NzPTsp1M/em7xpAK2KMkM3
         vVK6KmvdGlfcMwoHtVOIs64fsN27O0kPIpPj3HTr7GukOOxADhH+LNcpA2xy9lCidx2Q
         q5XqpEj2rBPBgfAu/mXjRYPILUY2StLNokf5AXZ9Aaeo/eDjcBWHZSiBn30WE9vDcaC8
         9holSe5lm74P9jyCZ5UhMQAzMM1nQx78yU8ZAnpeujdRknqX1hoxQ9NxKXCiXEXxg2uF
         NpvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LnnOv3aRMVZ1aGLeMtne5s6UdQUnb4SMTI9kNOJYmqo=;
        b=VaAJhpFlRYL023zPwfXz9n0gTNACzo6qaaMuWs5k3aZxgZviS9hYZy1yr1thtrPYIe
         WAmEENES6pVeHzZVp8cTvrjsSJTfN2Bp2w/N0/mI665Gd5Hf07ireR8mZAHsLDPhCn3E
         OZ0usK7L72K2j5FkjnOBVvIWMzixqOnUAfaFIF2qk0uXeMBOqSAGPC1/b+GTjl9Oq0LM
         OJzjRxqjLrfOS9CN6gkFt6BS33/tChupZg1/C60hNGOhXIjfTzUgYc2rT0R7mcT+QwSi
         HH+2cVhT/hAVry+ypuIzpGch6IiT2WFbu1suviRfoU3k/yjAHQ/BiOltWc5dZXuv/8iy
         PkeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i19si679808edr.274.2019.05.02.09.14.33
        for <linux-mm@kvack.org>;
        Thu, 02 May 2019 09:14:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D96CA78;
	Thu,  2 May 2019 09:14:32 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5B9783F5AF;
	Thu,  2 May 2019 09:14:27 -0700 (PDT)
Date: Thu, 2 May 2019 17:14:24 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>, libc-alpha@sourceware.org
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
Message-ID: <20190502161424.GQ3567@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
 <20190502111003.GO3567@e103592.cambridge.arm.com>
 <5b2c6cee345e00182e97842ae90c02cdcd830135.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b2c6cee345e00182e97842ae90c02cdcd830135.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 08:47:06AM -0700, Yu-cheng Yu wrote:
> On Thu, 2019-05-02 at 12:10 +0100, Dave Martin wrote:
> > On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > > An ELF file's .note.gnu.property indicates features the executable file
> > > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> 
> [...]
> > A couple of questions before I look in more detail:
> > 
> > 1) Can we rely on PT_GNU_PROPERTY being present in the phdrs to describe
> > the NT_GNU_PROPERTY_TYPE_0 note?  If so, we can avoid trying to parse
> > irrelevant PT_NOTE segments.
> 
> Some older linkers can create multiples of NT_GNU_PROPERTY_TYPE_0.  The code
> scans all PT_NOTE segments to ensure there is only one NT_GNU_PROPERTY_TYPE_0. 
> If there are multiples, then all are considered invalid.

I'm concerned that in the arm64 case we would waste some effort by
scanning multiple notes.

Could we do something like iterating over the phdrs, and if we find
exactly one PT_GNU_PROPERTY then use that, else fall back to scanning
all PT_NOTEs?

> > 2) Are there standard types for things like the program property header?
> > If not, can we add something in elf.h?  We should try to coordinate with
> > libc on that.  Something like
> > 
> > typedef __u32 Elf_Word;
> > 
> > typedef struct {
> > 	Elf_Word pr_type;
> > 	Elf_Word pr_datasz;
> > } Elf_Gnu_Prophdr;
> > 
> > (i.e., just the header part from [1], with a more specific name -- which
> > I just made up).
> 
> Yes, I will fix that.
> 
> [...]
> > 3) It looks like we have to go and re-parse all the notes for every
> > property requested by the arch code.
> 
> As explained above, it is necessary to scan all PT_NOTE segments.  But there
> should be only one NT_GNU_PROPERTY_TYPE_0 in an ELF file.  Once that is found,
> perhaps we can store it somewhere, or call into the arch code as you mentioned
> below.  I will look into that.

Just to get something working on arm64, I'm working on some hacks that
move things around a bit -- I'll post when I have something.

Did you have any view on my other point, below?

Cheers
---Dave

> > For now there is only one property requested anyway, so this is probably
> > not too bad.  But could we flip things around so that we have some
> > CONFIG_ARCH_WANTS_ELF_GNU_PROPERTY (say), and have the ELF core code
> > call into the arch backend for each property found?
> > 
> > The arch could provide some hook
> > 
> > 	int arch_elf_has_gnu_property(const Elf_Gnu_Prophdr *prop,
> > 					const void *data);
> > 
> > to consume the properties as they are found.
> > 
> > This would effectively replace the arch_setup_property() hook you
> > currently have.
> > 
> > Cheers
> > ---Dave
> > 
> > [1] https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI
> 

