Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74888C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38B372084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:12:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38B372084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF25F8E0002; Tue, 18 Jun 2019 05:12:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3288E0001; Tue, 18 Jun 2019 05:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A69278E0002; Tue, 18 Jun 2019 05:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0368E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:12:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so20396911edt.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B5unngtNz5I4UQ27+8Qxx0YTxNw7SawuVoye9McdKBg=;
        b=jLQDXW5Ts10YVutg94mSxVveVnMap6lOpgbFuS04lItHFAuw36qAgUwuMpBhSI5L5B
         MUyxy4J7txDdM5iuAmmjP08M1DuQCJTonuI54xtIJXrAqHMvwVPsPX5Sn/O+UOgBxnfA
         xfdwMnBcwAbfdwxlcAE0kmNig3RHuCSch2R8YrhmtBNB8Yfp7SyKHF5SxH+exV5X7HeA
         iTx0bgFm/+NqGtytuv9Qu7+kzkmV6hxvugsWZKhBinzFrvZ1uLiboBLZJiQKItpGkHla
         7alwkT9qjzOqeb7PL9o+DH4a5/iqi4XujEXPdLSgG7AGFSikJyNxyUO9XFJ8j6fzoWdo
         SQHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUO1vdDiRgXHgpijuCo5TagkuhgHvGcltVyZAmKxMWSbAgYQv93
	Vh4xHBtpB/EpHwomb3qWMDjHhLSOdOJiNZc5P9XnTtfn1RJ7Sv0gW+ybA9wdvPiYh+eLTVJhO0d
	Wfr9JNk6v6zDnvQH04rPbae4PTZg/Y9NeZiYWgo42f0+NRCbNFpdUcNIgNNdRk6mj4A==
X-Received: by 2002:a17:906:2101:: with SMTP id 1mr45255180ejt.182.1560849177915;
        Tue, 18 Jun 2019 02:12:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydZFx5PHI3lhMPgJO0iyFRtuGWWa/84NDBC5nQnNox47vpkU26Z9Bv6VcVz8e35fX6uc//
X-Received: by 2002:a17:906:2101:: with SMTP id 1mr45255130ejt.182.1560849177164;
        Tue, 18 Jun 2019 02:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560849177; cv=none;
        d=google.com; s=arc-20160816;
        b=JlZjMGgeb5Evwpv1x3AMYG3ccEerWOKHql8iEPrWoEvkXS8PV16olfyFG4vqQfW1NX
         +Tq1ys/y0N0Rgr7iWfDvYG/XHmB1+pY2YAAKUC5FSXdw5nKXwT+X7n03YSUEIy/9or6n
         3mfTJhpxKUlU9Gp04a+fbp6pBG2Mitx+pOLpc2aiqDUc6Ashml+zF++MWOTTR4pP1jPZ
         L2HMDr2OVrghN4jGkYblLg3+madl6yD+5IZWXfYUe2GzwA7ZMCJ3IW4Suz0RB54I23yX
         0YYISkqsDKsmvYCdHmPEVZL0sCRJ7Vn8vRq8PdlssY2J93OcLpxkXPSB02e4OTndDbdh
         zvjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B5unngtNz5I4UQ27+8Qxx0YTxNw7SawuVoye9McdKBg=;
        b=bLsSrCA9n6CTP3SOwGl7vli5SysUxyXbnG2tR4TDOPaA/1m+pWxhdCt+LYrrT9W1iW
         agVVdRKF77BxEesSiNvbzQNdv/Ucjxkd75LEDy9Wzmc7WM7E5YvIndUOcJO6GVYZjvfG
         jwLvihow054feZS+8di2oJ8IaSeSL9HBHjBL/jeQH0lT56g0ikb0AA8+7PZQSbSbbc4k
         A/bXordmUaSuJj4OimR0AjbCKuPeXieArpSRWr/5WAAapFQT4o8mDssAXmikrc+J27Dc
         kEKEvObvoM59qxAm1JA3GvicHQzC0J8c9vX84Do4vKwDuetdXcoevF7xX4i5zI+tIPXM
         A4vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e44si10262217edd.352.2019.06.18.02.12.56
        for <linux-mm@kvack.org>;
        Tue, 18 Jun 2019 02:12:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0D7DD344;
	Tue, 18 Jun 2019 02:12:56 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6F3EB3F246;
	Tue, 18 Jun 2019 02:12:52 -0700 (PDT)
Date: Tue, 18 Jun 2019 10:12:50 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Florian Weimer <fweimer@redhat.com>,
	Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
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
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618091248.GB2790@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
 <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:20:40PM +0200, Thomas Gleixner wrote:
> On Mon, 17 Jun 2019, Florian Weimer wrote:
> > * Dave Martin:
> > > On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> > >> We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> > >> version?) to PT_NOTE scanning?
> > >
> > > For arm64, we can check for PT_GNU_PROPERTY and then give up
> > > unconditionally.
> > >
> > > For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> > > of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> > > version doesn't tell you what ELF ABI a given executable conforms to.
> > >
> > > Since this sounds like it's largely a distro-specific issue, maybe there
> > > could be a Kconfig option to turn the fallback PT_NOTE scanning on?
> > 
> > I'm worried that this causes interop issues similarly to what we see
> > with VSYSCALL today.  If we need both and a way to disable it, it should
> > be something like a personality flag which can be configured for each
> > process tree separately.  Ideally, we'd settle on one correct approach
> > (i.e., either always process both, or only process PT_GNU_PROPERTY) and
> > enforce that.
> 
> Chose one and only the one which makes technically sense and is not some
> horrible vehicle.
> 
> Everytime we did those 'oh we need to make x fly workarounds' we regretted
> it sooner than later.

So I guess that points to keeping PT_NOTE scanning always available as a
fallback on x86.  This sucks a bit, but if there are binaries already in
the wild that rely on this, I don't think we have much choice...

I'd still favour a Kconfig option to allow this support to be suppressed
by arches that don't have a similar legacy to be compatible with.

Cheers
---Dave

