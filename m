Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DDC2C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:34:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 433FB2166E
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:34:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 433FB2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5C506B027A; Tue, 28 May 2019 12:34:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B313E6B027C; Tue, 28 May 2019 12:34:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F9FE6B0281; Tue, 28 May 2019 12:34:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEC66B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 12:34:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so33866622edl.10
        for <linux-mm@kvack.org>; Tue, 28 May 2019 09:34:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=h32QT9H6rq0E1vjXhg0NjEb7RMelxM2xdWE5E7m7I7c=;
        b=FOIe0rCHgXMgqWMACAzGQRIM7HEWjz00sYBCM3NdgNbB/RPmrJ9BToyaYw3o+xu5Dn
         ZdkSob3Qr/1plqUwwzc5l20101wi1J00wOvpYPbjl8XVIVsf8vuRBAprLaci10wYA97a
         JDAwFqPa6tw4RyxDNR09ueM2JKMsE6EQJVszkeM3EaYSbbgr48nJdj2ipuiaHkinzNFj
         zFvqLAsLIIhYM2GtwIJwhHsfOVm5P0OTNcZVK+1P/D4fFApCrbi30hH2C59y0vpDir2m
         luM4l6/dV6OIb+6vg3UPs7Bk+0TegnFRCK5JVjFUy2altd5Wo8vnZAJt2ohtcIH54xmf
         vXWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXRDCKaSg/cSM+U6uQgqkl3LXkIlVr1ahQbSkOY82cfHXtoTkuh
	Lkuh8aGWbPeyS3S/v2h17+kwAvoZ1g39itC+qP7CO59CTgwR4OTu1N2RunEYhLCstdmfDmUOomK
	36kYv2TRxKKVmJxSCtZi+rz70RxFgTucpESbmQ1M80heoE2pUA/28LZjaAPzHEuNZgw==
X-Received: by 2002:a50:8682:: with SMTP id r2mr129197119eda.106.1559061250899;
        Tue, 28 May 2019 09:34:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjYe/qZYocD7+XUX1Di1eMWrxjumT6YXHubOGBX0sKB7PA4eosU+xqQic4O72NGhkM4ET/
X-Received: by 2002:a50:8682:: with SMTP id r2mr129197023eda.106.1559061249953;
        Tue, 28 May 2019 09:34:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559061249; cv=none;
        d=google.com; s=arc-20160816;
        b=e+DI8Ed7lWMP6uhO/NzyznboS/dimgg/Mffy7Xz8fqMRUrnrZrtHkrjtFMfvvTohdJ
         SUuGq0iAV8PPyGlZ8Hvd5i2+Riqli5StbAou36F/KCmsOaECEUX2z+DeOMUrvxjqAfgh
         e9ZCiuXcYjz7qj7hKtfMMvThf70Evdw1xnAr4TJyHTUUn+gJj8Ngp9WvQFDHBUJ+bHHR
         +FtBngZLuazScCdG8lIyH8eavle8hL/um0vhceBRzd68/X/51rTicMiZvu8Nvm1tn+vo
         Tr1vzqfaS5ttMZiZ1oe07COVtwkM1nQ6/e0n2FpFMBnGpdtikzt1pq6m+1+jQ1VW5Lb1
         G7Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=h32QT9H6rq0E1vjXhg0NjEb7RMelxM2xdWE5E7m7I7c=;
        b=ugoKgSV4RkfXAmIL1e7CmVn2ddFfjgZ0mhxixaN4K+bdSwmnls61bK25WNQG/hNjFL
         RT6A+SjOiD65QaySy+sMJhQXpYU6lZPi0OwYpAlZcZCfk+BVvDTfgsM7N1/rqoSgvDse
         L/VdLZi1cqpE/JEaepENYaF2CDFjBSOwDO4JzE15BHAMPY943WgU1XypFxRWCrfA7/Eq
         Eu4fBLZDhIgMAjqFTlU1GaEamrcSZFUetbx3rAMf/7gfpwWamvhrVoKdlk6iwIOgQmLp
         Map0K5anLeVhwL4KRfNiU5+8Qb9NNKts1NxOgTHKRilfrb4OQzqonc+jW40RE2gtnolf
         puYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f3si762991edv.9.2019.05.28.09.34.09
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 09:34:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D37F1341;
	Tue, 28 May 2019 09:34:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2754A3F59C;
	Tue, 28 May 2019 09:34:03 -0700 (PDT)
Date: Tue, 28 May 2019 17:34:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Andrew Murray <andrew.murray@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Lee Smith <Lee.Smith@arm.com>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190528163400.GE32006@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <20190528155644.GD28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528155644.GD28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:56:45PM +0100, Dave P Martin wrote:
> On Tue, May 28, 2019 at 04:40:58PM +0100, Catalin Marinas wrote:
> 
> [...]
> 
> > My thoughts on allowing tags (quick look):
> >
> > brk - no
> 
> [...]
> 
> > mlock, mlock2, munlock - yes
> > mmap - no (we may change this with MTE but not for TBI)
> 
> [...]
> 
> > mprotect - yes
> 
> I haven't following this discussion closely... what's the rationale for
> the inconsistencies here (feel free to refer me back to the discussion
> if it's elsewhere).

_My_ rationale (feel free to disagree) is that mmap() by default would
not return a tagged address (ignoring MTE for now). If it gets passed a
tagged address or a "tagged NULL" (for lack of a better name) we don't
have clear semantics of whether the returned address should be tagged in
this ABI relaxation. I'd rather reserve this specific behaviour if we
overload the non-zero tag meaning of mmap() for MTE. Similar reasoning
for mremap(), at least on the new_address argument (not entirely sure
about old_address).

munmap() should probably follow the mmap() rules.

As for brk(), I don't see why the user would need to pass a tagged
address, we can't associate any meaning to this tag.

For the rest, since it's likely such addresses would have been tagged by
malloc() in user space, we should allow tagged pointers.

-- 
Catalin

