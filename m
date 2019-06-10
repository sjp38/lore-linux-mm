Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B09D8C31E43
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:57:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 749A920859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 749A920859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 237276B026F; Mon, 10 Jun 2019 12:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E6BE6B0270; Mon, 10 Jun 2019 12:57:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AFA06B0271; Mon, 10 Jun 2019 12:57:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B32AD6B026F
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:57:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so16257798ede.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dqpGru3cDb67KYv0vCNiRWA48ZCMlc9F7dAnoJihJ2o=;
        b=Vl3hEqI4Gf/JF8vW39HhQxgNoesvcfczsPafsd+jex3b+k0VvD8DnHUSqOQQFjR893
         Y6p+INFuGcSxpRjy8U+IiTDxZ0LfvZbVtCjUbCYQCzCcWKdUcdNsuoedzito6g6TcTy9
         RfdA3vFgSBHiaS6muvqemCivhz+7dZoyVJmUxAmvatg30yb594k1L7jMzWbTUAhjxj7I
         jTLl2Tu+mkeE/9hDWpKEsFJP4Pkawookt7gEMHrXKlZTaRav1VAxMLKee14N7PpRr5hy
         pXV/lYaptUZoXus36ytxV84w0OvwuRpF4/+w2Lxf3rTxc17NcY33GMY4aglM9wFPiJev
         F6tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAXh6kzysK1Od03yri/QsWNyuaL4IqtoBHfzrmqROWRstTKmNzH4
	bVntg9xs/ERmwjs/xCnbUdeubpUMB6slUQdRAXDT+StA6czfut+Mqdv25Gcws/AatKAckmBKbvE
	OlSAhwowm9EbeOCYa5MqEqp9RGTu4i6CPW4C9K0rf2ws1mZQc6GxmgEihvmdQYJHl5Q==
X-Received: by 2002:a17:906:d215:: with SMTP id w21mr62290898ejz.122.1560185859282;
        Mon, 10 Jun 2019 09:57:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcVtS3LdPb9+JTushNWdmM4SFaYDK07QfceG8bZVvs73TtuP65HSnJ2I68glHWwbIYhJKF
X-Received: by 2002:a17:906:d215:: with SMTP id w21mr62290809ejz.122.1560185858052;
        Mon, 10 Jun 2019 09:57:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560185858; cv=none;
        d=google.com; s=arc-20160816;
        b=fOpncQtHrS5sdLWXQbY9lM5YfQHKIQTzoMNwVn+C2ZI5lFXSQF5kTMQ+bGaeEF/vaD
         Tx1Mqdti+cEAbc4F+xOWpAPQlru1tbQY3Vjk+Sn5DIIZeP8VI+xr18Zi1yVtJGX0YLL/
         9hNbMuAtXwcYwQBT0Dz3nnVV1JybdurYhd6DeJ90CmXIKHS8XwSfSQzM1n/LYnZKnr23
         6rvbKHiJ0xLRPRZDviv5N+YDxRhcDl4dmijDJmenxBb7qaP1BrRdzASdUwXcqF+pBSN3
         K+ETLnNrR2E+Rw6WDkRzBRWR9YxdA0TsZT6BMI0h6fWJa8Whl2+npS7eAhhJSkjebjbp
         9nPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dqpGru3cDb67KYv0vCNiRWA48ZCMlc9F7dAnoJihJ2o=;
        b=I89PwrEi/SJ5MGMVhJZEXV1wmXLaOSIvs5Xlb7Z/sn/51uVLAKsxqVQB0ppN77xLjc
         GZ646hlISPBOo+bmuDT1XGv1cS07FFA2IwzKgz/Vm/UBkQVlRdUjdGHqf85oxJ/lkEc4
         B2UMFjZ39X/I9PeYjBlaxSdOkJPorXmcItx5Nn1kRytYtmWIhxGIjKlMZcXAjlQJ/17g
         XBtAAIrWJuRM1aHK1vRsWS5TzjIy20tnnR5GLlTrRcU5ZCTict7Au667fNmn5HFDQ43Y
         j1ZWZ/rnEbNZ8tOJQpEAUGoWXvzDTLu7ZdHi6wpTUSCeuNSAm9D4aDkX9lixlT61SvuQ
         EzBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b7si6879038ejb.160.2019.06.10.09.57.37
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 09:57:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 027D7337;
	Mon, 10 Jun 2019 09:57:37 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6B75A3F246;
	Mon, 10 Jun 2019 09:57:33 -0700 (PDT)
Date: Mon, 10 Jun 2019 17:57:31 +0100
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
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190610165730.GM28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 09:29:04AM -0700, Yu-cheng Yu wrote:
> On Fri, 2019-06-07 at 19:01 +0100, Dave Martin wrote:
> > On Thu, Jun 06, 2019 at 01:06:41PM -0700, Yu-cheng Yu wrote:
> > > An ELF file's .note.gnu.property indicates features the executable file
> > > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > > 
> > > With this patch, if an arch needs to setup features from ELF properties,
> > > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> > > arch_setup_property().
> > > 
> > > For example, for X86_64:
> > > 
> > > int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> > > {
> > > 	int r;
> > > 	uint32_t property;
> > > 
> > > 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> > > 			     &property);
> > > 	...
> > > }
> > 
> > Although this code works for the simple case, I have some concerns about
> > some aspects of the implementation here.  There appear to be some bounds
> > checking / buffer overrun issues, and the code seems quite complex.
> > 
> > Maybe this patch tries too hard to be compatible with toolchains that do
> > silly things such as embedding huge notes in an executable, or mixing
> > NT_GNU_PROPERTY_TYPE_0 in a single PT_NOTE with a load of junk not
> > relevant to the loader.  I wonder whether Linux can dictate what
> > interpretation(s) of the ELF specs it is prepared to support, rather than
> > trying to support absolutely anything.
> 
> To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
> logical choice.  And it breaks only a limited set of toolchains.
> 
> I will simplify the parser and leave this patch as-is for anyone who wants to
> back-port.  Are there any objections or concerns?

No objection from me ;)  But I'm biased.

Hopefully this change should allow substantial simplification.  For one
thing, PT_GNU_PROPERTY tells its file offset and size directly in its
phdrs entry.  That should save us a lot of effort on the kernel side.

Cheers
---Dave

