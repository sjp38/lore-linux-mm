Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97DCDC3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:02:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67427206BB
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:02:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67427206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE0216B0010; Tue, 20 Aug 2019 06:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E90F26B0269; Tue, 20 Aug 2019 06:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA7A76B026A; Tue, 20 Aug 2019 06:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id B9C766B0010
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:02:18 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 545841CBE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:02:18 +0000 (UTC)
X-FDA: 75842365956.07.arm58_3119ad640cd32
X-HE-Tag: arm58_3119ad640cd32
X-Filterd-Recvd-Size: 3515
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:02:17 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E6723344;
	Tue, 20 Aug 2019 03:02:15 -0700 (PDT)
Received: from arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5C5113F706;
	Tue, 20 Aug 2019 03:02:12 -0700 (PDT)
Date: Tue, 20 Aug 2019 11:02:10 +0100
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
	Borislav Petkov <bp@alien8.de>,
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
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v8 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190820100208.GO10425@arm.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
 <20190813205225.12032-23-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813205225.12032-23-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:52:20PM -0700, Yu-cheng Yu wrote:
> An ELF file's .note.gnu.property indicates features the executable file
> can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> 
> With this patch, if an arch needs to setup features from ELF properties,
> it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and specific
> arch_parse_property() and arch_setup_property().
> 
> For example, for X86_64:
> 
> int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> {
> 	int r;
> 	uint32_t property;
> 
> 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> 			     &property);
> 	...
> }
> 
> This patch is derived from code provided by H.J. Lu <hjl.tools@gmail.com>.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

[...]

For the hell of it, I tried implementing an alternate version [1] that
tries to integrate into the existing ELF loader more directly.

This may or may not be a better approach, but tries to solve some
issues such as not repeatedly reading and parsing the properties.

Cheers
---Dave


[1] [RFC PATCH 0/2] ELF: Alternate program property parser
https://lore.kernel.org/lkml/1566295063-7387-1-git-send-email-Dave.Martin@arm.com/

