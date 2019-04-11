Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23A01C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 09:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC6B72084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 09:56:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC6B72084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40DC96B026D; Thu, 11 Apr 2019 05:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397026B026E; Thu, 11 Apr 2019 05:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 260016B026F; Thu, 11 Apr 2019 05:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCDA76B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:56:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p90so2791411edp.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 02:56:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4ymNHUcnRR403Tww5/AYF7KiH2+Ihr2L9b0TzxF5wcU=;
        b=dALNovYquapy6E2k0I+LZNjBUN+jhUPbg26vGJlolvY6bIn+taxHtMaEHq3w0Ev6vf
         qXulsp9coPIzayqVclX8fQN7/phcKyQLuJSUplhkgOZWfHZz7CkjuNz/jC/6Dhh8N722
         wzpCPyKbzEruxWc8dC+4U1CKxESbOgRsZx85I56W38C6941Lko3ESmX6pd0F1FQXqYe6
         431T+9LI94fQGMU3OOC+zedbyUZOx8syU+mElglRwhmPxV8qqvjkMeoxjj53gc9k2aws
         8Prn6omx+6B+h6BxzhkE1lb0Y9FqKBbtCXjpDpE9UpDl3GoJUKtV9htCTa+2BG2nz123
         MBYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVcFY7Y/kuERuHtBRwJoZzHBuFaHVNu8Ndco5Pfb0/HHBS3q9C0
	KqSdvgyGNOkZEuQ1HVOto1Xi9XJuKrUXDrodGZVtFCpnCOlK5fh8Vi/jkRCKlr0Ygs3IvPRp91h
	X3hQoRLP9Ew+RI6MFcDsIjEQHJDH2lUQYgbNlUlL8vNQQdvaOETAk9TA1LBp2PYZZwQ==
X-Received: by 2002:a50:acc6:: with SMTP id x64mr2531258edc.141.1554976571388;
        Thu, 11 Apr 2019 02:56:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlJP4iod78bxJaqPt+7oeGZ/zgxPBCBcjZN69o0vg0t8MFldTK7MC8wEdZGiLxCn0o3dMb
X-Received: by 2002:a50:acc6:: with SMTP id x64mr2531198edc.141.1554976570430;
        Thu, 11 Apr 2019 02:56:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554976570; cv=none;
        d=google.com; s=arc-20160816;
        b=WeKng0RrmHA7NShNHwEk9Wids7NEQB4ctjDp0Ozh+v47IonIAPkM6a1LjTcvB+Su2Z
         MfmKblIhFyifESQaOHdyRA2Uuv4PKlNTbEn7NSC5kokr2gWawEao5nRTYyGdVzf9PgPH
         388+pzxBAyBI2kmBIFufLCGoKmRQmOARf4UV4xtU6g4iHb5/7HexDOQfZHMv3e5J73Po
         bIGjCydQAiZggDUttqjn9yeq5MMgmBHhWeladmYjwuQ1pGMWyISsHyepSMF9YufuGzMO
         l4CQ0Y+hKvsUohNK/j//CVou8P/gOUlbRm19k2Z5M7jArUk30h6YQDAA+uWot4jADjz1
         KTKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4ymNHUcnRR403Tww5/AYF7KiH2+Ihr2L9b0TzxF5wcU=;
        b=AY3Z/PWDsuZAx69z8iJGSStpXuK5RZZbYI9KgOHbHSJW3gg8EFYfWyTOYSP3dpf/JQ
         k8NjKcizf5qgAkCVqk6umZeWxVAzCuCPGLC+4QYSlITv6UYPXIsNMynKTjWXtdQjzeyY
         IeTH31mFt8Z+8d9upBawRNrHhZlWc/CDU3+h98hVj5kVSbFz/RtOxUP55V4WsSYT1gV4
         uDuBTjsCqcTgTGmJ/Kx5DUpUrNyUfWsAfjKP8adWY4f3KK1mNLO040/zFj9w8nWcb6In
         C4YF89rjZVgRdpdH59463S8ZeARxp0H4QjSfumLX90bJLZwML0FFLFbpNYFn7k0azx8D
         nQKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hh8si3598359ejb.66.2019.04.11.02.56.09
        for <linux-mm@kvack.org>;
        Thu, 11 Apr 2019 02:56:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E81FE374;
	Thu, 11 Apr 2019 02:56:08 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F17F73F59C;
	Thu, 11 Apr 2019 02:56:05 -0700 (PDT)
Date: Thu, 11 Apr 2019 10:55:43 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	Alan Tull <atull@kernel.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Lameter <cl@linux.com>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Moritz Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>,
	Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190411095543.GA55197@lakrids.cambridge.arm.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 02:22:23PM +1000, Alexey Kardashevskiy wrote:
> On 03/04/2019 07:41, Daniel Jordan wrote:

> > -	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
> > +	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
> >  		incr ? '+' : '-', npages << PAGE_SHIFT,
> > -		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
> > -		ret ? "- exceeded" : "");
> > +		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
> > +		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
> 
> 
> 
> atomic64_read() returns "long" which matches "%ld", why this change (and
> similar below)? You did not do this in the two pr_debug()s above anyway.

Unfortunately, architectures return inconsistent types for atomic64 ops.

Some return long (e..g. powerpc), some return long long (e.g. arc), and
some return s64 (e.g. x86).

I'm currently trying to clean things up so that all use s64 [1], but in
the mean time it's necessary for generic code use a cast or temporarly
variable to ensure a consistent type. Once that's cleaned up, we can
remove the redundant casts.

Thanks,
Mark.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=atomics/type-cleanup

