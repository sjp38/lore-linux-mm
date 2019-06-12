Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B7CC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D535208C4
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:32:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D535208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDBE36B0005; Wed, 12 Jun 2019 05:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB21C6B0006; Wed, 12 Jun 2019 05:32:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7A376B0007; Wed, 12 Jun 2019 05:32:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5146B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:32:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so25005284eda.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:32:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RHcRSzMqA/IjzdsrAxM4zzw7JZQk8y0NNwzKJqIELgs=;
        b=hy3IgFVYmc+NBhVecOEUewg+gp4dSovkV0/+OAyT4B8pv2fl0xtmOhp41YiN7I2lJJ
         mu1wkFZOq2Jll6mbHtqiAzzq3Ns1wTPTN7DZRziuTY2dJVISHAcPuLYIHAXWTbvRTHPN
         pkB4Cvt1CSLpR6Zcy+btm2AANfDAZRGigwBKRPDzwN/jWOUNqc49zMQAyijYQ4Yxqv9X
         IfiHjlBdcjEdfITBoeWifg/+tJNpAgPLccsLpMaUmG85goeKrNrxi6FoImtaLFmcV39y
         dbgF008eLkw5D7GkTGpjjMHSO2A/Udq0Gth8g0+WegFOlGGbqjyt+q9JWEEsYKnmZfhr
         C/Nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWCbXNKieCqu+ZVn74/neirB4CcrlbCD9fTnPDfbD9sG/jEQN/Y
	ha9aaA2u3O3E32fKs3n0yAy2mQSA48xymPUx8e6/pMP6Vd5/MuTVV4xj2oEqyxgz65OdcgK2a5w
	lQY04ULTo5YJcmT2fbfiRjrfb0+WpAjDO32Gt2EzDab67Uw4KX/oKq6FEnqhcr95JdQ==
X-Received: by 2002:a17:906:1cc6:: with SMTP id i6mr59497769ejh.100.1560331967052;
        Wed, 12 Jun 2019 02:32:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgcCxDzscwgjda1MEhWQFxtVR4DAiZOVPcmsm6rwFXZQIiauKpm8bUO5qAWbOSWvy4fSDm
X-Received: by 2002:a17:906:1cc6:: with SMTP id i6mr59497659ejh.100.1560331965517;
        Wed, 12 Jun 2019 02:32:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560331965; cv=none;
        d=google.com; s=arc-20160816;
        b=kzhS1ru6+wyfL8imxn/EReIXo/JvRfA7iNhJ1hdCKd6X/At0MHOEYIeVP2dKXrNRyF
         ILtlI5bQvWDbm2D2RZ8bXi4kjR8ZwsmFIYB8DEfTP1DRm4igemnTu72X7yG7mbnMhOWI
         oBks8EAxqPap8eVKmrlGdq9MxeCnNBbbqnEbUQ67jFpi1f7AR2JO/pxm2tKxA691tpPE
         8926RxglDoL+FWMmxN5T4MKWh+uoSqzg8WB/o4DrJizB+dh+iSXxDzq8cDRGHmUOV384
         eXudfyTfeIDy3EJGppcDLg5tNblaMga9YNg1wPw5FELLjm6S5VVlxJARBuO+iQQvYctz
         ov6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RHcRSzMqA/IjzdsrAxM4zzw7JZQk8y0NNwzKJqIELgs=;
        b=HTSP/ZiBxslm5j6Q6xjDAlO01JuBvMOTnF1U+9qWBRt9CB+0F8FTdBuuyjFEPlcugj
         QTlWFMyixHxQgI9D7oKi2e6GMEUZXsi5+K7uUybRBLuKdwEWZ1DpOx7hn7u64Pb3LZo2
         NmtTDek831fogV3m7HavXtkRl//iK4+cfbrPsHiIr9ADrpkoWrg9OIyaerQm79MUMPMp
         EGnSFR+0JFqYdgdtRwqffoDsYXSb1yaiwVDfepD978SE9WN0lBV/dr77nud5vsFotai1
         Fhz2iJY92VdVVB79XAArOMPmfIIPHHN2dhMqPZlVShKDeVpm3cbq/UXhUVB3kWw1VtzN
         5i3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n9si14035514edn.343.2019.06.12.02.32.45
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 02:32:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 871CE337;
	Wed, 12 Jun 2019 02:32:44 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EEAC83F246;
	Wed, 12 Jun 2019 02:32:40 -0700 (PDT)
Date: Wed, 12 Jun 2019 10:32:38 +0100
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
Message-ID: <20190612093238.GQ28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> On Tue, 2019-06-11 at 12:41 +0100, Dave Martin wrote:
> > On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
> > > * Yu-cheng Yu:
> > > 
> > > > To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
> > > > logical choice.  And it breaks only a limited set of toolchains.
> > > > 
> > > > I will simplify the parser and leave this patch as-is for anyone who wants
> > > > to
> > > > back-port.  Are there any objections or concerns?
> > > 
> > > Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
> > > the largest collection of CET-enabled binaries that exists today.
> > 
> > For clarity, RHEL is actively parsing these properties today?
> > 
> > > My hope was that we would backport the upstream kernel patches for CET,
> > > port the glibc dynamic loader to the new kernel interface, and be ready
> > > to run with CET enabled in principle (except that porting userspace
> > > libraries such as OpenSSL has not really started upstream, so many
> > > processes where CET is particularly desirable will still run without
> > > it).
> > > 
> > > I'm not sure if it is a good idea to port the legacy support if it's not
> > > part of the mainline kernel because it comes awfully close to creating
> > > our own private ABI.
> > 
> > I guess we can aim to factor things so that PT_NOTE scanning is
> > available as a fallback on arches for which the absence of
> > PT_GNU_PROPERTY is not authoritative.
> 
> We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> version?) to PT_NOTE scanning?

For arm64, we can check for PT_GNU_PROPERTY and then give up
unconditionally.

For x86, we would fall back to PT_NOTE scanning, but this will add a bit
of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
version doesn't tell you what ELF ABI a given executable conforms to.

Since this sounds like it's largely a distro-specific issue, maybe there
could be a Kconfig option to turn the fallback PT_NOTE scanning on?

Cheers
---Dave

