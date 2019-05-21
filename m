Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34B95C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE68721773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:55:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EOkHN4OY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE68721773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770626B0003; Mon, 20 May 2019 22:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7211F6B0005; Mon, 20 May 2019 22:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60ECD6B0006; Mon, 20 May 2019 22:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1286B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:55:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so11125610pga.4
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TZunHuUt7tyDrtFDeA5ZZ4ZwMnBTbuylcZfIETnEBPY=;
        b=XSbdEdbXfU5/3h/74EoaVogef/foVJ6Nfsoj/0Dma2SfFqh6itIfR9JaF244L4bZ91
         q8p+Bx+4gh02iKJlEng72tHec0rhk18/YmyhMLDBd/hX06iV//wTHg75IKxIR+jLVPiY
         9PBdtR4crIHJIopJ1oMRj3vv6x4Pi+ck5ZgBYI/a7S+jp2HE53SasOuc3Cxs5ZEgEFgK
         GcjK4ESkkUDLQALiN5z2eCEXX/kfptTtTFw942YX5jny6axF0WDpu2Jxkkczc9MInllq
         stqfAQ4gEydYi3C6FF+7ygG18lf1GJE2HVwQKmUz0jIW9WVjQ8hvQVQapjBF5WPv/8Ok
         6QIA==
X-Gm-Message-State: APjAAAVOHdWrK/ipqum1Q+tIj3FpmcxkTfWCGMkf3HVwAB7bKZ/6xs6H
	+JmP/Ied4BklrmidhNABgl7s10DvAkH3G/2GtzrasFVmavEdY2aBLpbgT5Jk5cwlqrov4doe9tb
	BeWFNUVGKkETLA+4t5nrXiWHhlOtVOj407TbksU9qHTs4E2zdqBEyY16IHpkF8fo=
X-Received: by 2002:aa7:808d:: with SMTP id v13mr52956590pff.198.1558407341821;
        Mon, 20 May 2019 19:55:41 -0700 (PDT)
X-Received: by 2002:aa7:808d:: with SMTP id v13mr52956536pff.198.1558407340992;
        Mon, 20 May 2019 19:55:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558407340; cv=none;
        d=google.com; s=arc-20160816;
        b=lr6svbl9FTU7mcn6ALdN4qSdIUdry1nKIHPYpSNdWgjR0Mv+TD/Z0IY7h/HEVWu0yA
         mARhMUGpuSQmukRrI9/XdmrRgxk+Up6RSk7NxLxHiBzNuUiIWbSuAxVYpolE3vaYKFAT
         T5O/Hz5JHGeJphvZO4vcBAaYoD7yLmq+NHelFiuTFV0MZNNV5lCdDwgdIwj9R+QYtVop
         VqBEzJKNZuvZ1F/cTVSOXB6GY4BbyLfQtF3U4+bzTEsj9X4YgYqJ3R0cHvsxPmQIjVYl
         8ck3A0JFYpBoRypWTtwUwemvlUVICd3xw0PMG5YjoGcZg+VXvp5y6bdTuQLw5piU/NCf
         V6yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=TZunHuUt7tyDrtFDeA5ZZ4ZwMnBTbuylcZfIETnEBPY=;
        b=kKQkc8q4hxnbtPjqIb3NhUZFPEf8T9+8TgAQpQtezyw8mCvH7k/pGoErW/IyvXEdvj
         cU0aZ3qh07kgnahEnxfx+po5/UIHWT3ZlWqrDcuRUbOCPW7wi+/Ruj2TQ+5u67YS0adl
         GU81WPjna7TGVuWYa0EnIiEI8rxPAioVRBncPQlPOnYhhzlVH484HlwRdK/qX6cKd4HV
         Vcvk/iTAwbcuzSiw0sGygnXjnAr/HnX6JhnxyPY5oc4J238kbIW79tuCQo2o6PzkdCKx
         Hw0wG712967EjnTJQJxFylxQuqeJb/6s7Xalfzt4cCGV11UFfYlZgxaxnMMZtre35COi
         hUAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EOkHN4OY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gb16sor21316696plb.4.2019.05.20.19.55.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 19:55:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EOkHN4OY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TZunHuUt7tyDrtFDeA5ZZ4ZwMnBTbuylcZfIETnEBPY=;
        b=EOkHN4OYXvIcl19VnDzQjUPREoQsG7FBD4IBtQZtxzWPHk38JIQSjSWEvQMNxOJ+dp
         0ygx7a3pBalvb/lz54klCwYUBBz7oL514HFPEuZmiyXOowZHoDmICshvgmGDNSJ/+t3M
         tvx6A4ge8kP+b7x+SV623eINdLfOZTTHTkLVv3NTXLPIHjrsKkZoufRQiC6qjodZ4D7l
         rGmiMG5iVRZP4e6noFyPH5Ou6AAb6YjBieeln98a0UTh834R1hHzohKoXbP0RmQ7fDvQ
         yu1HklXowvWr0APRyqramMkyyUKsLteDgM3RTpYFiSlnJ1Lg7L4n2Zf+B77ypVToW8bA
         E7gg==
X-Google-Smtp-Source: APXvYqzexWksuHBaFUEP7NSQz3gDQbJO+ELyIYn0MhPdSdkSdsBy0GUOBt75NltTcpChWbSJjMxU0g==
X-Received: by 2002:a17:902:e40f:: with SMTP id ci15mr81923421plb.280.1558407340615;
        Mon, 20 May 2019 19:55:40 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a69sm49600003pfa.81.2019.05.20.19.55.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 19:55:38 -0700 (PDT)
Date: Tue, 21 May 2019 11:55:33 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190521025533.GH10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520092801.GA6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> [cc linux-api]
> 
> On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > System could have much faster swap device like zRAM. In that case, swapping
> > is extremely cheaper than file-IO on the low-end storage.
> > In this configuration, userspace could handle different strategy for each
> > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > file IO is more expensive in this case so want to keep them in memory
> > until memory pressure happens.
> > 
> > To support such strategy easier, this patch introduces
> > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > that /proc/<pid>/clear_refs already has supported same filters.
> > They are filters could be Ored with other existing hints using top two bits
> > of (int behavior).
> 
> madvise operates on top of ranges and it is quite trivial to do the
> filtering from the userspace so why do we need any additional filtering?
> 
> > Once either of them is set, the hint could affect only the interested vma
> > either anonymous or file-backed.
> > 
> > With that, user could call a process_madvise syscall simply with a entire
> > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> 
> OK, so here is the reason you want that. The immediate question is why
> cannot the monitor do the filtering from the userspace. Slightly more
> work, all right, but less of an API to expose and that itself is a
> strong argument against.

What I should do if we don't have such filter option is to enumerate all of
vma via /proc/<pid>/maps and then parse every ranges and inode from string,
which would be painful for 2000+ vmas.

> 
> > * from v1r2
> >   * use consistent check with clear_refs to identify anon/file vma - surenb
> > 
> > * from v1r1
> >   * use naming "filter" for new madvise option - dancol
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/uapi/asm-generic/mman-common.h |  5 +++++
> >  mm/madvise.c                           | 14 ++++++++++++++
> >  2 files changed, 19 insertions(+)
> > 
> > diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> > index b8e230de84a6..be59a1b90284 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -66,6 +66,11 @@
> >  #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
> >  #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
> >  
> > +#define MADV_BEHAVIOR_MASK (~(MADV_ANONYMOUS_FILTER|MADV_FILE_FILTER))
> > +
> > +#define MADV_ANONYMOUS_FILTER	(1<<31)	/* works for only anonymous vma */
> > +#define MADV_FILE_FILTER	(1<<30)	/* works for only file-backed vma */
> > +
> >  /* compatibility flags */
> >  #define MAP_FILE	0
> >  
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index f4f569dac2bd..116131243540 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -1002,7 +1002,15 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >  	int write;
> >  	size_t len;
> >  	struct blk_plug plug;
> > +	bool anon_only, file_only;
> >  
> > +	anon_only = behavior & MADV_ANONYMOUS_FILTER;
> > +	file_only = behavior & MADV_FILE_FILTER;
> > +
> > +	if (anon_only && file_only)
> > +		return error;
> > +
> > +	behavior = behavior & MADV_BEHAVIOR_MASK;
> >  	if (!madvise_behavior_valid(behavior))
> >  		return error;
> >  
> > @@ -1067,12 +1075,18 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >  		if (end < tmp)
> >  			tmp = end;
> >  
> > +		if (anon_only && vma->vm_file)
> > +			goto next;
> > +		if (file_only && !vma->vm_file)
> > +			goto next;
> > +
> >  		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> >  		error = madvise_vma(tsk, vma, &prev, start, tmp,
> >  					behavior, &pages);
> >  		if (error)
> >  			goto out;
> >  		*nr_pages += pages;
> > +next:
> >  		start = tmp;
> >  		if (prev && start < prev->vm_end)
> >  			start = prev->vm_end;
> > -- 
> > 2.21.0.1020.gf2820cf01a-goog
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

