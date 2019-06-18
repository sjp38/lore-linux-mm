Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 075DBC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C78A820873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:06:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C78A820873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590766B0005; Tue, 18 Jun 2019 11:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A018E0002; Tue, 18 Jun 2019 11:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 393088E0001; Tue, 18 Jun 2019 11:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3A706B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:06:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so10089821pgk.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h3Sefg6u6oxFoY2FeQ8eCT/Mcn2nszvs3FQjGtROTqw=;
        b=k9h5If41xWk1SdBz21ItxixaOB0AY0K42olFfnEcKBB7khFkaYFUvhi9YNbgoNPkRz
         9B7iED3arDLJjiSRsgqJPagWqmeFYL4XDfrmU12sPaE5kRdtZJf0JBJyFkc10k4LGFUT
         0ZnRa+SP8mgZm1lHF7YW+7udpBs41Symun7OiXM7E9TfVA8C3SlfA7KJ5enm6BoCHJya
         +enTTMDVy4Gl/uRZ2Ft+kndfwhnzewCIzL6NDJVTI4VC81qyxP7VQCNdcYrNwc0tqY3q
         ID6jNnHMIV0fwZ9caUxfStOuRoGNT3zM5hJRL/8eOg/jvGtkpKsx4577NkyDRC6Zx8FQ
         dnvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV7v6uedYA+bRHEq/+er0oJ6fVA/GFGzrVp+x8ppVcQ9pD23wDh
	JN0pdxD7qPXTDhM7I6XYUz6tmdI5DxSt3WYX5vydpkdooY9fisgi5i0SajoHHHMaz2sxZ1vAdh6
	0HxIr0zdEfEhUunQDaJfR2qSfQCve97dprSexhKIFEN1zi1Qm7x7lop7rKiBL6AB9EQ==
X-Received: by 2002:a62:5303:: with SMTP id h3mr38497748pfb.58.1560870408640;
        Tue, 18 Jun 2019 08:06:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCk7o5HfTe3Ba8n5cN71Y0ckoT/q94qwFdwhZB4ljcuxmV+vHk5+A6QCpIs05NUKTCYHGT
X-Received: by 2002:a62:5303:: with SMTP id h3mr38497603pfb.58.1560870406914;
        Tue, 18 Jun 2019 08:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560870406; cv=none;
        d=google.com; s=arc-20160816;
        b=hq7EIBGMWjzATXrAOFQ0bVGrr1698+8DvxAcDDPT5Nn3RVsusq6nL2HthunYKvEDwp
         /SH5RUOtWxSBuOPA2P6XZ/qFW9W3fM4OJref68H/qtanDs1fiZ+4g7WZ8ad6DkphpcNq
         uwYknWL9ait7iQjNnNDF+QTD57X5l4mFFhrSLZoC0977Utc2uc4MUeCElEk6Y64CyyUw
         qA77SwyEb73FDIyLLU7jqKuvJ+ScQwoGhwuPKjInljxuItYJnn98WaQrxpHScXHealYQ
         OnwbvyKXYNDJ7fceGtUVIiTtkuRnu+VbHGWZ0TKLlZBt5kNXsBXphtTRrJWv9dliVAAh
         bY5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=h3Sefg6u6oxFoY2FeQ8eCT/Mcn2nszvs3FQjGtROTqw=;
        b=l49I6SLWYk1uUjpS6c0HJHKlcVMDlyq9xNgZUDBc8DTXPXJDQL6V2wJZUxmljGL0S6
         akBGWSqzhYL/hYIgO4XEq4czE1wIGRDhpOh1364M3XgsQ2mPY3WqWSz0uT1HR+yhdOvU
         XT6Ww7R/OIX9+lTbCh6qxmWBKNpSHL/zHcVJuKgh4rA05/VSja/nD6KKKzH/SsXF/txG
         BhLZuuFzdv1f1IMHDLfb1BVELlpc+1pYn2wOqMtP04dlzAcl4d23/24c+6LqLYIdR9rW
         KlAUfyRZao2vpC5kG2vo5SjyDDW0i9CfkN+5KbITIqv+3DGeoezi0sGtABQ6/V/WEvUt
         IuYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f9si417099pgg.450.2019.06.18.08.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 08:06:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 08:06:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="160085055"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga008.fm.intel.com with ESMTP; 18 Jun 2019 08:06:47 -0700
Message-ID: <d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Florian Weimer <fweimer@redhat.com>, Thomas Gleixner
 <tglx@linutronix.de>,  x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,  linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan
 Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Date: Tue, 18 Jun 2019 07:58:37 -0700
In-Reply-To: <20190618133223.GD2790@e103592.cambridge.arm.com>
References: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	 <20190611114109.GN28398@e103592.cambridge.arm.com>
	 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	 <20190612093238.GQ28398@e103592.cambridge.arm.com>
	 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
	 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
	 <20190618091248.GB2790@e103592.cambridge.arm.com>
	 <20190618124122.GH3419@hirez.programming.kicks-ass.net>
	 <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
	 <20190618125512.GJ3419@hirez.programming.kicks-ass.net>
	 <20190618133223.GD2790@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 14:32 +0100, Dave Martin wrote:
> On Tue, Jun 18, 2019 at 02:55:12PM +0200, Peter Zijlstra wrote:
> > On Tue, Jun 18, 2019 at 02:47:00PM +0200, Florian Weimer wrote:
> > > * Peter Zijlstra:
> > > 
> > > > I'm not sure I read Thomas' comment like that. In my reading keeping the
> > > > PT_NOTE fallback is exactly one of those 'fly workarounds'. By not
> > > > supporting PT_NOTE only the 'fine' people already shit^Hpping this out
> > > > of tree are affected, and we don't have to care about them at all.
> > > 
> > > Just to be clear here: There was an ABI document that required PT_NOTE
> > > parsing.
> > 
> > URGH.
> > 
> > > The Linux kernel does *not* define the x86-64 ABI, it only
> > > implements it.  The authoritative source should be the ABI document.
> > > 
> > > In this particularly case, so far anyone implementing this ABI extension
> > > tried to provide value by changing it, sometimes successfully.  Which
> > > makes me wonder why we even bother to mainatain ABI documentation.  The
> > > kernel is just very late to the party.
> > 
> > How can the kernel be late to the party if all of this is spinning
> > wheels without kernel support?
> 
> PT_GNU_PROPERTY is mentioned and allocated a p_type value in hjl's
> spec [1], but otherwise seems underspecified.
> 
> In particular, it's not clear whether a PT_GNU_PROPERTY phdr _must_ be
> emitted for NT_GNU_PROPERTY_TYPE_0.  While it seems a no-brainer to emit
> it, RHEL's linker already doesn't IIUC, and there are binaries in the
> wild.
> 
> Maybe this phdr type is a late addition -- I haven't attempted to dig
> through the history.
> 
> 
> For arm64 we don't have this out-of-tree legacy to support, so we can
> avoid exhausitvely searching for the note: no PT_GNU_PROPERTY ->
> no note.
> 
> So, can we do the same for x86, forcing RHEL to carry some code out of
> tree to support their legacy binaries?  Or do we accept that there is
> already a de facto ABI and try to be compatible with it?
> 
> 
> From my side, I want to avoid duplication between x86 and arm64, and
> keep unneeded complexity out of the ELF loader where possible.

Hi Florian,

The kernel looks at only ld-linux.  Other applications are loaded by ld-linux. 
So the issues are limited to three versions of ld-linux's.  Can we somehow
update those??

Thanks,
Yu-cheng

