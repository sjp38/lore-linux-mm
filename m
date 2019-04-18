Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C952AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DB7121871
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:34:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DB7121871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BCAA6B0005; Thu, 18 Apr 2019 09:34:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C256B0006; Thu, 18 Apr 2019 09:34:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4F456B0007; Thu, 18 Apr 2019 09:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA4876B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:34:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w9so1507462plz.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:34:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iRg0UlGOBeCVU2joKmRIJiqs+1V+/iQXunVn4f9p/yY=;
        b=JF6sfKBjVfY7LeqxI8wRjaBuRvDQOmrQ2CprR/ap0foGIw4TmwKAyVGjJIsCJQ9iw3
         dCrdXRKF7gSwi6wIkMySl3rkweJ3kmgHMfnNsOlQuhec2GOJMz+SVw+MMAqjRI4qNpLi
         UnKPA5lgsK3LgqIgsCnz/YFADW/zWlEbgOYi2wOP4L9rEeRSLeAO/Zib2X1//pdmPTxW
         u+3CvyKYxgBn3xuF7is45xUaABLK95RGq1YdSMYsMOEdHFIYzqGELpqrwmz6GQnuJJWb
         vOhkOGT8L+mEl1ZptVjxUtWgWETlZlIQ/3xy80kbOXiCXgxvSBJF7xR0GcwXqnxgtEkj
         tpwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAW52Mqa8+4VH5pAXPcyobz0c0P/9LxIHLCDJT4JXpE2qHIHhd8k
	ixmvYC9QCQaVYTCT/TGHJ/B3jgwNy8DNxeJBYNc3+tvYIryLUVvuYEXt9nl+dVjz8FtLlAw9ORz
	0vsEdfUe25mmkbL+DifcIuUKhxW6oJ322MhRXUaGofRPZSXySvLEIreI27M8KpAc=
X-Received: by 2002:a62:e710:: with SMTP id s16mr87727851pfh.74.1555594442347;
        Thu, 18 Apr 2019 06:34:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPv31R4b9qfU579q+i5k8vH0/SL0rMHkVAOCeReBbqBDNEwWSQiRgEJUKAJuVchTOTaO2Q
X-Received: by 2002:a62:e710:: with SMTP id s16mr87727771pfh.74.1555594441436;
        Thu, 18 Apr 2019 06:34:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555594441; cv=none;
        d=google.com; s=arc-20160816;
        b=WySq0Tgr9sBAi+RqZRW8DoByGR17mFksr0KTfAvvlpfLxgQNggVdQZQa929eYrhPfe
         5Bh2o3j2Rnnz37eKhLm3Q/fqreCBqYvTZSZPCHprkBt2xvG1OERG6aHACfdNRJ6MJZUa
         zS+MKtKyd0/2wk3ik1s9+FJ9W79y1dQ62zWTkGDIf9nVmZ6n+sliQIQn3mUg9+ZOXTx5
         7/i+nLWVmFYdhhbUHZ+lci+knGsAZwfkZRRTbYo28nQsl3sEQtcLs9BD8QcC6lAShZjN
         bwBuZS29hfqEz5YrQ7PaX9j9dTBo7SHPSWOSy06CN9E4jS//VTVPyrtiH9InZH51EzHh
         yHoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=iRg0UlGOBeCVU2joKmRIJiqs+1V+/iQXunVn4f9p/yY=;
        b=WSbQjJ5q9ttVWMVIa64oczFifXciIzMRfHbly3/IoleiMw5fiVQuF1e2gQpdGh2t4P
         2t+KYFRALdEhgyx3wo969xb4on17l+LIoWFWHXCgWQYBYMs74hGyO08q9bSemmE6H3mN
         Au6mtE9hyAAsM6RLTSfjvEF8BekrWo765n8V7R/ng0ctb9TUMSzr/N3RNafKl7kSO6t2
         bBiiDHKGJD+mZihT1/zGqCSkNY/nJZ/BApahM7LErS+k8OxmqXYG/zfK7AEShcz3F40P
         4XIVODX/+hEx7Ntf/mIdpzsoSCc5vJGXWS4C7LhYNeZYiQHXna23q+t/X14euhpAGXWn
         RbkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h18si1992064pgj.47.2019.04.18.06.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:34:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 00B2D20652;
	Thu, 18 Apr 2019 13:33:57 +0000 (UTC)
Date: Thu, 18 Apr 2019 09:33:56 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Alexander Potapenko <glider@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML
 <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
 x86@kernel.org, Andy Lutomirski <luto@kernel.org>, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, Alexey
 Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
 Pekka Enberg <penberg@kernel.org>, Linux Memory Management List
 <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Christoph
 Lameter <cl@linux.com>, Catalin Marinas <catalin.marinas@arm.com>, Dmitry
 Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 kasan-dev <kasan-dev@googlegroups.com>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 14/29] dm bufio: Simplify stack trace retrieval
Message-ID: <20190418093356.5d4b7732@gandalf.local.home>
In-Reply-To: <CAG_fn=WL0yLqavV_mhodT=B6KcAzJ+LS0hss1jqany9Cn92RHw@mail.gmail.com>
References: <20190418084119.056416939@linutronix.de>
	<20190418084254.361284697@linutronix.de>
	<CAG_fn=WP9+bVv9hedoaTzWK+xBzedxaGJGVOPnF0o115s-oWvg@mail.gmail.com>
	<alpine.DEB.2.21.1904181353420.3174@nanos.tec.linutronix.de>
	<CAG_fn=WL0yLqavV_mhodT=B6KcAzJ+LS0hss1jqany9Cn92RHw@mail.gmail.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 14:11:44 +0200
Alexander Potapenko <glider@google.com> wrote:

> On Thu, Apr 18, 2019 at 1:54 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > On Thu, 18 Apr 2019, Alexander Potapenko wrote:  
> > > On Thu, Apr 18, 2019 at 11:06 AM Thomas Gleixner <tglx@linutronix.de> wrote:  
> > > > -       save_stack_trace(&b->stack_trace);
> > > > +       b->stack_len = stack_trace_save(b->stack_entries, MAX_STACK, 2);  
> > > As noted in one of similar patches before, can we have an inline
> > > comment to indicate what does this "2" stand for?  
> >
> > Come on. We have gazillion of functions which take numerical constant
> > arguments. Should we add comments to all of them?  
> Ok, sorry. I might not be familiar enough with the kernel style guide.

It is a legitimate complaint but not for this series. I only complain
about hard coded constants when they are added. That "2" was not
added by this series. This patch set is a clean up of the stack tracing
code, not a clean up of removing hard coded constants, or commenting
them.

The hard coded "2" was there without a comment before this patch series
and Thomas is correct to leave it as is for these changes. This patch
series should not modify what was already there which is out of scope
for the purpose of these changes.

A separate clean up patch to the maintainer of the subsystem (dm bufio
in this case) is fine. But it's not Thomas's responsibility.

-- Steve

