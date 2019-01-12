Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072DCC43387
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 02:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE9620870
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 02:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iLgpakor"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE9620870
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A24F8E0003; Fri, 11 Jan 2019 21:58:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44F838E0001; Fri, 11 Jan 2019 21:58:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318698E0003; Fri, 11 Jan 2019 21:58:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDDEB8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 21:58:48 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y7so5294807wrr.12
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:58:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oA0YpQMCdJU1zfIVfz2vDT77FI6zrfK8PmyJGe88nf0=;
        b=Ef/HikTBF0PX/cXBxXTckfEZE3CO950rV01Iy8vSmkwvhpKAGtlDsc0XlQC9S01cNx
         dsvRjczSWiBBu/Cq2FwSX9OM9uTWEA/l4m+ZvMH1LjLkeeJf/0BtAWO8kpqCtoiY1w1B
         pcj4TYGlFoCBMOSB+LP/7D+nxL0hw27hUsjJlzeJ+CFXI0VWDXUjHXTwbjWwen2FsdzN
         3NUVVsXBWqCgXL3pg46QzcAgOx/eqR2F+wm89gFtGdBtPnuIqC5MWk7Cx53YRb81dVL5
         2GcROcaPMsVFxaullQfX40qyiIXIhwE8v+c7Wdb1W7WwgnQoI2YH1IyU343Vd8TzIB7y
         34qw==
X-Gm-Message-State: AJcUukf6Pmba8h1gyPGSsa3lgPoRzf4x2dkcSoXRl+GyliTSZ9x8gwHv
	GZeAvMa3Gqewq0YYXHlVlLgiH9GoWTwIxs6ZIQTc+LV2Nnt2QrvWZ+9/KK3/nKc7+ty2FYbTnGv
	TWkks4CMstf4y2XZt0MYXeYvxQ8yHyWSkpmgRFz3HdTbfTnTUWC42whU98yqpUuTA60m5QlS39F
	T7cLwdJb2FfnZRYSrbqK98GyZ0P65JkBz3TETxjrmHasCDWjQ3mdYWPZ2KqXOZLvTNjd6o0XN8Y
	xEZPdReDy6ebZWjs/NJ4+5exiGMmMwiY5r6+pVF5WY8cWguzqUVFrc/CNf/p9XtZHddsglS412/
	VDIvWJ4xRUPO96tMpnHQ0KYWVQCvtmEctlkM92J8Pr2eY/zud0Dzbp0CKp6eKRxi33s8Rf4Svv6
	c
X-Received: by 2002:a5d:63c3:: with SMTP id c3mr15531052wrw.215.1547261928372;
        Fri, 11 Jan 2019 18:58:48 -0800 (PST)
X-Received: by 2002:a5d:63c3:: with SMTP id c3mr15531031wrw.215.1547261927514;
        Fri, 11 Jan 2019 18:58:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547261927; cv=none;
        d=google.com; s=arc-20160816;
        b=Jd3SsDm5Vk4KKN5D5AnXXFTVzUld9EMhAghxHKhtJ343E9s38P1MKxfZs1w9Itfmtb
         F2OnrkuNMVou9SRpxtbxHoSjazsPffajw6APcrFRXSHy9SgfDXltBN6yvrEC/OlvYdwh
         iOBU5s2KJhOO8ZpnSDEG/XMHTFses8SIUi8VILFTeMIEQ5hJkCKLpG7sAA4QUKhVLFlW
         HZZQF58KyjRYyPIbTkVrwTfiVG1lyJxNpBgn/mAm0liCCrdgSEVPUo5TaeWs1lL0YfPM
         HLHG1WG7WJHxykITP7yuY7coTm8/3KaHJIa6Ku1E49FXleHRD2rKh5zUzUJwGn6lEjQm
         R1eA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oA0YpQMCdJU1zfIVfz2vDT77FI6zrfK8PmyJGe88nf0=;
        b=G7mtxyROAJJN+dnmLPVxbMhmImdllasdYAG7s2OYo9cJC+shrHhkAUfu3C6zL2eEy6
         62uXm3e1NFXXXJ0ZG7qJspAGk2Ui1CWAzhHlr6VqS8IMSbJqxzYiagXX0mcKu2OvfOP+
         xVKawwXXUdrrXVquSssiI84URtOX+s6NVAY7M4S3ZYZyiEev5bNmQqXm+TpsJhlYVNsA
         Szc3PzjnbmK1HlERk3NZKSCJCl6Wle2GZ5qmpQQiltjQfuiQpklbsOWwyAFXrWP9mZ2C
         WsETgWY8uI52+/InDKET5io6pccC01DMtKG7NLSmDCNPvlgfHA36SUYK/KoDhf9vt1/g
         k8gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iLgpakor;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor5300680wrv.44.2019.01.11.18.58.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 18:58:47 -0800 (PST)
Received-SPF: pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iLgpakor;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oA0YpQMCdJU1zfIVfz2vDT77FI6zrfK8PmyJGe88nf0=;
        b=iLgpakorSqfoGh51GzcIxeWq0hiHYjCnbrtcaS9N8pkXYywPrAlJe9Tyiz7J12ZjS7
         ZM4O1suQFAiFyoe0zMGmOa/gbzDG+a2bjCXFhpX7Bt2OZfP35C7+Z1+eOu+Eq+7yFILW
         UZCfpqrqASl++Pym/PWkOGDxJjfUS0/kAawW74ehg9mIVx1+oCu/ttNe02xmeS9iFYB/
         3Ql0apirfHi5TOi87Aw0oxVwffn/WzaT4CWysWjQ9ocQTLb2ksT9pypAj89fdu/CWjXj
         72MobcQlEe73OIeT4B+OcbWKc6/9oxbeLydbPz0f72L3EPO5vQo2ZNX6ldQctf0Jkl0q
         wZmg==
X-Google-Smtp-Source: ALg8bN4K8kdswqFPg8E9VgzjlKUzEkixsQIlYoKhQ+uyxRmx+ztTcv8ihe5tqARyVlUkYDwnHjPoyQCaWf3pD/LyKCA=
X-Received: by 2002:adf:9246:: with SMTP id 64mr16726152wrj.130.1547261926762;
 Fri, 11 Jan 2019 18:58:46 -0800 (PST)
MIME-Version: 1.0
References: <20190111181600.GJ6310@bombadil.infradead.org> <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
In-Reply-To: <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
From: Michel Lespinasse <walken@google.com>
Date: Fri, 11 Jan 2019 18:58:33 -0800
Message-ID:
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
Subject: Re: [PATCH v2] rbtree: fix the red root
To: David Lechner <david@lechnology.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, esploit@protonmail.ch, 
	jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, 
	joeypabalinas@gmail.com, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190112025833.23v80FeufoeeslLmuKkrq3PH6nAKj7OR1bxKIeBqJy8@z>

On Fri, Jan 11, 2019 at 3:47 PM David Lechner <david@lechnology.com> wrote:
>
> On 1/11/19 2:58 PM, Qian Cai wrote:
> > A GPF was reported,
> >
> > kasan: CONFIG_KASAN_INLINE enabled
> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > general protection fault: 0000 [#1] SMP KASAN
> >          kasan_die_handler.cold.22+0x11/0x31
> >          notifier_call_chain+0x17b/0x390
> >          atomic_notifier_call_chain+0xa7/0x1b0
> >          notify_die+0x1be/0x2e0
> >          do_general_protection+0x13e/0x330
> >          general_protection+0x1e/0x30
> >          rb_insert_color+0x189/0x1480
> >          create_object+0x785/0xca0
> >          kmemleak_alloc+0x2f/0x50
> >          kmem_cache_alloc+0x1b9/0x3c0
> >          getname_flags+0xdb/0x5d0
> >          getname+0x1e/0x20
> >          do_sys_open+0x3a1/0x7d0
> >          __x64_sys_open+0x7e/0xc0
> >          do_syscall_64+0x1b3/0x820
> >          entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > It turned out,
> >
> > gparent = rb_red_parent(parent);
> > tmp = gparent->rb_right; <-- GPF was triggered here.
> >
> > Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
> > which is red. Otherwise, it will be treated properly a few lines above.
> >
> > /*
> >   * If there is a black parent, we are done.
> >   * Otherwise, take some corrective action as,
> >   * per 4), we don't want a red root or two
> >   * consecutive red nodes.
> >   */
> > if(rb_is_black(parent))
> >       break;
> >
> > Hence, it violates the rule #1 (the root can't be red) and need a fix
> > up, and also add a regression test for it. This looks like was
> > introduced by 6d58452dc06 where it no longer always paint the root as
> > black.
> >
> > Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
> > when necessary)
> > Reported-by: Esme <esploit@protonmail.ch>
> > Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
>
> Tested-by: David Lechner <david@lechnology.com>
> FWIW, this fixed the following crash for me:
>
> Unable to handle kernel NULL pointer dereference at virtual address 00000004

Just to clarify, do you have a way to reproduce this crash without the fix ?

I don't think the fix is correct, because it just silently ignores a
corrupted rbtree (red root node). But the code that creates this
situation certainly needs to be fixed - having a reproduceable test
case would certainly help here.

Regarding 6d58452dc06, the reasoning was that this code expects to be
called after inserting a new (red) leaf into an rbtree that had all of
its data structure invariants satisfied. So in this context, it should
not be necessary to always reset the root to black, as this should
already be the case...

