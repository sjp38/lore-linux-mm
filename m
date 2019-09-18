Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91815C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 16:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAFE21907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 16:10:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Pm+DD6fy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAFE21907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEDE76B02D5; Wed, 18 Sep 2019 12:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC46D6B02D6; Wed, 18 Sep 2019 12:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98C666B02D7; Wed, 18 Sep 2019 12:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id 5619E6B02D5
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:10:12 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EAE468243775
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:10:11 +0000 (UTC)
X-FDA: 75948528222.15.owl92_19c16401b85f
X-HE-Tag: owl92_19c16401b85f
X-Filterd-Recvd-Size: 42722
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:10:10 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id c3so356395qtv.10
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:10:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Wcdh1E3aDcYW0VSo8zkDu4fdNQyYVFyK9x/zIDboSWw=;
        b=Pm+DD6fyBaDRH9/9ombjQP1DOIq/QHt+R642N07n1j75i+TRqduBUrcF3T5FxNs/rE
         nvnAmGsROERoTg9uk2j58G1lUQER3RgDOZWlo314/HZYe6bXIdPnG0k8SA96wrZBruXJ
         4zIw9w5rKQ+mV9+Pc4n0t9K9HCGI7tVzzwLvKgbxVVm3ZGq8wTkYDeHfcik0U8b7qUTl
         4BaHq5hRvn+AjwUNwQgFwnll1S5uvK33S7WEuQYVTcZq+iShaYPSIP2D78ohmr3vB6Q3
         1+A2GMgafnknanZIzaubuPsQFo+abZyMJjCZU5+VgNYB7DC1OmwAch68ipHmYEBHmt8v
         x7wA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Wcdh1E3aDcYW0VSo8zkDu4fdNQyYVFyK9x/zIDboSWw=;
        b=naMm8FVazaLMrFfnrtk87Ssmh/0hW0xx65yu4mgvw2uv8fVkGlthW8atsETW+hwuzE
         6EbPxKDeOJad4+kx1NlheZbgypeFc58Jn0D6Kwayz9m3Vv+0l8oZvFe9Mh/DVYbMEqwq
         fODJmaJJB0qhAKEvX+bumwfs7W+1xIdob6vjQ4i29p9MuX4h0obrIzmdR6gI1p5EOPkd
         NAS+/CpqS8EU6AyPXENSZOvz3xa22pxfTILDXdoN8x0ixy3Ld2YlR2dfrtAynGjf1BhR
         XtU6BBb98xn6IDJnmp5OMrxhWNZbIOSBA8hmd2mRBuQwQwOGDXiMvQ+djp3kjVVI3+11
         5bWQ==
X-Gm-Message-State: APjAAAWC/iOY3U+upfSXRCh8+6Cj50pU7d5vIa33kFbA6weIeoNKDIul
	rvFXbamOguYmZgGQIUqnHhEXMg==
X-Google-Smtp-Source: APXvYqyaH93fYHIG6xa1m+FEZkUpm4C5q/0Zr7v8YJm6TmtzMm+yOIdVbq0S20WswcMaRcxxBNumrg==
X-Received: by 2002:ac8:1289:: with SMTP id y9mr4817062qti.201.1568823009560;
        Wed, 18 Sep 2019 09:10:09 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id z12sm3318291qkg.97.2019.09.18.09.10.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 09:10:08 -0700 (PDT)
Message-ID: <1568823006.5576.178.camel@lca.pw>
Subject: Re: printk() + memory offline deadlock (WAS Re:
 page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang)
From: Qian Cai <cai@lca.pw>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky
 <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  linux-arm-kernel@lists.infradead.org, Peter
 Zijlstra <peterz@infradead.org>,  Waiman Long <longman@redhat.com>, Thomas
 Gleixner <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>,  Arnd
 Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 18 Sep 2019 12:10:06 -0400
In-Reply-To: <20190918155059.GA158834@tigerII.localdomain>
References: <1566509603.5576.10.camel@lca.pw>
	 <1567717680.5576.104.camel@lca.pw> <1568128954.5576.129.camel@lca.pw>
	 <20190911011008.GA4420@jagdpanzerIV> <1568289941.5576.140.camel@lca.pw>
	 <20190916104239.124fc2e5@gandalf.local.home>
	 <1568817579.5576.172.camel@lca.pw>
	 <20190918155059.GA158834@tigerII.localdomain>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-19 at 00:50 +0900, Sergey Senozhatsky wrote:
> On (09/18/19 10:39), Qian Cai wrote:
> > > Perhaps for a quick fix (and a comment that says this needs to be f=
ixed
> > > properly). I think the changes to printk() that was discussed at
> > > Plumbers may also solve this properly.
> >=20
> > I assume that the new printk() stuff will also fix this deadlock betw=
een
> > printk() and memory offline.
>=20
> Mother chicken...
>=20
> Do you actually see a deadlock? I'd rather expect a lockdep splat, but
> anyway...

Not yet, just a lockdep splat so far.

>=20
> > [=C2=A0=C2=A0317.337595] WARNING: possible circular locking dependenc=
y detected
> > [=C2=A0=C2=A0317.337596] 5.3.0-next-20190917+ #9 Not tainted
> > [=C2=A0=C2=A0317.337597] --------------------------------------------=
----------
> > [=C2=A0=C2=A0317.337597] test.sh/8738 is trying to acquire lock:
> > [=C2=A0=C2=A0317.337598] ffffffffb33a4978 ((console_sem).lock){-.-.},=
 at:> down_trylock+0x16/0x50
> >=20
> > [=C2=A0=C2=A0317.337602] but task is already holding lock:
> > [=C2=A0=C2=A0317.337602] ffff88883fff4318 (&(&zone->lock)->rlock){-.-=
.}, at:> start_isolate_page_range+0x1f7/0x570
> >=20
> > [=C2=A0=C2=A0317.337606] which lock already depends on the new lock.
> >=20
> > [=C2=A0=C2=A0317.337608] the existing dependency chain (in reverse or=
der) is:
> >=20
> > [=C2=A0=C2=A0317.337609] -> #3 (&(&zone->lock)->rlock){-.-.}:
> > [=C2=A0=C2=A0317.337612]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__lock_acquire+0x5b3/0xb40
> > [=C2=A0=C2=A0317.337613]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337613]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_raw_spin_lock+0x2f/0x40
> > [=C2=A0=C2=A0317.337614]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0rmqueue_bulk.constprop.21+0xb6/0x1160
> > [=C2=A0=C2=A0317.337615]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0get_page_from_freelist+0x898/0x22c0
> > [=C2=A0=C2=A0317.337616]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__alloc_pages_nodemask+0x2f3/0x1cd0
> > [=C2=A0=C2=A0317.337617]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0alloc_page_interleave+0x18/0x130
> > [=C2=A0=C2=A0317.337618]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0alloc_pages_current+0xf6/0x110
> > [=C2=A0=C2=A0317.337619]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0allocate_slab+0x4c6/0x19c0
> > [=C2=A0=C2=A0317.337620]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0new_slab+0x46/0x70
> > [=C2=A0=C2=A0317.337621]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0___slab_alloc+0x58b/0x960
> > [=C2=A0=C2=A0317.337621]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__slab_alloc+0x43/0x70
> > [=C2=A0=C2=A0317.337622]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0kmem_cache_alloc+0x354/0x460
> > [=C2=A0=C2=A0317.337623]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0fill_pool+0x272/0x4b0
> > [=C2=A0=C2=A0317.337624]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__debug_object_init+0x86/0x790
> > [=C2=A0=C2=A0317.337624]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0debug_object_init+0x16/0x20
> > [=C2=A0=C2=A0317.337625]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0hrtimer_init+0x27/0x1e0
> > [=C2=A0=C2=A0317.337626]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0init_dl_task_timer+0x20/0x40
> > [=C2=A0=C2=A0317.337627]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__sched_fork+0x10b/0x1f0
> > [=C2=A0=C2=A0317.337627]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0init_idle+0xac/0x520
> > [=C2=A0=C2=A0317.337628]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0idle_thread_get+0x7c/0xc0
> > [=C2=A0=C2=A0317.337629]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0bringup_cpu+0x1a/0x1e0
> > [=C2=A0=C2=A0317.337630]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0cpuhp_invoke_callback+0x197/0x1120
> > [=C2=A0=C2=A0317.337630]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_cpu_up+0x171/0x280
> > [=C2=A0=C2=A0317.337631]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0do_cpu_up+0xb1/0x120
> > [=C2=A0=C2=A0317.337632]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0cpu_up+0x13/0x20
> > [=C2=A0=C2=A0317.337632]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0smp_init+0xa4/0x12d
> > [=C2=A0=C2=A0317.337633]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0kernel_init_freeable+0x37e/0x76e
> > [=C2=A0=C2=A0317.337634]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0kernel_init+0x11/0x12f
> > [=C2=A0=C2=A0317.337635]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0ret_from_fork+0x3a/0x50
>=20
> So you have debug objects enabled. Right? This thing does not behave
> when it comes to printing. debug_objects are slightly problematic.

Yes, but there is an also a similar splat without the debug_objects. It l=
ooks
like anything try to allocate memory in that path will trigger it anyway.

[=C2=A0=C2=A0297.425908] WARNING: possible circular locking dependency de=
tected
[=C2=A0=C2=A0297.425908] 5.3.0-next-20190917 #8 Not tainted
[=C2=A0=C2=A0297.425909] ------------------------------------------------=
------
[=C2=A0=C2=A0297.425910] test.sh/8653 is trying to acquire lock:
[=C2=A0=C2=A0297.425911] ffffffff865a4460 (console_owner){-.-.}, at:
console_unlock+0x207/0x750

[=C2=A0=C2=A0297.425914] but task is already holding lock:
[=C2=A0=C2=A0297.425915] ffff88883fff3c58 (&(&zone->lock)->rlock){-.-.}, =
at:
__offline_isolated_pages+0x179/0x3e0

[=C2=A0=C2=A0297.425919] which lock already depends on the new lock.


[=C2=A0=C2=A0297.425920] the existing dependency chain (in reverse order)=
 is:

[=C2=A0=C2=A0297.425922] -> #3 (&(&zone->lock)->rlock){-.-.}:
[=C2=A0=C2=A0297.425925]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0297.425925]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0297.425926]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x2f/0x40
[=C2=A0=C2=A0297.425927]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
mqueue_bulk.constprop.21+0xb6/0x1160
[=C2=A0=C2=A0297.425928]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_page_from_freelist+0x898/0x22c0
[=C2=A0=C2=A0297.425928]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_alloc_pages_nodemask+0x2f3/0x1cd0
[=C2=A0=C2=A0297.425929]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_pages_current+0x9c/0x110
[=C2=A0=C2=A0297.425930]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
llocate_slab+0x4c6/0x19c0
[=C2=A0=C2=A0297.425931]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
ew_slab+0x46/0x70
[=C2=A0=C2=A0297.425931]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
__slab_alloc+0x58b/0x960
[=C2=A0=C2=A0297.425932]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_slab_alloc+0x43/0x70
[=C2=A0=C2=A0297.425933]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_kmalloc+0x3ad/0x4b0
[=C2=A0=C2=A0297.425933]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_tty_buffer_request_room+0x100/0x250
[=C2=A0=C2=A0297.425934]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_insert_flip_string_fixed_flag+0x67/0x110
[=C2=A0=C2=A0297.425935]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
ty_write+0xa2/0xf0
[=C2=A0=C2=A0297.425936]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
_tty_write+0x36b/0x7b0
[=C2=A0=C2=A0297.425936]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_write+0x284/0x4c0
[=C2=A0=C2=A0297.425937]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_vfs_write+0x50/0xa0
[=C2=A0=C2=A0297.425938]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_write+0x105/0x290
[=C2=A0=C2=A0297.425939]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
edirected_tty_write+0x6a/0xc0
[=C2=A0=C2=A0297.425939]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_iter_write+0x248/0x2a0
[=C2=A0=C2=A0297.425940]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_writev+0x106/0x1e0
[=C2=A0=C2=A0297.425941]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_writev+0xd4/0x180
[=C2=A0=C2=A0297.425941]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_x64_sys_writev+0x45/0x50
[=C2=A0=C2=A0297.425942]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0297.425943]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
ntry_SYSCALL_64_after_hwframe+0x49/0xbe

[=C2=A0=C2=A0297.425944] -> #2 (&(&port->lock)->rlock){-.-.}:
[=C2=A0=C2=A0297.425946]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0297.425947]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0297.425948]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0297.425949]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_tty_get+0x20/0x60
[=C2=A0=C2=A0297.425949]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_default_wakeup+0xf/0x30
[=C2=A0=C2=A0297.425950]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_tty_wakeup+0x39/0x40
[=C2=A0=C2=A0297.425951]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
art_write_wakeup+0x2a/0x40
[=C2=A0=C2=A0297.425952]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
erial8250_tx_chars+0x22e/0x440
[=C2=A0=C2=A0297.425952]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
erial8250_handle_irq.part.8+0x14a/0x170
[=C2=A0=C2=A0297.425953]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
erial8250_default_handle_irq+0x5c/0x90
[=C2=A0=C2=A0297.425954]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
erial8250_interrupt+0xa6/0x130
[=C2=A0=C2=A0297.425955]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_handle_irq_event_percpu+0x78/0x4f0
[=C2=A0=C2=A0297.425955]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
andle_irq_event_percpu+0x70/0x100
[=C2=A0=C2=A0297.425956]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
andle_irq_event+0x5a/0x8b
[=C2=A0=C2=A0297.425957]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0h=
andle_edge_irq+0x117/0x370
[=C2=A0=C2=A0297.425958]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_IRQ+0x9e/0x1e0
[=C2=A0=C2=A0297.425958]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
et_from_intr+0x0/0x2a
[=C2=A0=C2=A0297.425959]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
puidle_enter_state+0x156/0x8e0
[=C2=A0=C2=A0297.425960]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
puidle_enter+0x41/0x70
[=C2=A0=C2=A0297.425960]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
all_cpuidle+0x5e/0x90
[=C2=A0=C2=A0297.425961]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_idle+0x333/0x370
[=C2=A0=C2=A0297.425962]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
pu_startup_entry+0x1d/0x1f
[=C2=A0=C2=A0297.425962]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_secondary+0x290/0x330
[=C2=A0=C2=A0297.425963]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
econdary_startup_64+0xb6/0xc0

[=C2=A0=C2=A0297.425964] -> #1 (&port_lock_key){-.-.}:
[=C2=A0=C2=A0297.425967]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0297.425967]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0297.425968]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0297.425969]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
erial8250_console_write+0x3e4/0x450
[=C2=A0=C2=A0297.425970]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
niv8250_console_write+0x4b/0x60
[=C2=A0=C2=A0297.425970]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_unlock+0x501/0x750
[=C2=A0=C2=A0297.425971]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x10d/0x340
[=C2=A0=C2=A0297.425972]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x1f/0x30
[=C2=A0=C2=A0297.425972]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x44/0xd4
[=C2=A0=C2=A0297.425973]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0x9f/0xc5
[=C2=A0=C2=A0297.425974]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
egister_console+0x39c/0x520
[=C2=A0=C2=A0297.425975]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
niv8250_console_init+0x23/0x2d
[=C2=A0=C2=A0297.425975]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_init+0x338/0x4cd
[=C2=A0=C2=A0297.425976]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_kernel+0x534/0x724
[=C2=A0=C2=A0297.425977]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0x=
86_64_start_reservations+0x24/0x26
[=C2=A0=C2=A0297.425977]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0x=
86_64_start_kernel+0xf4/0xfb
[=C2=A0=C2=A0297.425978]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
econdary_startup_64+0xb6/0xc0

[=C2=A0=C2=A0297.425979] -> #0 (console_owner){-.-.}:
[=C2=A0=C2=A0297.425982]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
heck_prev_add+0x107/0xea0
[=C2=A0=C2=A0297.425982]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
alidate_chain+0x8fc/0x1200
[=C2=A0=C2=A0297.425983]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0297.425984]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x126/0x280
[=C2=A0=C2=A0297.425984]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_unlock+0x269/0x750
[=C2=A0=C2=A0297.425985]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x10d/0x340
[=C2=A0=C2=A0297.425986]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x1f/0x30
[=C2=A0=C2=A0297.425987]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x44/0xd4
[=C2=A0=C2=A0297.425987]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0x9f/0xc5
[=C2=A0=C2=A0297.425988]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_offline_isolated_pages.cold.52+0x2f/0x30a
[=C2=A0=C2=A0297.425989]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0o=
ffline_isolated_pages_cb+0x17/0x30
[=C2=A0=C2=A0297.425990]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0w=
alk_system_ram_range+0xda/0x160
[=C2=A0=C2=A0297.425990]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_offline_pages+0x79c/0xa10
[=C2=A0=C2=A0297.425991]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0o=
ffline_pages+0x11/0x20
[=C2=A0=C2=A0297.425992]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emory_subsys_offline+0x7e/0xc0
[=C2=A0=C2=A0297.425992]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
evice_offline+0xd5/0x110
[=C2=A0=C2=A0297.425993]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tate_store+0xc6/0xe0
[=C2=A0=C2=A0297.425994]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
ev_attr_store+0x3f/0x60
[=C2=A0=C2=A0297.425995]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
ysfs_kf_write+0x89/0xb0
[=C2=A0=C2=A0297.425995]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernfs_fop_write+0x188/0x240
[=C2=A0=C2=A0297.425996]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_vfs_write+0x50/0xa0
[=C2=A0=C2=A0297.425997]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_write+0x105/0x290
[=C2=A0=C2=A0297.425997]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
sys_write+0xc6/0x160
[=C2=A0=C2=A0297.425998]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_x64_sys_write+0x43/0x50
[=C2=A0=C2=A0297.425999]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0297.426000]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
ntry_SYSCALL_64_after_hwframe+0x49/0xbe

[=C2=A0=C2=A0297.426001] other info that might help us debug this:

[=C2=A0=C2=A0297.426002] Chain exists of:
[=C2=A0=C2=A0297.426002]=C2=A0=C2=A0=C2=A0console_owner --> &(&port->lock=
)->rlock --> &(&zone->lock)-
>rlock

[=C2=A0=C2=A0297.426007]=C2=A0=C2=A0Possible unsafe locking scenario:

[=C2=A0=C2=A0297.426008]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0C=
PU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
[=C2=A0=C2=A0297.426009]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-=
---=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
[=C2=A0=C2=A0297.426009]=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)->rlock);
[=C2=A0=C2=A0297.426011]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&port->lock)->rlock);
[=C2=A0=C2=A0297.426013]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&zone->lock)->rlock);
[=C2=A0=C2=A0297.426014]=C2=A0=C2=A0=C2=A0lock(console_owner);

[=C2=A0=C2=A0297.426016]=C2=A0=C2=A0*** DEADLOCK ***

[=C2=A0=C2=A0297.426017] 9 locks held by test.sh/8653:
[=C2=A0=C2=A0297.426018]=C2=A0=C2=A0#0: ffff88839ba7d408 (sb_writers#4){.=
+.+}, at:
vfs_write+0x25f/0x290
[=C2=A0=C2=A0297.426021]=C2=A0=C2=A0#1: ffff888277618880 (&of->mutex){+.+=
.}, at:
kernfs_fop_write+0x128/0x240
[=C2=A0=C2=A0297.426024]=C2=A0=C2=A0#2: ffff8898131fc218 (kn->count#115){=
.+.+}, at:
kernfs_fop_write+0x138/0x240
[=C2=A0=C2=A0297.426028]=C2=A0=C2=A0#3: ffffffff86962a80 (device_hotplug_=
lock){+.+.}, at:
lock_device_hotplug_sysfs+0x16/0x50
[=C2=A0=C2=A0297.426031]=C2=A0=C2=A0#4: ffff8884374f4990 (&dev->mutex){..=
..}, at:
device_offline+0x70/0x110
[=C2=A0=C2=A0297.426034]=C2=A0=C2=A0#5: ffffffff86515250 (cpu_hotplug_loc=
k.rw_sem){++++}, at:
__offline_pages+0xbf/0xa10
[=C2=A0=C2=A0297.426037]=C2=A0=C2=A0#6: ffffffff867405f0 (mem_hotplug_loc=
k.rw_sem){++++}, at:
percpu_down_write+0x87/0x2f0
[=C2=A0=C2=A0297.426040]=C2=A0=C2=A0#7: ffff88883fff3c58 (&(&zone->lock)-=
>rlock){-.-.}, at:
__offline_isolated_pages+0x179/0x3e0
[=C2=A0=C2=A0297.426043]=C2=A0=C2=A0#8: ffffffff865a4920 (console_lock){+=
.+.}, at:
vprintk_emit+0x100/0x340

[=C2=A0=C2=A0297.426047] stack backtrace:
[=C2=A0=C2=A0297.426048] CPU: 1 PID: 8653 Comm: test.sh Not tainted 5.3.0=
-next-20190917 #8
[=C2=A0=C2=A0297.426049] Hardware name: HPE ProLiant DL560 Gen10/ProLiant=
 DL560 Gen10,
BIOS U34 05/21/2019
[=C2=A0=C2=A0297.426049] Call Trace:
[=C2=A0=C2=A0297.426050]=C2=A0=C2=A0dump_stack+0x86/0xca
[=C2=A0=C2=A0297.426051]=C2=A0=C2=A0print_circular_bug.cold.31+0x243/0x26=
e
[=C2=A0=C2=A0297.426051]=C2=A0=C2=A0check_noncircular+0x29e/0x2e0
[=C2=A0=C2=A0297.426052]=C2=A0=C2=A0? stack_trace_save+0x87/0xb0
[=C2=A0=C2=A0297.426053]=C2=A0=C2=A0? print_circular_bug+0x120/0x120
[=C2=A0=C2=A0297.426053]=C2=A0=C2=A0check_prev_add+0x107/0xea0
[=C2=A0=C2=A0297.426054]=C2=A0=C2=A0validate_chain+0x8fc/0x1200
[=C2=A0=C2=A0297.426055]=C2=A0=C2=A0? check_prev_add+0xea0/0xea0
[=C2=A0=C2=A0297.426055]=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[=C2=A0=C2=A0297.426056]=C2=A0=C2=A0lock_acquire+0x126/0x280
[=C2=A0=C2=A0297.426057]=C2=A0=C2=A0? console_unlock+0x207/0x750
[=C2=A0=C2=A0297.426057]=C2=A0=C2=A0? __kasan_check_read+0x11/0x20
[=C2=A0=C2=A0297.426058]=C2=A0=C2=A0console_unlock+0x269/0x750
[=C2=A0=C2=A0297.426059]=C2=A0=C2=A0? console_unlock+0x207/0x750
[=C2=A0=C2=A0297.426059]=C2=A0=C2=A0vprintk_emit+0x10d/0x340
[=C2=A0=C2=A0297.426060]=C2=A0=C2=A0vprintk_default+0x1f/0x30
[=C2=A0=C2=A0297.426061]=C2=A0=C2=A0vprintk_func+0x44/0xd4
[=C2=A0=C2=A0297.426061]=C2=A0=C2=A0? do_raw_spin_lock+0x118/0x1d0
[=C2=A0=C2=A0297.426062]=C2=A0=C2=A0printk+0x9f/0xc5
[=C2=A0=C2=A0297.426063]=C2=A0=C2=A0? kmsg_dump_rewind_nolock+0x64/0x64
[=C2=A0=C2=A0297.426064]=C2=A0=C2=A0? __offline_isolated_pages+0x179/0x3e=
0
[=C2=A0=C2=A0297.426064]=C2=A0=C2=A0__offline_isolated_pages.cold.52+0x2f=
/0x30a
[=C2=A0=C2=A0297.426065]=C2=A0=C2=A0? online_memory_block+0x20/0x20
[=C2=A0=C2=A0297.426066]=C2=A0=C2=A0offline_isolated_pages_cb+0x17/0x30
[=C2=A0=C2=A0297.426067]=C2=A0=C2=A0walk_system_ram_range+0xda/0x160
[=C2=A0=C2=A0297.426067]=C2=A0=C2=A0? walk_mem_res+0x30/0x30
[=C2=A0=C2=A0297.426068]=C2=A0=C2=A0? dissolve_free_huge_page+0x1e/0x2b0
[=C2=A0=C2=A0297.426069]=C2=A0=C2=A0__offline_pages+0x79c/0xa10
[=C2=A0=C2=A0297.426069]=C2=A0=C2=A0? __add_memory+0xc0/0xc0
[=C2=A0=C2=A0297.426070]=C2=A0=C2=A0? __kasan_check_write+0x14/0x20
[=C2=A0=C2=A0297.426071]=C2=A0=C2=A0? __mutex_lock+0x344/0xcd0
[=C2=A0=C2=A0297.426071]=C2=A0=C2=A0? _raw_spin_unlock_irqrestore+0x49/0x=
50
[=C2=A0=C2=A0297.426072]=C2=A0=C2=A0? device_offline+0x70/0x110
[=C2=A0=C2=A0297.426073]=C2=A0=C2=A0? klist_next+0x1c1/0x1e0
[=C2=A0=C2=A0297.426073]=C2=A0=C2=A0? __mutex_add_waiter+0xc0/0xc0
[=C2=A0=C2=A0297.426074]=C2=A0=C2=A0? klist_next+0x10b/0x1e0
[=C2=A0=C2=A0297.426075]=C2=A0=C2=A0? klist_iter_exit+0x16/0x40
[=C2=A0=C2=A0297.426076]=C2=A0=C2=A0? device_for_each_child+0xd0/0x110
[=C2=A0=C2=A0297.426076]=C2=A0=C2=A0offline_pages+0x11/0x20
[=C2=A0=C2=A0297.426077]=C2=A0=C2=A0memory_subsys_offline+0x7e/0xc0
[=C2=A0=C2=A0297.426078]=C2=A0=C2=A0device_offline+0xd5/0x110
[=C2=A0=C2=A0297.426078]=C2=A0=C2=A0? auto_online_blocks_show+0x70/0x70
[=C2=A0=C2=A0297.426079]=C2=A0=C2=A0state_store+0xc6/0xe0
[=C2=A0=C2=A0297.426080]=C2=A0=C2=A0dev_attr_store+0x3f/0x60
[=C2=A0=C2=A0297.426080]=C2=A0=C2=A0? device_match_name+0x40/0x40
[=C2=A0=C2=A0297.426081]=C2=A0=C2=A0sysfs_kf_write+0x89/0xb0
[=C2=A0=C2=A0297.426082]=C2=A0=C2=A0? sysfs_file_ops+0xa0/0xa0
[=C2=A0=C2=A0297.426082]=C2=A0=C2=A0kernfs_fop_write+0x188/0x240
[=C2=A0=C2=A0297.426083]=C2=A0=C2=A0__vfs_write+0x50/0xa0
[=C2=A0=C2=A0297.426084]=C2=A0=C2=A0vfs_write+0x105/0x290
[=C2=A0=C2=A0297.426084]=C2=A0=C2=A0ksys_write+0xc6/0x160
[=C2=A0=C2=A0297.426085]=C2=A0=C2=A0? __x64_sys_read+0x50/0x50
[=C2=A0=C2=A0297.426086]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
[=C2=A0=C2=A0297.426086]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
[=C2=A0=C2=A0297.426087]=C2=A0=C2=A0__x64_sys_write+0x43/0x50
[=C2=A0=C2=A0297.426088]=C2=A0=C2=A0do_syscall_64+0xcc/0x76c
[=C2=A0=C2=A0297.426088]=C2=A0=C2=A0? trace_hardirqs_on_thunk+0x1a/0x20
[=C2=A0=C2=A0297.426089]=C2=A0=C2=A0? syscall_return_slowpath+0x210/0x210
[=C2=A0=C2=A0297.426090]=C2=A0=C2=A0? entry_SYSCALL_64_after_hwframe+0x3e=
/0xbe
[=C2=A0=C2=A0297.426091]=C2=A0=C2=A0? trace_hardirqs_off_caller+0x3a/0x15=
0
[=C2=A0=C2=A0297.426092]=C2=A0=C2=A0? trace_hardirqs_off_thunk+0x1a/0x20
[=C2=A0=C2=A0297.426092]=C2=A0=C2=A0entry_SYSCALL_64_after_hwframe+0x49/0=
xbe
[=C2=A0=C2=A0297.426093] RIP: 0033:0x7fd7336b4e18
[=C2=A0=C2=A0297.426095] Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 =
00 00 00 00 f3 0f
1e fa 48 8d 05 05 59 2d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d=
 00 f0
ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49 89 d4 55
[=C2=A0=C2=A0297.426096] RSP: 002b:00007ffc58c7b258 EFLAGS: 00000246 ORIG=
_RAX:
0000000000000001
[=C2=A0=C2=A0297.426098] RAX: ffffffffffffffda RBX: 0000000000000008 RCX:=
 00007fd7336b4e18
[=C2=A0=C2=A0297.426098] RDX: 0000000000000008 RSI: 000055ad6d519c70 RDI:=
 0000000000000001
[=C2=A0=C2=A0297.426099] RBP: 000055ad6d519c70 R08: 000000000000000a R09:=
 00007fd733746300
[=C2=A0=C2=A0297.426100] R10: 000000000000000a R11: 0000000000000246 R12:=
 00007fd733986780
[=C2=A0=C2=A0297.426101] R13: 0000000000000008 R14: 00007fd733981740 R15:=
 0000000000000008


[=C2=A0=C2=A0763.659202][=C2=A0=C2=A0=C2=A0=C2=A0C6] WARNING: possible ci=
rcular locking dependency detected
[=C2=A0=C2=A0763.659202][=C2=A0=C2=A0=C2=A0=C2=A0C6] 5.3.0-next-20190917 =
#3 Not tainted
[=C2=A0=C2=A0763.659203][=C2=A0=C2=A0=C2=A0=C2=A0C6] --------------------=
----------------------------------
[=C2=A0=C2=A0763.659203][=C2=A0=C2=A0=C2=A0=C2=A0C6] test.sh/8352 is tryi=
ng to acquire lock:
[=C2=A0=C2=A0763.659203][=C2=A0=C2=A0=C2=A0=C2=A0C6] ffffffffa187e5f8 ((c=
onsole_sem).lock){..-.}, at:
down_trylock+0x14/0x40
[=C2=A0=C2=A0763.659206][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659206][=C2=A0=C2=A0=C2=A0=C2=A0C6] but task is already =
holding lock:
[=C2=A0=C2=A0763.659206][=C2=A0=C2=A0=C2=A0=C2=A0C6] ffff9bcf7f373c58 (&(=
&zone->lock)->rlock){-.-.}, at:
__offline_isolated_pages+0x11e/0x2d0
[=C2=A0=C2=A0763.659208][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659208][=C2=A0=C2=A0=C2=A0=C2=A0C6] which lock already d=
epends on the new lock.
[=C2=A0=C2=A0763.659209][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659209][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659209][=C2=A0=C2=A0=C2=A0=C2=A0C6] the existing depende=
ncy chain (in reverse order) is:
[=C2=A0=C2=A0763.659210][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659210][=C2=A0=C2=A0=C2=A0=C2=A0C6] -> #3 (&(&zone->lock=
)->rlock){-.-.}:
[=C2=A0=C2=A0763.659211][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__lock_acquire+0x44e/0x8c0
[=C2=A0=C2=A0763.659212][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0lock_acquire+0xc0/0x1c0
[=C2=A0=C2=A0763.659212][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0_raw_spin_lock+0x2f/0x40
[=C2=A0=C2=A0763.659212][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0rmqueue_bulk.constprop.24+0x62/0xba0
[=C2=A0=C2=A0763.659213][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0get_page_from_freelist+0x581/0x1810
[=C2=A0=C2=A0763.659213][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__alloc_pages_nodemask+0x20d/0x1750
[=C2=A0=C2=A0763.659214][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0alloc_page_interleave+0x17/0x100
[=C2=A0=C2=A0763.659214][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0alloc_pages_current+0xc0/0xe0
[=C2=A0=C2=A0763.659214][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0allocate_slab+0x4b2/0x1a20
[=C2=A0=C2=A0763.659215][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0new_slab+0x46/0x70
[=C2=A0=C2=A0763.659215][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0___slab_alloc+0x58a/0x960
[=C2=A0=C2=A0763.659215][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__slab_alloc+0x43/0x70
[=C2=A0=C2=A0763.659216][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0kmem_cache_alloc+0x33e/0x440
[=C2=A0=C2=A0763.659216][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0fill_pool+0x1ae/0x460
[=C2=A0=C2=A0763.659216][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__debug_object_init+0x35/0x4a0
[=C2=A0=C2=A0763.659217][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0debug_object_init+0x16/0x20
[=C2=A0=C2=A0763.659217][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0hrtimer_init+0x25/0x130
[=C2=A0=C2=A0763.659218][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0init_dl_task_timer+0x20/0x30
[=C2=A0=C2=A0763.659218][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__sched_fork+0x92/0x100
[=C2=A0=C2=A0763.659218][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0init_idle+0x8d/0x380
[=C2=A0=C2=A0763.659219][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0fork_idle+0xd9/0x140
[=C2=A0=C2=A0763.659219][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0idle_threads_init+0xd3/0x15e
[=C2=A0=C2=A0763.659219][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0smp_init+0x1b/0xbb
[=C2=A0=C2=A0763.659220][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0kernel_init_freeable+0x248/0x557
[=C2=A0=C2=A0763.659220][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0kernel_init+0xf/0x11e
[=C2=A0=C2=A0763.659220][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0ret_from_fork+0x27/0x50
[=C2=A0=C2=A0763.659221][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659221][=C2=A0=C2=A0=C2=A0=C2=A0C6] -> #2 (&rq->lock){-.=
-.}:
[=C2=A0=C2=A0763.659222][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__lock_acquire+0x44e/0x8c0
[=C2=A0=C2=A0763.659223][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0lock_acquire+0xc0/0x1c0
[=C2=A0=C2=A0763.659223][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0_raw_spin_lock+0x2f/0x40
[=C2=A0=C2=A0763.659223][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0task_fork_fair+0x37/0x150
[=C2=A0=C2=A0763.659224][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0sched_fork+0x126/0x230
[=C2=A0=C2=A0763.659224][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0copy_process+0xafc/0x1e90
[=C2=A0=C2=A0763.659224][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0_do_fork+0x89/0x720
[=C2=A0=C2=A0763.659225][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0kernel_thread+0x58/0x70
[=C2=A0=C2=A0763.659225][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0rest_init+0x28/0x302
[=C2=A0=C2=A0763.659225][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0arch_call_rest_init+0xe/0x1b
[=C2=A0=C2=A0763.659226][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0start_kernel+0x581/0x5a0
[=C2=A0=C2=A0763.659226][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0x86_64_start_reservations+0x24/0x26
[=C2=A0=C2=A0763.659227][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0x86_64_start_kernel+0xef/0xf6
[=C2=A0=C2=A0763.659227][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0secondary_startup_64+0xb6/0xc0
[=C2=A0=C2=A0763.659227][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659227][=C2=A0=C2=A0=C2=A0=C2=A0C6] -> #1 (&p->pi_lock){=
-.-.}:
[=C2=A0=C2=A0763.659229][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__lock_acquire+0x44e/0x8c0
[=C2=A0=C2=A0763.659229][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0lock_acquire+0xc0/0x1c0
[=C2=A0=C2=A0763.659230][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0763.659230][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0try_to_wake_up+0x5c/0xbc0
[=C2=A0=C2=A0763.659230][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0wake_up_process+0x15/0x20
[=C2=A0=C2=A0763.659231][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__up+0x4a/0x50
[=C2=A0=C2=A0763.659231][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0up+0x45/0x50
[=C2=A0=C2=A0763.659231][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__up_console_sem+0x37/0x60
[=C2=A0=C2=A0763.659232][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0console_unlock+0x357/0x600
[=C2=A0=C2=A0763.659232][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_emit+0x101/0x320
[=C2=A0=C2=A0763.659232][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_default+0x1f/0x30
[=C2=A0=C2=A0763.659233][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_func+0x44/0xd4
[=C2=A0=C2=A0763.659233][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0printk+0x58/0x6f
[=C2=A0=C2=A0763.659234][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0do_exit+0xd73/0xd80
[=C2=A0=C2=A0763.659234][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0do_group_exit+0x41/0xd0
[=C2=A0=C2=A0763.659234][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__x64_sys_exit_group+0x18/0x20
[=C2=A0=C2=A0763.659235][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0do_syscall_64+0x6d/0x488
[=C2=A0=C2=A0763.659235][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0entry_SYSCALL_64_after_hwframe+0x49/0xbe
[=C2=A0=C2=A0763.659235][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659236][=C2=A0=C2=A0=C2=A0=C2=A0C6] -> #0 ((console_sem)=
.lock){..-.}:
[=C2=A0=C2=A0763.659237][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0check_prev_add+0x9b/0xa10
[=C2=A0=C2=A0763.659237][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0validate_chain+0x759/0xdc0
[=C2=A0=C2=A0763.659238][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__lock_acquire+0x44e/0x8c0
[=C2=A0=C2=A0763.659238][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0lock_acquire+0xc0/0x1c0
[=C2=A0=C2=A0763.659239][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0763.659239][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0down_trylock+0x14/0x40
[=C2=A0=C2=A0763.659239][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__down_trylock_console_sem+0x2b/0xa0
[=C2=A0=C2=A0763.659240][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0console_trylock+0x16/0x60
[=C2=A0=C2=A0763.659240][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_emit+0xf4/0x320
[=C2=A0=C2=A0763.659240][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_default+0x1f/0x30
[=C2=A0=C2=A0763.659241][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vprintk_func+0x44/0xd4
[=C2=A0=C2=A0763.659241][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0printk+0x58/0x6f
[=C2=A0=C2=A0763.659242][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__offline_isolated_pages.cold.55+0x38/0x28e
[=C2=A0=C2=A0763.659242][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0offline_isolated_pages_cb+0x15/0x20
[=C2=A0=C2=A0763.659242][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0walk_system_ram_range+0x7b/0xd0
[=C2=A0=C2=A0763.659243][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__offline_pages+0x456/0xc10
[=C2=A0=C2=A0763.659243][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0offline_pages+0x11/0x20
[=C2=A0=C2=A0763.659243][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0memory_subsys_offline+0x44/0x60
[=C2=A0=C2=A0763.659244][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0device_offline+0x90/0xc0
[=C2=A0=C2=A0763.659244][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0state_store+0xbc/0xe0
[=C2=A0=C2=A0763.659244][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0dev_attr_store+0x17/0x30
[=C2=A0=C2=A0763.659245][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0sysfs_kf_write+0x4b/0x60
[=C2=A0=C2=A0763.659245][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0kernfs_fop_write+0x119/0x1c0
[=C2=A0=C2=A0763.659245][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__vfs_write+0x1b/0x40
[=C2=A0=C2=A0763.659246][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0vfs_write+0xbd/0x1c0
[=C2=A0=C2=A0763.659246][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0ksys_write+0x64/0xe0
[=C2=A0=C2=A0763.659247][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0__x64_sys_write+0x1a/0x20
[=C2=A0=C2=A0763.659247][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0do_syscall_64+0x6d/0x488
[=C2=A0=C2=A0763.659247][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0entry_SYSCALL_64_after_hwframe+0x49/0xbe
[=C2=A0=C2=A0763.659248][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659248][=C2=A0=C2=A0=C2=A0=C2=A0C6] other info that migh=
t help us debug this:
[=C2=A0=C2=A0763.659248][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659248][=C2=A0=C2=A0=C2=A0=C2=A0C6] Chain exists of:
[=C2=A0=C2=A0763.659249][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0(co=
nsole_sem).lock --> &rq->lock --> &(&zone->lock)-
>rlock
[=C2=A0=C2=A0763.659251][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659251][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0Possible =
unsafe locking scenario:
[=C2=A0=C2=A0763.659251][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659252][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0CPU1
[=C2=A0=C2=A0763.659252][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0----=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0----
[=C2=A0=C2=A0763.659252][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0loc=
k(&(&zone->lock)->rlock);
[=C2=A0=C2=A0763.659253][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0lock(&rq->lock);
[=C2=A0=C2=A0763.659254][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)-
>rlock);
[=C2=A0=C2=A0763.659255][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0=C2=A0loc=
k((console_sem).lock);
[=C2=A0=C2=A0763.659256][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659256][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0*** DEADL=
OCK ***
[=C2=A0=C2=A0763.659256][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659257][=C2=A0=C2=A0=C2=A0=C2=A0C6] 8 locks held by test=
.sh/8352:
[=C2=A0=C2=A0763.659257][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#0: ffff9=
bdf4da39408 (sb_writers#4){.+.+}, at:
vfs_write+0x174/0x1c0
[=C2=A0=C2=A0763.659259][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#1: ffff9=
be348280880 (&of->mutex){+.+.}, at:
kernfs_fop_write+0xe4/0x1c0
[=C2=A0=C2=A0763.659260][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#2: ffff9=
bdb873757d0 (kn->count#125){.+.+}, at:
kernfs_fop_write+0xed/0x1c0
[=C2=A0=C2=A0763.659262][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#3: fffff=
fffa194dec0 (device_hotplug_lock){+.+.}, at:
lock_device_hotplug_sysfs+0x15/0x40
[=C2=A0=C2=A0763.659264][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#4: ffff9=
bcf7314c990 (&dev->mutex){....}, at:
device_offline+0x4e/0xc0
[=C2=A0=C2=A0763.659265][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#5: fffff=
fffa185b9f0 (cpu_hotplug_lock.rw_sem){++++},
at: __offline_pages+0x3b/0xc10
[=C2=A0=C2=A0763.659267][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#6: fffff=
fffa18e0b90 (mem_hotplug_lock.rw_sem){++++},
at: percpu_down_write+0x36/0x1c0
[=C2=A0=C2=A0763.659268][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0#7: ffff9=
bcf7f373c58 (&(&zone->lock)->rlock){-.-.}, at:
__offline_isolated_pages+0x11e/0x2d0
[=C2=A0=C2=A0763.659270][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0
[=C2=A0=C2=A0763.659270][=C2=A0=C2=A0=C2=A0=C2=A0C6] stack backtrace:
[=C2=A0=C2=A0763.659271][=C2=A0=C2=A0=C2=A0=C2=A0C6] CPU: 6 PID: 8352 Com=
m: test.sh Not tainted 5.3.0-next-
20190917 #3
[=C2=A0=C2=A0763.659271][=C2=A0=C2=A0=C2=A0=C2=A0C6] Hardware name: HPE P=
roLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 07/10/2019
[=C2=A0=C2=A0763.659272][=C2=A0=C2=A0=C2=A0=C2=A0C6] Call Trace:
[=C2=A0=C2=A0763.659272][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0dump_stac=
k+0x70/0x9a
[=C2=A0=C2=A0763.659272][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0print_cir=
cular_bug.cold.31+0x1c0/0x1eb
[=C2=A0=C2=A0763.659273][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0check_non=
circular+0x18c/0x1a0
[=C2=A0=C2=A0763.659273][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0check_pre=
v_add+0x9b/0xa10
[=C2=A0=C2=A0763.659273][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0validate_=
chain+0x759/0xdc0
[=C2=A0=C2=A0763.659274][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__lock_ac=
quire+0x44e/0x8c0
[=C2=A0=C2=A0763.659274][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0lock_acqu=
ire+0xc0/0x1c0
[=C2=A0=C2=A0763.659274][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0? down_tr=
ylock+0x14/0x40
[=C2=A0=C2=A0763.659275][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0? vprintk=
_emit+0xf4/0x320
[=C2=A0=C2=A0763.659275][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0_raw_spin=
_lock_irqsave+0x3a/0x50
[=C2=A0=C2=A0763.659275][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0? down_tr=
ylock+0x14/0x40
[=C2=A0=C2=A0763.659276][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0down_tryl=
ock+0x14/0x40
[=C2=A0=C2=A0763.659276][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__down_tr=
ylock_console_sem+0x2b/0xa0
[=C2=A0=C2=A0763.659276][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0console_t=
rylock+0x16/0x60
[=C2=A0=C2=A0763.659277][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0vprintk_e=
mit+0xf4/0x320
[=C2=A0=C2=A0763.659277][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0vprintk_d=
efault+0x1f/0x30
[=C2=A0=C2=A0763.659277][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0vprintk_f=
unc+0x44/0xd4
[=C2=A0=C2=A0763.659278][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0printk+0x=
58/0x6f
[=C2=A0=C2=A0763.659278][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__offline=
_isolated_pages.cold.55+0x38/0x28e
[=C2=A0=C2=A0763.659278][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0? online_=
memory_block+0x20/0x20
[=C2=A0=C2=A0763.659279][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0offline_i=
solated_pages_cb+0x15/0x20
[=C2=A0=C2=A0763.659279][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0walk_syst=
em_ram_range+0x7b/0xd0
[=C2=A0=C2=A0763.659279][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__offline=
_pages+0x456/0xc10
[=C2=A0=C2=A0763.659280][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0offline_p=
ages+0x11/0x20
[=C2=A0=C2=A0763.659280][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0memory_su=
bsys_offline+0x44/0x60
[=C2=A0=C2=A0763.659280][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0device_of=
fline+0x90/0xc0
[=C2=A0=C2=A0763.659281][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0state_sto=
re+0xbc/0xe0
[=C2=A0=C2=A0763.659281][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0dev_attr_=
store+0x17/0x30
[=C2=A0=C2=A0763.659281][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0sysfs_kf_=
write+0x4b/0x60
[=C2=A0=C2=A0763.659282][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0kernfs_fo=
p_write+0x119/0x1c0
[=C2=A0=C2=A0763.659282][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__vfs_wri=
te+0x1b/0x40
[=C2=A0=C2=A0763.659282][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0vfs_write=
+0xbd/0x1c0
[=C2=A0=C2=A0763.659283][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0ksys_writ=
e+0x64/0xe0
[=C2=A0=C2=A0763.659283][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0__x64_sys=
_write+0x1a/0x20
[=C2=A0=C2=A0763.659283][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0do_syscal=
l_64+0x6d/0x488
[=C2=A0=C2=A0763.659284][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0? trace_h=
ardirqs_off_thunk+0x1a/0x20
[=C2=A0=C2=A0763.659284][=C2=A0=C2=A0=C2=A0=C2=A0C6]=C2=A0=C2=A0entry_SYS=
CALL_64_after_hwframe+0x49/0xbe

>=20
> This thing does
>=20
> 	rq->lock --> zone->lock
>=20
> It takes rq->lock and then calls into __sched_fork()->hrtimer_init()->d=
ebug_objects()->MM
>=20
> This doesn't look very right - a dive into MM under rq->lock.
>=20
> Peter, Thomas am I wrong?
>=20
> > [=C2=A0=C2=A0317.337635] -> #2 (&rq->lock){-.-.}:
> > [=C2=A0=C2=A0317.337638]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__lock_acquire+0x5b3/0xb40
> > [=C2=A0=C2=A0317.337639]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337639]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_raw_spin_lock+0x2f/0x40
> > [=C2=A0=C2=A0317.337640]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0task_fork_fair+0x43/0x200
> > [=C2=A0=C2=A0317.337641]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0sched_fork+0x29b/0x420
> > [=C2=A0=C2=A0317.337642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0copy_process+0xf3c/0x2fd0
> > [=C2=A0=C2=A0317.337642]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_do_fork+0xef/0x950
> > [=C2=A0=C2=A0317.337643]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0kernel_thread+0xa8/0xe0
> > [=C2=A0=C2=A0317.337644]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0rest_init+0x28/0x311
> > [=C2=A0=C2=A0317.337645]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0arch_call_rest_init+0xe/0x1b
> > [=C2=A0=C2=A0317.337645]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0start_kernel+0x6eb/0x724
> > [=C2=A0=C2=A0317.337646]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0x86_64_start_reservations+0x24/0x26
> > [=C2=A0=C2=A0317.337647]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0x86_64_start_kernel+0xf4/0xfb
> > [=C2=A0=C2=A0317.337648]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0secondary_startup_64+0xb6/0xc0
>=20
> pi_lock --> rq->lock
>=20
> > [=C2=A0=C2=A0317.337649] -> #1 (&p->pi_lock){-.-.}:
> > [=C2=A0=C2=A0317.337651]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__lock_acquire+0x5b3/0xb40
> > [=C2=A0=C2=A0317.337652]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337653]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_raw_spin_lock_irqsave+0x3a/0x50
> > [=C2=A0=C2=A0317.337653]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0try_to_wake_up+0xb4/0x1030
> > [=C2=A0=C2=A0317.337654]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0wake_up_process+0x15/0x20
> > [=C2=A0=C2=A0317.337655]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__up+0xaa/0xc0
> > [=C2=A0=C2=A0317.337655]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0up+0x55/0x60
> > [=C2=A0=C2=A0317.337656]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__up_console_sem+0x37/0x60
> > [=C2=A0=C2=A0317.337657]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0console_unlock+0x3a0/0x750
> > [=C2=A0=C2=A0317.337658]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_emit+0x10d/0x340
> > [=C2=A0=C2=A0317.337658]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_default+0x1f/0x30
> > [=C2=A0=C2=A0317.337659]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_func+0x44/0xd4
> > [=C2=A0=C2=A0317.337660]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0printk+0x9f/0xc5
> > [=C2=A0=C2=A0317.337660]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0crng_reseed+0x3cc/0x440
> > [=C2=A0=C2=A0317.337661]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0credit_entropy_bits+0x3e8/0x4f0
> > [=C2=A0=C2=A0317.337662]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0random_ioctl+0x1eb/0x250
> > [=C2=A0=C2=A0317.337663]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0do_vfs_ioctl+0x13e/0xa70
> > [=C2=A0=C2=A0317.337663]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0ksys_ioctl+0x41/0x80
> > [=C2=A0=C2=A0317.337664]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__x64_sys_ioctl+0x43/0x4c
> > [=C2=A0=C2=A0317.337665]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0do_syscall_64+0xcc/0x76c
> > [=C2=A0=C2=A0317.337666]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0entry_SYSCALL_64_after_hwframe+0x49/0xbe
>=20
> console_sem->lock --> pi_lock
>=20
> This also covers console_sem->lock --> rq->lock, and maintains
> pi_lock --> rq->lock
>=20
> So we have
>=20
> 	console_sem->lock --> pi_lock --> rq->lock
>=20
> > [=C2=A0=C2=A0317.337667] -> #0 ((console_sem).lock){-.-.}:
> > [=C2=A0=C2=A0317.337669]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0check_prev_add+0x107/0xea0
> > [=C2=A0=C2=A0317.337670]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0validate_chain+0x8fc/0x1200
> > [=C2=A0=C2=A0317.337671]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__lock_acquire+0x5b3/0xb40
> > [=C2=A0=C2=A0317.337671]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337672]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0_raw_spin_lock_irqsave+0x3a/0x50
> > [=C2=A0=C2=A0317.337673]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0down_trylock+0x16/0x50
> > [=C2=A0=C2=A0317.337674]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__down_trylock_console_sem+0x2b/0xa0
> > [=C2=A0=C2=A0317.337675]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0console_trylock+0x16/0x60
> > [=C2=A0=C2=A0317.337676]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_emit+0x100/0x340
> > [=C2=A0=C2=A0317.337677]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_default+0x1f/0x30
> > [=C2=A0=C2=A0317.337678]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vprintk_func+0x44/0xd4
> > [=C2=A0=C2=A0317.337678]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0printk+0x9f/0xc5
> > [=C2=A0=C2=A0317.337679]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__dump_page.cold.2+0x73/0x210
> > [=C2=A0=C2=A0317.337680]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0dump_page+0x12/0x50
> > [=C2=A0=C2=A0317.337680]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0has_unmovable_pages+0x3e9/0x4b0
> > [=C2=A0=C2=A0317.337681]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0start_isolate_page_range+0x3b4/0x570
> > [=C2=A0=C2=A0317.337682]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__offline_pages+0x1ad/0xa10
> > [=C2=A0=C2=A0317.337683]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0offline_pages+0x11/0x20
> > [=C2=A0=C2=A0317.337683]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0memory_subsys_offline+0x7e/0xc0
> > [=C2=A0=C2=A0317.337684]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0device_offline+0xd5/0x110
> > [=C2=A0=C2=A0317.337685]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0state_store+0xc6/0xe0
> > [=C2=A0=C2=A0317.337686]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0dev_attr_store+0x3f/0x60
> > [=C2=A0=C2=A0317.337686]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0sysfs_kf_write+0x89/0xb0
> > [=C2=A0=C2=A0317.337687]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0kernfs_fop_write+0x188/0x240
> > [=C2=A0=C2=A0317.337688]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__vfs_write+0x50/0xa0
> > [=C2=A0=C2=A0317.337688]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0vfs_write+0x105/0x290
> > [=C2=A0=C2=A0317.337689]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0ksys_write+0xc6/0x160
> > [=C2=A0=C2=A0317.337690]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0__x64_sys_write+0x43/0x50
> > [=C2=A0=C2=A0317.337691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0do_syscall_64+0xcc/0x76c
> > [=C2=A0=C2=A0317.337691]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0entry_SYSCALL_64_after_hwframe+0x49/0xbe
>=20
> zone->lock --> console_sem->lock
>=20
> So then we have
>=20
> 	zone->lock --> console_sem->lock --> pi_lock --> rq->lock
>=20
>   vs. the reverse chain
>=20
> 	rq->lock --> console_sem->lock
>=20
> If I get this right.
>=20
> > [=C2=A0=C2=A0317.337693] other info that might help us debug this:
> >=20
> > [=C2=A0=C2=A0317.337694] Chain exists of:
> > [=C2=A0=C2=A0317.337694]=C2=A0=C2=A0=C2=A0(console_sem).lock --> &rq-=
>lock --> &(&zone->lock)->rlock
> >=20
> > [=C2=A0=C2=A0317.337699]=C2=A0=C2=A0Possible unsafe locking scenario:
> >=20
> > [=C2=A0=C2=A0317.337700]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0CPU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
> > [=C2=A0=C2=A0317.337701]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0----=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
> > [=C2=A0=C2=A0317.337701]=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)->rlock)=
;
> > [=C2=A0=C2=A0317.337703]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock(&rq->lock);
> > [=C2=A0=C2=A0317.337705]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock(&(&zone->lock)->rlock);
> > [=C2=A0=C2=A0317.337706]=C2=A0=C2=A0=C2=A0lock((console_sem).lock);
> >=20
> > [=C2=A0=C2=A0317.337708]=C2=A0=C2=A0*** DEADLOCK ***
> >=20
> > [=C2=A0=C2=A0317.337710] 8 locks held by test.sh/8738:
> > [=C2=A0=C2=A0317.337710]=C2=A0=C2=A0#0: ffff8883940b5408 (sb_writers#=
4){.+.+}, at: vfs_write+0x25f/0x290
> > [=C2=A0=C2=A0317.337713]=C2=A0=C2=A0#1: ffff889fce310280 (&of->mutex)=
{+.+.}, at: kernfs_fop_write+0x128/0x240
> > [=C2=A0=C2=A0317.337716]=C2=A0=C2=A0#2: ffff889feb6d4830 (kn->count#1=
15){.+.+}, at: kernfs_fop_write+0x138/0x240
> > [=C2=A0=C2=A0317.337720]=C2=A0=C2=A0#3: ffffffffb3762d40 (device_hotp=
lug_lock){+.+.}, at: lock_device_hotplug_sysfs+0x16/0x50
> > [=C2=A0=C2=A0317.337723]=C2=A0=C2=A0#4: ffff88981f0dc990 (&dev->mutex=
){....}, at: device_offline+0x70/0x110
> > [=C2=A0=C2=A0317.337726]=C2=A0=C2=A0#5: ffffffffb3315250 (cpu_hotplug=
_lock.rw_sem){++++}, at: __offline_pages+0xbf/0xa10
> > [=C2=A0=C2=A0317.337729]=C2=A0=C2=A0#6: ffffffffb35408b0 (mem_hotplug=
_lock.rw_sem){++++}, at:  percpu_down_write+0x87/0x2f0
> > [=C2=A0=C2=A0317.337732]=C2=A0=C2=A0#7: ffff88883fff4318 (&(&zone->lo=
ck)->rlock){-.-.}, at: start_isolate_page_range+0x1f7/0x570
> > [=C2=A0=C2=A0317.337736] stack backtrace:
> > [=C2=A0=C2=A0317.337737] CPU: 58 PID: 8738 Comm: test.sh Not tainted =
5.3.0-next-20190917+ #9
> > [=C2=A0=C2=A0317.337738] Hardware name: HPE ProLiant DL560 Gen10/ProL=
iant DL560 Gen10, BIOS U34 05/21/2019
> > [=C2=A0=C2=A0317.337739] Call Trace:
> > [=C2=A0=C2=A0317.337739]=C2=A0=C2=A0dump_stack+0x86/0xca
> > [=C2=A0=C2=A0317.337740]=C2=A0=C2=A0print_circular_bug.cold.31+0x243/=
0x26e
> > [=C2=A0=C2=A0317.337741]=C2=A0=C2=A0check_noncircular+0x29e/0x2e0
> > [=C2=A0=C2=A0317.337742]=C2=A0=C2=A0? debug_lockdep_rcu_enabled+0x4b/=
0x60
> > [=C2=A0=C2=A0317.337742]=C2=A0=C2=A0? print_circular_bug+0x120/0x120
> > [=C2=A0=C2=A0317.337743]=C2=A0=C2=A0? is_ftrace_trampoline+0x9/0x20
> > [=C2=A0=C2=A0317.337744]=C2=A0=C2=A0? kernel_text_address+0x59/0xc0
> > [=C2=A0=C2=A0317.337744]=C2=A0=C2=A0? __kernel_text_address+0x12/0x40
> > [=C2=A0=C2=A0317.337745]=C2=A0=C2=A0check_prev_add+0x107/0xea0
> > [=C2=A0=C2=A0317.337746]=C2=A0=C2=A0validate_chain+0x8fc/0x1200
> > [=C2=A0=C2=A0317.337746]=C2=A0=C2=A0? check_prev_add+0xea0/0xea0
> > [=C2=A0=C2=A0317.337747]=C2=A0=C2=A0? format_decode+0xd6/0x600
> > [=C2=A0=C2=A0317.337748]=C2=A0=C2=A0? file_dentry_name+0xe0/0xe0
> > [=C2=A0=C2=A0317.337749]=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
> > [=C2=A0=C2=A0317.337749]=C2=A0=C2=A0lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337750]=C2=A0=C2=A0? down_trylock+0x16/0x50
> > [=C2=A0=C2=A0317.337751]=C2=A0=C2=A0? vprintk_emit+0x100/0x340
> > [=C2=A0=C2=A0317.337752]=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
> > [=C2=A0=C2=A0317.337753]=C2=A0=C2=A0? down_trylock+0x16/0x50
> > [=C2=A0=C2=A0317.337753]=C2=A0=C2=A0down_trylock+0x16/0x50
> > [=C2=A0=C2=A0317.337754]=C2=A0=C2=A0? vprintk_emit+0x100/0x340
> > [=C2=A0=C2=A0317.337755]=C2=A0=C2=A0__down_trylock_console_sem+0x2b/0=
xa0
> > [=C2=A0=C2=A0317.337756]=C2=A0=C2=A0console_trylock+0x16/0x60
> > [=C2=A0=C2=A0317.337756]=C2=A0=C2=A0vprintk_emit+0x100/0x340
> > [=C2=A0=C2=A0317.337757]=C2=A0=C2=A0vprintk_default+0x1f/0x30
> > [=C2=A0=C2=A0317.337758]=C2=A0=C2=A0vprintk_func+0x44/0xd4
> > [=C2=A0=C2=A0317.337758]=C2=A0=C2=A0printk+0x9f/0xc5
> > [=C2=A0=C2=A0317.337759]=C2=A0=C2=A0? kmsg_dump_rewind_nolock+0x64/0x=
64
> > [=C2=A0=C2=A0317.337760]=C2=A0=C2=A0? __dump_page+0x1d7/0x430
> > [=C2=A0=C2=A0317.337760]=C2=A0=C2=A0__dump_page.cold.2+0x73/0x210
> > [=C2=A0=C2=A0317.337761]=C2=A0=C2=A0dump_page+0x12/0x50
> > [=C2=A0=C2=A0317.337762]=C2=A0=C2=A0has_unmovable_pages+0x3e9/0x4b0
> > [=C2=A0=C2=A0317.337763]=C2=A0=C2=A0start_isolate_page_range+0x3b4/0x=
570
> > [=C2=A0=C2=A0317.337763]=C2=A0=C2=A0? unset_migratetype_isolate+0x280=
/0x280
> > [=C2=A0=C2=A0317.337764]=C2=A0=C2=A0? rcu_read_lock_bh_held+0xc0/0xc0
> > [=C2=A0=C2=A0317.337765]=C2=A0=C2=A0__offline_pages+0x1ad/0xa10
> > [=C2=A0=C2=A0317.337765]=C2=A0=C2=A0? lock_acquire+0x126/0x280
> > [=C2=A0=C2=A0317.337766]=C2=A0=C2=A0? __add_memory+0xc0/0xc0
> > [=C2=A0=C2=A0317.337767]=C2=A0=C2=A0? __kasan_check_write+0x14/0x20
> > [=C2=A0=C2=A0317.337767]=C2=A0=C2=A0? __mutex_lock+0x344/0xcd0
> > [=C2=A0=C2=A0317.337768]=C2=A0=C2=A0? _raw_spin_unlock_irqrestore+0x4=
9/0x50
> > [=C2=A0=C2=A0317.337769]=C2=A0=C2=A0? device_offline+0x70/0x110
> > [=C2=A0=C2=A0317.337770]=C2=A0=C2=A0? klist_next+0x1c1/0x1e0
> > [=C2=A0=C2=A0317.337770]=C2=A0=C2=A0? __mutex_add_waiter+0xc0/0xc0
> > [=C2=A0=C2=A0317.337771]=C2=A0=C2=A0? klist_next+0x10b/0x1e0
> > [=C2=A0=C2=A0317.337772]=C2=A0=C2=A0? klist_iter_exit+0x16/0x40
> > [=C2=A0=C2=A0317.337772]=C2=A0=C2=A0? device_for_each_child+0xd0/0x11=
0
> > [=C2=A0=C2=A0317.337773]=C2=A0=C2=A0offline_pages+0x11/0x20
> > [=C2=A0=C2=A0317.337774]=C2=A0=C2=A0memory_subsys_offline+0x7e/0xc0
> > [=C2=A0=C2=A0317.337774]=C2=A0=C2=A0device_offline+0xd5/0x110
> > [=C2=A0=C2=A0317.337775]=C2=A0=C2=A0? auto_online_blocks_show+0x70/0x=
70
> > [=C2=A0=C2=A0317.337776]=C2=A0=C2=A0state_store+0xc6/0xe0
> > [=C2=A0=C2=A0317.337776]=C2=A0=C2=A0dev_attr_store+0x3f/0x60
> > [=C2=A0=C2=A0317.337777]=C2=A0=C2=A0? device_match_name+0x40/0x40
> > [=C2=A0=C2=A0317.337778]=C2=A0=C2=A0sysfs_kf_write+0x89/0xb0
> > [=C2=A0=C2=A0317.337778]=C2=A0=C2=A0? sysfs_file_ops+0xa0/0xa0
> > [=C2=A0=C2=A0317.337779]=C2=A0=C2=A0kernfs_fop_write+0x188/0x240
> > [=C2=A0=C2=A0317.337780]=C2=A0=C2=A0__vfs_write+0x50/0xa0
> > [=C2=A0=C2=A0317.337780]=C2=A0=C2=A0vfs_write+0x105/0x290
> > [=C2=A0=C2=A0317.337781]=C2=A0=C2=A0ksys_write+0xc6/0x160
> > [=C2=A0=C2=A0317.337782]=C2=A0=C2=A0? __x64_sys_read+0x50/0x50
> > [=C2=A0=C2=A0317.337782]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
> > [=C2=A0=C2=A0317.337783]=C2=A0=C2=A0? do_syscall_64+0x79/0x76c
> > [=C2=A0=C2=A0317.337784]=C2=A0=C2=A0__x64_sys_write+0x43/0x50
> > [=C2=A0=C2=A0317.337784]=C2=A0=C2=A0do_syscall_64+0xcc/0x76c
> > [=C2=A0=C2=A0317.337785]=C2=A0=C2=A0? trace_hardirqs_on_thunk+0x1a/0x=
20
> > [=C2=A0=C2=A0317.337786]=C2=A0=C2=A0? syscall_return_slowpath+0x210/0=
x210
> > [=C2=A0=C2=A0317.337787]=C2=A0=C2=A0? entry_SYSCALL_64_after_hwframe+=
0x3e/0xbe
> > [=C2=A0=C2=A0317.337787]=C2=A0=C2=A0? trace_hardirqs_off_caller+0x3a/=
0x150
> > [=C2=A0=C2=A0317.337788]=C2=A0=C2=A0? trace_hardirqs_off_thunk+0x1a/0=
x20
> > [=C2=A0=C2=A0317.337789]=C2=A0=C2=A0entry_SYSCALL_64_after_hwframe+0x=
49/0xbe
>=20
> Lovely.
>=20
> 	-ss

