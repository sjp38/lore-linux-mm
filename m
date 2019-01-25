Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9CA4C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 04:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DE85218A6
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 04:19:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GWwUloLc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DE85218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7C8E8E00B6; Thu, 24 Jan 2019 23:19:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2B858E00B5; Thu, 24 Jan 2019 23:19:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42058E00B6; Thu, 24 Jan 2019 23:19:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81E1A8E00B5
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:19:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g12so5461178pll.22
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:19:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=v958TPGd4/hka73djmxBpKoCgDXtGpOi9Y+UjzF5q/8=;
        b=A7NQkwJZi2FYNhE48H5VF9u7ct4X3ROyHOb2BH3MaVHarhrbtXJ99FSN36RyZyoiUv
         RSYTrFyQYr4lPRfS+GcJU4HDYk+69sfOChW8SOjS4Vu3KBcCCic2yCGzX1jY669kEIqU
         /DngOsTMWbxy07zRFqp4qLGorZH8fH3voX8JEaN+0TIjK1dfAouvRczMqnIY8dBdm8cQ
         Wjnon8cMXPU4Pj8NEAsnwJ9kYJI/hWupJL22V8V5AlfT05vcXIISozTdnsK594o1Z1+f
         ODi9XeqDJE+cwwzRCE2/P9rVsWD5vWVucsUILZITLbmCcnZ4w/2bE3/FSi/niPAd3GU9
         /KeQ==
X-Gm-Message-State: AJcUukeLL2vI4mMoi1R0IKEj/hdWbFm8n0eCjOgKPVYr/oFvc7HmAzvs
	tGiFBekLaF5rJof4cnjgYFIV9qj0OvkPH6BOWwx2rNRmW/FZzmkkJq3KlsRkS+jpV/P6Ib8+lom
	bq/j2W1tEy7muuzsU2W6QooXu3glUESn/Y6zpQ70FI0EqCqT7eSNRMb3b+TYBJ/rgMgnIF0Ii5z
	9H3ZfqG5qb0/n/x/5bcezQ/rm08yDawSCBmnAYZCUcuhu3p6OeLU+62IeXcbFQe78wuOkzCHDG1
	FbhDg83EXvKJGidYn1xBhBsNvfNAhxX7M2OjvKOIabnNjckPoaNAUzik7dQJmdZK62hiEiSupgb
	YE+QkbFL6cSx5bWyIixTAXV9aT9TyX5M00Qd6YuNKVOwK02QIBQmr21DAfojJy6TwzjhG48GJj/
	U
X-Received: by 2002:a17:902:209:: with SMTP id 9mr9532585plc.288.1548389996031;
        Thu, 24 Jan 2019 20:19:56 -0800 (PST)
X-Received: by 2002:a17:902:209:: with SMTP id 9mr9532540plc.288.1548389994985;
        Thu, 24 Jan 2019 20:19:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548389994; cv=none;
        d=google.com; s=arc-20160816;
        b=yPvMXrgTyhyZepnSD710zN/6sQSYV0GibVqYH1+3S/I+jXhgJQu+s9yn08TqWHKWsS
         QAG0xiQBaVdiby+jmXlDsjcVXKsAEGGf1MgPxx4xup6InXJBVd85fKeNqeDMKL2eTOJg
         kq1Lexj1Pj/D4LruAMmgL4uI+X7JupRG+ZiKaZttFUJVBezDBQ2qjS9jekkK7+hvUvQX
         qIgJ4xwUAvb2j5biZd1oOSpFhWQx0EBOqhmZ9/mKDGissdhUImFpRAPIFrB5oiScVMvh
         Klr1uSpe5CmUoxeHB3n9BRaN7pySaVoz/W0QL7K1h4SO9ezgUq4BlBKr6JICymsbc4XO
         7g8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=v958TPGd4/hka73djmxBpKoCgDXtGpOi9Y+UjzF5q/8=;
        b=cVOL7D+I+w78D6UDZXwDBUfQz8dGOdqtjFpUp2MGfdlxIx7FcdzJdRFsyPSc1wANOB
         TLXgzd0JkYoKcrEMQ01FkHYWXx00P439kHAjPq9MJC67NTj1uSA77XieG0vqmlIQFta1
         vcA6zooH2VzMkd4JRkGMiB3FYPL59yWCh3nh6/kijNkQqm96qyoSmyaQXT5Ps+ZPXquN
         nvAisDkKKCeadO/22+bvy9ZHb+2iAuLeNESYpSLntH2MotHdXgcx8eFn8sFMgbRzXVUf
         G7XStYNWUVkyL869wcHF/zjETtiC0rDHb0YXT+rGZavSHGIRjlhhXYZ7ZE7sM5zGkeMz
         5RDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GWwUloLc;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n11sor34371640pfk.44.2019.01.24.20.19.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 20:19:54 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GWwUloLc;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=v958TPGd4/hka73djmxBpKoCgDXtGpOi9Y+UjzF5q/8=;
        b=GWwUloLcFlHXKuXqcyGGP0+z+PKdikla/KjDJ68nkzlyCoK6daJzPMUZGL5+xeCBO6
         Bp7La7Ei2Kf/r4KWuAiHVLqpuJ31giSLeaILW5awNWgxGE0Tdxc9zwyH4iRkA1KV5kGV
         zGv/vRE8LbzjtMGBbyR11MmYJLO/SAKAg7HboWZSVExyX6LRcpockE60J8tOvIadEmOF
         aKGAzYnHp1NDbti/USh793RcdWgjth3aVNTlupoqQ0RjCabjgV59gOKGsFQNyss/lzHH
         Cmjpwe65Vsjrhz2oVzW4e0u8/KkC5ozhjFqLMSH41oXvu/CB6I63fkUMnRo3FODRihxP
         Wmvg==
X-Google-Smtp-Source: ALg8bN7l+EaYQtxKu+A1pEdaS0VJYXBAxmSDq/YL72LVesvoqDELB0vKnU0JNFfrRJ4nHrwr2eljYg==
X-Received: by 2002:a62:8a51:: with SMTP id y78mr9278486pfd.35.1548389994002;
        Thu, 24 Jan 2019 20:19:54 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id m65sm54142060pfg.180.2019.01.24.20.19.52
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 Jan 2019 20:19:52 -0800 (PST)
Date: Thu, 24 Jan 2019 20:19:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Qian Cai <cai@lca.pw>
cc: Michal Hocko <mhocko@suse.com>, hughd@google.com, 
    Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, 
    vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
In-Reply-To: <20190123093002.GP4087@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw> <20190123093002.GP4087@dhcp22.suse.cz>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125041945.jcDtUlo7gWk3JE6Rn6uI1Xbl4arfjZA697FI7mjSvSE@z>

On Wed, 23 Jan 2019, Michal Hocko wrote:
> On Tue 22-01-19 23:29:04, Qian Cai wrote:
> > Running LTP migrate_pages03 [1] a few times triggering BUG() below on an arm64
> > ThunderX2 server. Reverted the commit 9a1ea439b16b9 ("mm:
> > put_and_wait_on_page_locked() while page is migrated") allows it to run
> > continuously.
> > 
> > put_and_wait_on_page_locked
> >   wait_on_page_bit_common
> >     put_page
> >       put_page_testzero
> >         VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> > 
> > [1]
> > https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages03.c
> > 
> > [ 1304.643587] page:ffff7fe0226ff000 count:2 mapcount:0 mapping:ffff8095c3406d58 index:0x7
> > [ 1304.652082] xfs_address_space_operations [xfs]
> [...]
> > [ 1304.682652] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> 
> This looks like a page reference countimbalance to me. The page seemed
> to be freed at the the migration code (wait_on_page_bit_common) called
> put_page and immediatelly got reused for xfs allocation and that is why
> we see its ref count==2. But I fail to see how that is possible as
> __migration_entry_wait already does get_page_unless_zero so the
> imbalance must have been preexisting.

This report worried me, but I've thought around it, and agree with
Michal that it must be reflecting a preexisting refcount imbalance -
preexisting in the sense that the imbalance occurred sometime before
reaching put_and_wait_on_page_locked(), and in the sense that the bug
causing the imbalance came in before the put_and_wait_on_page_locked()
commit, perhaps even long ago.

If it is a software bug at all - I wonder if any other hardware shows
the same issue - I have not seen it on x86 (though I wasn't using xfs),
nor heard of anyone else reporting it - but thank you for doing so,
it could be important.

But I (probably) disagree with Michal about the page being freed and
reused for xfs allocation. I have no proof, but I think the likelihood
is that the page shown is the old xfs page (from libc-2.28.so, I see)
which is currently being migrated.

I realize that "last migrate reason: syscall_or_cpuset" would not get 
set until later, but I think it's left over from the previous migration:
migrate_pages03 looks like it's migrating pages back and forth repeatedly.

What I think happened is that something at some time earlier did a
mistaken put_page() on the page.  Then __migration_entry_wait() raced
with migrate_page_move_mapping(), in such a way that get_page_unless_zero()
then briefly raised the page's refcount to expected_count, so migration was
able to freeze the page (set its refcount transiently to 0).  Then put_and
_wait_on_page_locked() reached the put_page() in wait_on_page_bit_common()
while migration still had the refcount frozen at 0, and bang, your crash.

But how come reverting the put_and_wait commit appears to fix it for you?
That puzzled me, for a while I expected you then to see an equally visible
crash in the old put_page() after wait_on_page_locked(), or else at the
migration end where it puts the page afterwards (putback_lru_page perhaps).

I guess the answer comes from that "libc-2.28.so".  This page is one of
those very popular pages which were next-to-impossible to migrate before
the put_and_wait commit, because they are so widely mapped, and their
migration entries so frequently faulted, that migration could not freeze
them.  (With enough migration waiters to outweigh the off-by-one of the
incorrect refcount.)

Being so widely used, the refcount imbalance on that page would (I think)
only show up when unmounting the root at shutdown: easily missed.

So I think you've identified that the put_and_wait commit has exposed
an existing bug, and it may be very tedious to track down where that is.
Maybe the bug is itself triggered by migrate_pages03, but quite likely not.

Hugh

