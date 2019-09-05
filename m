Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F26E3C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3E30206DF
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:06:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="d4fpCjgq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3E30206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F01A6B0003; Thu,  5 Sep 2019 17:06:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 479006B0005; Thu,  5 Sep 2019 17:06:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F1EB6B0007; Thu,  5 Sep 2019 17:06:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id 0639F6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:06:25 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8915255FAE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:06:25 +0000 (UTC)
X-FDA: 75902100330.30.rub50_551a6e9cd5d2e
X-HE-Tag: rub50_551a6e9cd5d2e
X-Filterd-Recvd-Size: 4740
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com [209.85.208.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:06:24 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id a22so3992218ljd.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:06:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dJ1viyEd746u1MzO5bkdAZU+71ZT2HJWhvIS6MWOLz4=;
        b=d4fpCjgqvFKqBijwNopM5Tjl0Abua4COwRNrVEApjvF/wjmS5dLW3m+kZhLhJeWnNu
         iSfejJzg0trBi/IHb6f2jl/1tb3uJHRcCRTEU7aIX6HTXwYewwZvmYkWtTpA7+5upHD6
         uWJrxHL1ER3GQibDLiYN4aNmhG5i7+LEzMMxY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=dJ1viyEd746u1MzO5bkdAZU+71ZT2HJWhvIS6MWOLz4=;
        b=dXOaofluBfd+CNRI9F3Xmd0EFe8C8lFIqGANVHdf5viLa8jvcu/jI65eWOpv0e+Hmp
         CSCimvlofie0LZ6zXDRxGLCzZbXETTucyFjDMIQWt1rowRqhTW00T5rs8j+TEvvqMJEx
         EpTU2zNxfEo+rYtq9LjIe6FsdQAbE1xLm44c3HoLEfhRXcYPrvS5cuRv9dfpLO9wXbFT
         dMBccHC5Yj/Rjo/DUlZsyogViZheFbPYJtvnxTpcM6ZjbXc+fdk7kwMDMMCbFd8nyvMF
         Ce0IsgTSumW4Uk8DBgWO2Cy1t0n41UzG9twDPYnoJjU9W2AodMZWH9SmuUYygXQWQjEJ
         JVxA==
X-Gm-Message-State: APjAAAVNjY6peOn10Dn+2S6ZeFPh9SOXYNoTQPNcyKskAW6m0pry2NZe
	nYOitCAhDbHacrL4/E/StisizL9BFt8=
X-Google-Smtp-Source: APXvYqwIXcqCT71Uu6/nDNZgOvSQMgEjGlStgsNT/8RvpgzdMUaU768tp4mH+7EWrK8jmA/XaTqwOA==
X-Received: by 2002:a05:651c:1ba:: with SMTP id c26mr3456584ljn.154.1567717582298;
        Thu, 05 Sep 2019 14:06:22 -0700 (PDT)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id t82sm652529lff.58.2019.09.05.14.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Sep 2019 14:06:21 -0700 (PDT)
Received: by mail-lj1-f169.google.com with SMTP id d5so3942196lja.10
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:06:20 -0700 (PDT)
X-Received: by 2002:a2e:814d:: with SMTP id t13mr3621962ljg.72.1567717580519;
 Thu, 05 Sep 2019 14:06:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190905101534.9637-1-peterx@redhat.com>
In-Reply-To: <20190905101534.9637-1-peterx@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Sep 2019 14:06:04 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgSwiRsT4=q71jnF_5JrUn5qg76VBw+oMJ-e7SQ17Q1QA@mail.gmail.com>
Message-ID: <CAHk-=wgSwiRsT4=q71jnF_5JrUn5qg76VBw+oMJ-e7SQ17Q1QA@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] mm: Page fault enhancements
To: Peter Xu <peterx@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, 
	Pavel Emelyanov <xemul@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Martin Cracauer <cracauer@cons.org>, Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Denis Plotnikov <dplotnikov@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 3:15 AM Peter Xu <peterx@redhat.com> wrote:
>
> This series is split out of userfaultfd-wp series to only cover the
> general page fault changes, since it seems to make sense itself.

The series continues to look sane to me, but I'd like VM people to
take a look. I see a few reviewed-by's, it would be nice to see more
comments from people. I'd like to see Andrea in particular say "yeah,
this looks all good to me".

Also a question on how this will get to me - it smells like Andrew's
-mm tree to me, both from a VM and a userfaultfd angle (and looking
around, at least a couple of previous patches by Peter have gone that
way).

And it would be lovely to have actual _numbers_ for the alleged
latency improvements. I 100% believe them, but still, numbers rule.

Talking about latency, what about that retry loop in gup()? That's the
one I'm not at all convinced about. It doesn't check for signals, so
if there is some retry logic, it loops forever. Hmm?

             Linus

