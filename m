Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72843C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E65F2190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E65F2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD9116B0269; Fri, 22 Mar 2019 06:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAFC26B026A; Fri, 22 Mar 2019 06:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC66F6B026B; Fri, 22 Mar 2019 06:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 535B46B0269
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:48:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p4so789194edd.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+0wnXzeAJwW6uvDrnRfuljM8QnBbXgPjVPYb690Xkzg=;
        b=Ayt0SeXQYhHo2GQ5pRimq17NJvz/vqwzoJ8m82vt0SJ68m8lxANOMoiKTsYh9y9VFi
         iumoyRlvpo96+qXwHVeVOEN86mw+NGQEVWatgQ6zN8TQNnP2L8eO3PeNeKot2RJQHs2E
         XBQGIIdxutlT/j7K0iRj8DCqId5jL5XETTYg+oyeGT1yXn6gXA69F8Y0Q1KjBUGW1+9g
         9lMZ1VjCKOl01DVp+0jRZC4yqwEcNKLON+dZ3QAfrmGfJOLbMa8Fo4bkjgZkMyNTwACW
         1kfjNNgnJl9IvFf5aaizNxfEOg5CS1mJLGKoiTUjoEmgxc4lQubsKOkmYsHVKcx3Yo4/
         ZJww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWtS9aKl2mcP/AKfVOieGJb4+LqHsrRJRD3sKG3RjYsbXahc/KJ
	ftxBULlpojDXNhe5l/aa9AT5BPQ88Ksf69qkSKQTWOeCoYep+tfBw2gCYvauu4F+051pzhpskLU
	su6flOmxQWUlU59gxYP6BhsnlVnPHN/3yJU44MqXKvxHFUA1bVLsNt0YQIHcWWRt0bw==
X-Received: by 2002:a50:d793:: with SMTP id w19mr5603225edi.99.1553251731873;
        Fri, 22 Mar 2019 03:48:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZHRBhAvEsAgSN8AtaY4+g6OLm2H6b4yN+dl6+W7H5dRXYS82FVZ+K7tV4GH1VT/C6cTVX
X-Received: by 2002:a50:d793:: with SMTP id w19mr5603166edi.99.1553251730648;
        Fri, 22 Mar 2019 03:48:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553251730; cv=none;
        d=google.com; s=arc-20160816;
        b=WIskvHGPz27xbs7S/JRVFKjqZsoBiGmS08VPnNm95V0udIX/myWJIW91qd+ZudWz+w
         hKwqRLk6Xw0nD0VdEuZFijc/nV6HHsNX66q/XajM466rqjgtvo5xX7I3azGani5SsB/d
         cMi+klSPuW/qCO1F66AlS4b14SQ6UaUMtOg3FrLwAxfnZBNV/W+f+c5biPMNR76Ooyku
         wAGGWkuToUa9V+6Wq2i77/X/TRf90iWJA5ypupJdM0M45JJdnvlwnmgDHxiZVaxLv7PL
         Q7dSRm3zK1LVXh38uE781E6FhgReWPSi9nmsUM+4axJWiD+Bzf/fOi6WaXpULsXSec3e
         IxqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+0wnXzeAJwW6uvDrnRfuljM8QnBbXgPjVPYb690Xkzg=;
        b=QSVSyIU3AqiOocwIP5JDB4ujeCryhB7wOltNZayGvDoM1XTwlyEyKf9V6A2WWbm6R8
         2XModDy3/523n2FrSOFIPCS0hj0kDhvyOY/nStyW2JkQ5qrS8QwoUnCZlue4yNkfiukw
         Gt3C5WhsGE1XXh1usByKAWrG4sSKfdzXmpUUw0JMNEQJM4QYZsFLl2k4ogSF/qA5W2hE
         I0UU0v8C1ac4vYz7a09RoN5rqQ8O+lALL4C9mzZzQurFyWqZFf3SwueRG6sc9KyRD82L
         AtLUYPZHIEdQRc5NZQ98iQIXqGEzBc9JoU62E5ixP4rGV1jGoiv87Vfh46hLG+fu2KCn
         7a5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t8si3343852eda.212.2019.03.22.03.48.50
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 03:48:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 35A5C374;
	Fri, 22 Mar 2019 03:48:49 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E58943F575;
	Fri, 22 Mar 2019 03:48:42 -0700 (PDT)
Date: Fri, 22 Mar 2019 10:48:40 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Amit Daniel Kachhap <amit.kachhap@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Graeme Barnes <Graeme.Barnes@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Dmitry Vyukov <dvyukov@google.com>,
	Branislav Rankov <Branislav.Rankov@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 2/4] arm64: Define Documentation/arm64/elf_at_flags.txt
Message-ID: <20190322104839.GA13384@arrakis.emea.arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
 <20190318163533.26838-3-vincenzo.frascino@arm.com>
 <CADGdYn7HYcj4vxw2bCS6McdNRmWu7o13=VAQra5A1Z18JNPMXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADGdYn7HYcj4vxw2bCS6McdNRmWu7o13=VAQra5A1Z18JNPMXQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 11:52:37AM +0530, Amit Daniel Kachhap wrote:
> On Mon, Mar 18, 2019 at 10:06 PM Vincenzo Frascino
> <vincenzo.frascino@arm.com> wrote:
> > +Example of correct usage (pseudo-code) for a userspace application:
> > +
> > +bool arm64_syscall_tbi_is_present(void)
> > +{
> > +       unsigned long at_flags = getauxval(AT_FLAGS);
> > +       if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
> > +                       return true;
> > +
> > +       return false;
> > +}
> > +
> > +void main(void)
> > +{
> > +       char *addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
> > +                         MAP_ANONYMOUS, -1, 0);
> > +
> > +       int fd = open("test.txt", O_WRONLY);
> > +
> > +       /* Check if the relaxed ABI is supported */
> > +       if (arm64_syscall_tbi_is_present()) {
> > +               /* Add a tag to the pointer */
> > +               addr = tag_pointer(addr);
> > +       }
> > +
> > +       strcpy("Hello World\n", addr);
> 
> Nit: s/strcpy("Hello World\n", addr)/strcpy(addr, "Hello World\n")

Not exactly a nit ;).

> > +
> > +       /* Write to a file */
> > +       write(fd, addr, sizeof(addr));

I presume this was supposed to write "Hello World\n" to a file but
sizeof(addr) is 1.

Since we already support tagged pointers in user space (as long as they
are not passed into the kernel), the above example could tag the pointer
unconditionally and only clear it before write() if
!arm64_syscall_tbi_is_present().

-- 
Catalin

