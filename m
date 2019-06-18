Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B03AC31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E19DD214AF
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E19DD214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1618E0002; Tue, 18 Jun 2019 12:20:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A1708E0001; Tue, 18 Jun 2019 12:20:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66A758E0002; Tue, 18 Jun 2019 12:20:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 165138E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:20:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so21955206edo.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:20:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=35xcTdgw1ipLMWHY+uaNl0cVLtglgLWKsfWDwYrtOVM=;
        b=oulmXKY+fdDoVJhHC2ed2vLDAGxgG7VfkxW1Hd5D/4YHO5tnj8NDiJRlKLGdEwqOxb
         /K1HSOlOIL8GTaw6xFEvAO5N2Lp3PB2fhKaLQIUdCzDfRdQXbMfcTRzanZIr+9FMqKcJ
         Eih6aeX3QrZh+yh9pXmQilANQD2QGSEsNEJXlih/gCCw+aMh3B/n4I6gY6Bu/RCdv8mv
         zyjlMMwT/jERDSLXL0q6L9tjyOyIGGULkZ2Eqsd3Xm2AcekREml2aQIdS1kLxff/yAgX
         MsBIgMffcDPRSq3qLfZ18MGJeTsFA5QOC8EoGQEkAqMvdvp4lOFcY3zggiHIF1AvA0lH
         06hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAU4VjTCkO8oZRsK6c6PPKZ68NdooVpxsalSaR1I14JFtj1UH49p
	7EHBo7k2+reH1xSBinNPc9lDDQ1H+WK3cunLrCKG+hSYR7Qn0rHR1x/z4ZQn8vlbUcLmELaqsJQ
	QVartzSehGYICRaGROXqp8nGwBMbre9ngcQ9KIVLD9h1hXTIH7PNOFhJnn/wHYrOPfw==
X-Received: by 2002:a17:906:644c:: with SMTP id l12mr51204370ejn.199.1560874814636;
        Tue, 18 Jun 2019 09:20:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQNkIvnkgK6DQ6inYa89f0BX816kTB0qMQ2kqLH1EPqHvH0JGSgzlI8IWyhEBa72OPHT/k
X-Received: by 2002:a17:906:644c:: with SMTP id l12mr51204295ejn.199.1560874813734;
        Tue, 18 Jun 2019 09:20:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560874813; cv=none;
        d=google.com; s=arc-20160816;
        b=OhmE8Of5/WEusq4mJY9O0j4pEb2a7lHjlhihXRXIWcJod543RaAFSo6XEEFHkMYZxn
         nlLNw+LXH+Mn+J78tpddYgzRtiRVcqYoxOxhLeXeWezpqGmzS7DY62+j8+ZADOkgOuJZ
         YrbcsxjNdiWpKSSRBf+QJszOj5qRFl3PYvnLV+bJ+bJ+tioFcaWfqUzX1yiifoAaE+z4
         Q6xRVbD85TwX6lwFVxqKcSb5FXfOocbSujIqZvgnMD0FWtBxcsJvG7r8h9M0TTbDbOrT
         a5j6EWn8nhtUJ3tWKhx0osrbg3T7LRh1nTakEy0ZaKYGEgSvVfV3jsZKrWVKeGXu1pSF
         4fKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=35xcTdgw1ipLMWHY+uaNl0cVLtglgLWKsfWDwYrtOVM=;
        b=DmuuZKJIkx3gXgfEtCLTwNTxroMwnL6JFDan8uXrTVhSOM/LPvXWB4pEJpUrEWnXap
         9aLQ1OOIVEnQpbJYH2+9YvscWoalviQW82sgARhPTHfja4Hee6+VdOlh3LXCBcMPP425
         x+ari8HchrD6NLAJuAJv9G+jgAAW1QQzHuMQozIy+70sFjSXm8/MIfT+8Vvh2tt2Cb3w
         m33v4Bvxq5le2BigqTpRvMu2jC3NbXhCAgR60E6qsecUrCqVP1OWywMknZf+b6T9oNJi
         9aWu/rYSPWGmgaoedrQu9d59l3MWDJ0UP8RZcJLkrC8laZthknJtG2BC10I5UfBg8SLp
         whGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id pj23si9517528ejb.251.2019.06.18.09.20.13
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 09:20:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B4DBB344;
	Tue, 18 Jun 2019 09:20:12 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 284273F246;
	Tue, 18 Jun 2019 09:20:09 -0700 (PDT)
Date: Tue, 18 Jun 2019 17:20:07 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Florian Weimer <fweimer@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
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
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618162005.GF2790@e103592.cambridge.arm.com>
References: <20190618091248.GB2790@e103592.cambridge.arm.com>
 <20190618124122.GH3419@hirez.programming.kicks-ass.net>
 <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
 <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
 <20190618133223.GD2790@e103592.cambridge.arm.com>
 <d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
 <87pnna7v1d.fsf@oldenburg2.str.redhat.com>
 <1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
 <87blyu7ubf.fsf@oldenburg2.str.redhat.com>
 <b0491cb517ba377da6496fe91a98fdbfca4609a9.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0491cb517ba377da6496fe91a98fdbfca4609a9.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 09:00:35AM -0700, Yu-cheng Yu wrote:
> On Tue, 2019-06-18 at 18:05 +0200, Florian Weimer wrote:
> > * Yu-cheng Yu:
> > 
> > > > I assumed that it would also parse the main executable and make
> > > > adjustments based on that.
> > > 
> > > Yes, Linux also looks at the main executable's header, but not its
> > > NT_GNU_PROPERTY_TYPE_0 if there is a loader.
> > > 
> > > > 
> > > > ld.so can certainly provide whatever the kernel needs.  We need to tweak
> > > > the existing loader anyway.
> > > > 
> > > > No valid statically-linked binaries exist today, so this is not a
> > > > consideration at this point.
> > > 
> > > So from kernel, we look at only PT_GNU_PROPERTY?
> > 
> > If you don't parse notes/segments in the executable for CET, then yes.
> > We can put PT_GNU_PROPERTY into the loader.
> 
> Thanks!

Would this require the kernel and ld.so to be updated in a particular
order to avoid breakage?  I don't know enough about RHEL to know how
controversial that might be.

Also:

What about static binaries distrubited as part of RHEL?

A user would also reasonably expect static binaries built using the
distro toolchain to work on top of the distro kernel...  which might
be broken by this.


(When I say "broken" I mean that the binary would run, but CET
protections would be silently turned off.)

Cheers
---Dave

