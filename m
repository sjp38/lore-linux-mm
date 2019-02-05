Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E75DAC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:16:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9965F2081B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:16:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="ROWLTkl6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9965F2081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F3668E0078; Tue,  5 Feb 2019 02:16:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1078E001C; Tue,  5 Feb 2019 02:16:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2429A8E0078; Tue,  5 Feb 2019 02:16:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4BC88E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 02:16:26 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id j24-v6so417455lji.20
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 23:16:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FgdDrEwRt2DcpNMQgDQ7LK+wdPfSmuc4/VBeDOvNh8s=;
        b=co9NhiodJirZ6U3C4VPMsNPmvHg+pzW4XFXR6GbDyw2gg2CD97Lr9XKpDZcaa/EgE1
         Xsf+GEdyVkfZxfQoMFzUgZ5KLWZhZwcZeHuW7ZS330ifLafamnBazwftXR5nSgQKGj2Q
         oiVLb80xN18F07Fzuadlo+/r6HYKjomG+6KGdlJIGff7tm/JzR8h7GHb/A+woBmVTfHy
         F2v+2M71OLRBtzTIycwwG3I0+i4cYdfbC16JwsKmDwldCP7Hk3erLPBt7ytMSEmT4XKH
         o2/EqW576ojT71Szy3wnEcw7PcNSpeywB90KJJQMTofWDzNNF7Eb54qVrNMFRYrRj2jH
         +grw==
X-Gm-Message-State: AHQUAuZ+AZ07018+Rrcox4aoLciYXKtFf5AFV7hCsikahKl9XgK2GHd1
	pdI9vAJGVmvTx8mVpfw+6BsN2QOUvs+ZcGJnW7fA7S7g/VG94QDIp7pUUWt9DXrORy3uQzmKWWS
	t8aGvzVKPneRuXI70wvLGgq7MmZ8xvoNGeywrx0OSJ7VrmHrUrYHp1NQ8uN+p0Qpbn/Yf9ZGF3d
	iWnlCzA8ZOPnFJE3ZHpK0rRPQkGcrHsPbKp/FttHJ40CRDaAg68v+Wf3nm91Vi+fqNXSEJT7But
	IIbcB4xRM7MIdRPz3vxaWkr+Y3iHW4TZKE3jbH0DTbE1iOA4izfE+ozUWXXalQuybJ2Z7/wQ8ZC
	DuKU7UIfxP06Qu/tZUqQmY75ORpgEcQTplJ+K7Bp/UmZ6kF/1rS5qJGKZnsNdDw49fnb2bfK0iu
	L
X-Received: by 2002:a2e:2e1a:: with SMTP id u26-v6mr2034643lju.8.1549350985783;
        Mon, 04 Feb 2019 23:16:25 -0800 (PST)
X-Received: by 2002:a2e:2e1a:: with SMTP id u26-v6mr2034614lju.8.1549350984863;
        Mon, 04 Feb 2019 23:16:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549350984; cv=none;
        d=google.com; s=arc-20160816;
        b=DG84ySLHM5DXi8XQg+oFD91CM3B9neivxzyIsRMwpyOPsr1yZ6C2nUnBEsvEAKoYbB
         ZYmw0N5JlJ+1Yzg9+0YLhdlRacGs+0eliVNDtjffQ0+FT+vvQhtc5QlSVcQAZB/ysp3J
         XoYrKL1iPAmJauzWplpbgKS4p6TIJ60uyLGTUduJr7NKpYf3D/D335DVb0UxyFuE6YpP
         VWFVnfjnG06UZTFtarQNL6Zo7lL++0xqGIhz4bix93I96FIaC/0Qt2Mwl2r0MBVAjjoN
         x0L+uns1vRNBhh4xbee3ln3HExMoKt4UABQjlYytkhexrBY50mRKVX4L5OQkdI4CK0YJ
         HQSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FgdDrEwRt2DcpNMQgDQ7LK+wdPfSmuc4/VBeDOvNh8s=;
        b=T/wy5evNWARx0j542aA6pZfL3n3V1c9J20gl2X2ta0UxQky+FoQEGktHEHnMP75ndD
         nTFMjj/Z2KKi9bySToP7bmV3OttRdE4YryAA/y1QsSxPFWkqmAt4dHmP0CH/DBanvqsH
         Ik1PXBUmZ6i3asnpm+5uTQ5ZkZT94AHZxuIeV1dR2Us0banZHlZiV7DhkQjc/RVPGBMd
         fIEnYJf2eje/huIn7xRtjyn2cbzZNEzdnKBsy1jwl3yfbwVrUNf/lBXjCfKAtvcLOhKV
         91yIN6LoLMdv5ETi4X8GvvbpuFtHGfV1mWUduxWI+wSLgoBaLuXEnhWxvJdTS3qEZJ6i
         PTdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ROWLTkl6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m72sor5055726lfe.8.2019.02.04.23.16.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 23:16:24 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=ROWLTkl6;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FgdDrEwRt2DcpNMQgDQ7LK+wdPfSmuc4/VBeDOvNh8s=;
        b=ROWLTkl6aQWh6v4hDyodVTmi62aCjx3oJ3nOE4h/bRrNbt5gz5CQAJHmOnqGnqBKLS
         E3v5lJDRWBRGLKXHpkKHL36TLgLdbBIaI5qMC++5W8vI36p8DuGFSJvPkC/ZfkTb/tvi
         n3XYFHHlTj2tGSBRrlxH7DCv5Ayw7V47zImQo=
X-Google-Smtp-Source: AHgI3IZD1oUvZVidg6Kj7mJO48TtG1pUonqM1ERyWo/x842Jdlr1MZjcKzf6kNUABNGiBoaSqmQEKQ==
X-Received: by 2002:a19:920a:: with SMTP id u10mr2226958lfd.122.1549350983710;
        Mon, 04 Feb 2019 23:16:23 -0800 (PST)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com. [209.85.167.46])
        by smtp.gmail.com with ESMTPSA id s9-v6sm3102239lja.12.2019.02.04.23.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 23:16:22 -0800 (PST)
Received: by mail-lf1-f46.google.com with SMTP id i26so1875912lfc.0
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 23:16:21 -0800 (PST)
X-Received: by 2002:a19:ab09:: with SMTP id u9mr2059854lfe.149.1549350981411;
 Mon, 04 Feb 2019 23:16:21 -0800 (PST)
MIME-Version: 1.0
References: <20190204091300.GB13536@shodan.usersys.redhat.com> <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Feb 2019 07:16:05 +0000
X-Gmail-Original-Message-ID: <CAHk-=wjXP6dnbdeLryqrMCG8+-yk1G7gcSKiopDKDEj0AdzdAA@mail.gmail.com>
Message-ID: <CAHk-=wjXP6dnbdeLryqrMCG8+-yk1G7gcSKiopDKDEj0AdzdAA@mail.gmail.com>
Subject: Re: mm: race in put_and_wait_on_page_locked()
To: Hugh Dickins <hughd@google.com>
Cc: Artem Savkov <asavkov@redhat.com>, Baoquan He <bhe@redhat.com>, Qian Cai <cai@lca.pw>, 
	Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 4, 2019 at 8:43 PM Hugh Dickins <hughd@google.com> wrote:
>
> Something I shall not be doing, is verifying the correctness of the
> low-level get_page_unless_zero() versus page_ref_freeze() protocol
> on arm64 and power - nobody has reported on x86, and I do wonder if
> there's a barrier missing somewhere, that could manifest in this way -
> but I'm unlikely to be the one to find that (and also think that any
> weakness there should have shown up long before now).

Remind me what the page_ref_freeze() rules even _are_?

It's a very special thing, setting the page count down to zero if it
matches the "expected" count.

Now, if another CPU does a put_page() at that point, that certainly
will hit the "oops, we dropped the ref to something that was zero".

So the "expected" count had better be only references we have and own
100%, but some of those references aren't really necessarily private
to our thread.

For example, what happens if

 (a) one CPU is doing migration_entry_wait() (counting expected page
refs etc, before doing page_ref_freeze)

 (b) another CPU is dirtying a page that was in the swap cache and
takes a reference to it, but drops it from the swap cache

Note how (b) does not change the refcount on the page at all, because
it just moves the ref-count from "swap cache entry" to "I own the page
in my page tables". Which means that when (a) does the "count expected
count, and match it", it happily matches, and the page_ref_freeze()
succeeds and makes the page count be zero.

But now (b) has a private reference to that page, and can drop it, so
the "freeze" isn't a freeze at all.

Ok, so clearly the above cannot happen, and there's something I'm
missing with the freezing. I think we hold the page lock while this is
going on, which means those two things cannot happen at the same time.
But maybe there is something else that does the above kind of "move
page ref from one owner to another"?

The page_ref_freeze() rules don't seem to be documented anywhere.

             Linus

