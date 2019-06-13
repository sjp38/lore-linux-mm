Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 000ADC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:26:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2E52147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:26:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2E52147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4859D6B026A; Thu, 13 Jun 2019 09:26:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43CC86B026B; Thu, 13 Jun 2019 09:26:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323E86B026C; Thu, 13 Jun 2019 09:26:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA0DF6B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:26:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so30873358eda.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:26:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UNBuwHu5ogeUMBOwYOqLU+Ps9l58XgB4dMd5pLPyQwQ=;
        b=QF3YtNPUCjLIVUFUov08t5mAi2A6VKkTro88deSfItt8U8HtamNXA+OQhxc2bD545U
         ueDUmLG/rh5RQdxke/zEo9AXKevnffo/+IwrRTNPqDN3oOrqlIEMB0ZAJY7FgbtMKbPy
         QGKKe68PRcgkW0rvgDUTaP/l5aeHYR6vqoKnEy0m9q5r1mF6qKFzm/ry0zJ/974N3+ou
         TfbMCz/K/vzZWdoSBotRwP8M9njWKimPbwMq/889NA0qivEZT5Kl1qopx/mZwUQIkcCo
         7tCmSDJ2ST6tH/FWEyyp7Q29KEQRxAWSqEx+ycvtRsO7Z/VLGEUTO1oYQX91LIPTSFFk
         6rzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAVUHSvTErW41kSd+lZD/xpcMtBAh7QXTiQCEFbLfimNO/OnRJ59
	yjtOe7y0/soW8Nxg9JwiHZBkEB5Yj+OGXXYeBGwNxlwc8ZjnFzl+gVix39jXLtUGrMCvlmG72Lh
	o9K2YHxUp/zVKrzUPoT++KrF+VxmE9M9CJL188v31wRqqXSDnAaD2yWkO5jeBheHDVg==
X-Received: by 2002:a50:92a5:: with SMTP id k34mr68186725eda.90.1560432391388;
        Thu, 13 Jun 2019 06:26:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXQXAL5W3sTw0+eK/cgcCeToXF+6aQdTOL7WQ3Sx0Uy1nG6sWwlMFku7y9tB2zxm+DOOuD
X-Received: by 2002:a50:92a5:: with SMTP id k34mr68186632eda.90.1560432390521;
        Thu, 13 Jun 2019 06:26:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560432390; cv=none;
        d=google.com; s=arc-20160816;
        b=Ll60KLUPUhdqqVVVnFTN12dV2qmm3ReEM3Ewp9kJZ2Tw4bhu/Sj0AXKTWfBLdkjxWN
         I1ABmvrfh19hLHdmEprVGpeySazZD5L3RdMXSVpcc1Uq7yJEdCcLJ291Xn8wKYu2uvHF
         u1ob3tB8q4KjZ+xtF+3IaMK6MnRn5amWdYscYEAQ7LOhkP1a97mgPf+9bXsuEjex2BwD
         XlhloAQC/mb86Q2gROnbkNU6/sFHeqYmYo3ZDQWUE58R/aCgWrw1WbYfaromYAhgSfFf
         vf3Vvn4Ih1Ss6ZreSIyLFwbuYQBvH800WxcAw17oiFXe/qYS3YzriRuuE4x6DxGvhRGW
         X+8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UNBuwHu5ogeUMBOwYOqLU+Ps9l58XgB4dMd5pLPyQwQ=;
        b=dosVVgQB5XC2R1sZeNni5RBAUj42I0sjfLS1PGIXjtReVLrSU+WP8Wi0OfFNkd4tpR
         53mmdh9VWQsgEnDQkDOB7PEXVbo0jHAFthDywSvCALs9bBNpjONQm/U7C/ySuBBrD+p+
         W8fyHkyNnH/69BKz6nr/fnXOBeALKHRgTKxWcbcPpI+fPJAI2iT8wvYzspSbDJzExyxi
         8/PZ8z2S+UCaf65aokA9IdkQwd1MJ7QSBDR4pl6Szfx9eu680XSPyBtazkCALglnpMT9
         iAclkLb8wjXdrbSEIqJsFqizkmU9FuWR0jPw9HdPKFbWPZi5Hg/TxXUViGurECLc3hCG
         33XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r12si2056753ejj.133.2019.06.13.06.26.30
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 06:26:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7478D2B;
	Thu, 13 Jun 2019 06:26:29 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DD1273F73C;
	Thu, 13 Jun 2019 06:26:25 -0700 (PDT)
Date: Thu, 13 Jun 2019 14:26:23 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Florian Weimer <fweimer@redhat.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190613132623.GA28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
 <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <b8fb6626a6ae415fac4d5daa86225e4c68d56673.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8fb6626a6ae415fac4d5daa86225e4c68d56673.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:04:01PM -0700, Yu-cheng Yu wrote:
> On Wed, 2019-06-12 at 10:32 +0100, Dave Martin wrote:
> > On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> > > On Tue, 2019-06-11 at 12:41 +0100, Dave Martin wrote:
> > > > On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
> > > > > * Yu-cheng Yu:
> > > > > 
> > > > > > To me, looking at PT_GNU_PROPERTY and not trying to support anything
> > > > > > is a
> > > > > > logical choice.  And it breaks only a limited set of toolchains.
> > > > > > 
> > > > > > I will simplify the parser and leave this patch as-is for anyone who
> > > > > > wants
> > > > > > to
> > > > > > back-port.  Are there any objections or concerns?
> > > > > 
> > > > > Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
> > > > > the largest collection of CET-enabled binaries that exists today.
> > > > 
> > > > For clarity, RHEL is actively parsing these properties today?
> > > > 
> > > > > My hope was that we would backport the upstream kernel patches for CET,
> > > > > port the glibc dynamic loader to the new kernel interface, and be ready
> > > > > to run with CET enabled in principle (except that porting userspace
> > > > > libraries such as OpenSSL has not really started upstream, so many
> > > > > processes where CET is particularly desirable will still run without
> > > > > it).
> > > > > 
> > > > > I'm not sure if it is a good idea to port the legacy support if it's not
> > > > > part of the mainline kernel because it comes awfully close to creating
> > > > > our own private ABI.
> > > > 
> > > > I guess we can aim to factor things so that PT_NOTE scanning is
> > > > available as a fallback on arches for which the absence of
> > > > PT_GNU_PROPERTY is not authoritative.
> > > 
> > > We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> > > version?) to PT_NOTE scanning?
> > 
> > For arm64, we can check for PT_GNU_PROPERTY and then give up
> > unconditionally.
> > 
> > For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> > of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> > version doesn't tell you what ELF ABI a given executable conforms to.
> > 
> > Since this sounds like it's largely a distro-specific issue, maybe there
> > could be a Kconfig option to turn the fallback PT_NOTE scanning on?
> 
> Yes, I will make it a Kconfig option.

OK, that works for me.  This would also help keep the PT_NOTE scanning
separate from the rest of the code.

For arm64 we could then unconditionally select/deselect that option,
where x86 could leave it configurable either way.

Cheers
---Dave

