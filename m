Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23DC3C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D288820684
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="QHJOC2ZZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D288820684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D2B46B0279; Thu,  6 Jun 2019 11:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682326B027A; Thu,  6 Jun 2019 11:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54A126B027D; Thu,  6 Jun 2019 11:35:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28D4D6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:35:57 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id u8so745246oie.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:35:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1uRCmoXjULyV6kNTp2XKoB1qQmxkPSNDXYL9A3FHXFA=;
        b=qEQjKMJRmrcWcm1OilpotBqbPHJTzpIOXlB9SD03f0Pgk6SvmdVDdyZcBF9FguPdNn
         loEYebRpAiwQxgGCUS02EH5GwHAiIX/+i1axVwrrY1B84wuQ9773TBM619wForQFQ7BZ
         Sx7KgqUWbw3IQKqtMEn7SYX7L4w7SxGkctMwJsw0qPypZTFBCKfmSkpGtOS/AIZsuRn/
         NR/s4duQ/WQGiiXtZhrRkCGkCYiIKGhzXfrHhcgKuKpUzye5VU5W7l1DpDnsbzz9X7VD
         /cF2N/H2nn47ppQkaipt/zfMKLQ2dAjRtQTWyGszc9lPsRFaD9bittEOAu1Wvm0IpEUy
         CQeQ==
X-Gm-Message-State: APjAAAWTE6DT1A9twOeecnbhEZbN/bcAGsIvhB9yeRYLb7wY4mKxJs5/
	t+y1tT6FHEyqCygKbeIv1JbBRRsOy5BT+mzHK4zt23uPgTtZ6WGx7UxYaoqtgOiwG3I0ytDbXLI
	aTCQ/97IsuSvkEK0f7JhiXAIX1rpegdnTEGfjZJmruFS+D/F4GQ6HJaa7TB3w6ONHTw==
X-Received: by 2002:aca:4404:: with SMTP id r4mr448460oia.130.1559835356718;
        Thu, 06 Jun 2019 08:35:56 -0700 (PDT)
X-Received: by 2002:aca:4404:: with SMTP id r4mr448397oia.130.1559835355644;
        Thu, 06 Jun 2019 08:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559835355; cv=none;
        d=google.com; s=arc-20160816;
        b=SQ8+lQa6oOuvJqvSBz1aOFNema7pYYYp28WK729EWMVI4rDWXpPrzGI36tdNX9zmq+
         Tj1j3hXt/Elu7ivIM29/6qwUMdIbFbB8M5mzft/nv+cfnT0yb/RcZZ3orodS1cyKgwaW
         fG1oaT01QDRy2qcUsCyoE1xMarpI9HVsGOAyGmSdxqyFUKX/yMob3q06x3jCiuTGGUyA
         MN/5ZvDXN9Dl9x2MFMGd1d89kh50hYBf9TtfKI19HTIiVyv/iU69vswau23tDiuU9Baa
         iyvx1pRFgoaxP42yV7wRfaFHvOc+IGTXVQwGx2FwJoTyfZDF9d0Er+IiTZM6c8SPyPuO
         lK0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1uRCmoXjULyV6kNTp2XKoB1qQmxkPSNDXYL9A3FHXFA=;
        b=cQZ7NcqW/0IaWZM/Lw5NMu/0EjZdxiA273iMj/aGVgXYpIvY4lSz/En1rSeE/dYbUw
         HcPCKaUnwXqD0IHZPqCkTyKdimRLzfjTuaX210G8uIhzWogVL7w75ByREdF2gPAudG9I
         PzUaEQeLHb5of6R7F/ASJOG7tB9J017ayDZXgoc+AdO4E7xhpR0x2wlas5AdbYxqu7A6
         /8P0+LxMOGID9gvgpPnFO/M+v5dlJii3mt+7XNgNTNf0ykjVoEBgRxQaqLPPst0H4iBb
         BjtKkhiYbqzFEbwWjAKIKQz6BW8X+tIlQS+Oxcvz+CQ7R7Agw/NZD4WVImQYtA24ceKk
         QDSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=QHJOC2ZZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor814455oic.139.2019.06.06.08.35.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:35:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=QHJOC2ZZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1uRCmoXjULyV6kNTp2XKoB1qQmxkPSNDXYL9A3FHXFA=;
        b=QHJOC2ZZhCoDsF3kkt0jD8pflX+D1g9wOGO30jisMp6VkS20cZbHhajfwYZJVXdiNh
         JvAq7go3CRc5C+qomPxstLKznxkYPvd1O8ef7VHSAdG1rMnaPbbiOm9MuPNkCt7QxXaR
         tW2MckCN4CHKIL8N13EVae4FrQAMJth8VAaKv/3gRwubZltnT7kNI3PWIXvq1c0vgZdi
         L4XQGyBb2kkKpfIMhfb2YWP8o3M95HB+am83dkZODoLq1I1UWGrX6Sp8tjJSrVa2UG3+
         kN4AXQu3lycB826+fr4/pUl5FixrZTURACJPQlnP2NuCi+p38m+p145UkX/P89XlKLdK
         QHrQ==
X-Google-Smtp-Source: APXvYqwQgzrGrWeJ2qr6zRt1Kh72wsL96qCKSVk7C2TBZflDvhLK6wlI/C4trmZ0QEDDo8Q9KA4CrwRdXYqf7oGmgHc=
X-Received: by 2002:aca:bbc5:: with SMTP id l188mr410988oif.73.1559835355090;
 Thu, 06 Jun 2019 08:35:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190606014544.8339-1-ira.weiny@intel.com> <20190606104203.GF7433@quack2.suse.cz>
In-Reply-To: <20190606104203.GF7433@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 6 Jun 2019 08:35:42 -0700
Message-ID: <CAPcyv4h-k_5T39fDY+SVrLXG_XETmgz-6N3NjQUteYG7g9NdDQ@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Jan Kara <jack@suse.cz>
Cc: "Weiny, Ira" <ira.weiny@intel.com>, "Theodore Ts'o" <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>, 
	Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, 
	linux-xfs <linux-xfs@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	John Hubbard <jhubbard@nvidia.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 3:42 AM Jan Kara <jack@suse.cz> wrote:
>
> On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > ... V1,000,000   ;-)
> >
> > Pre-requisites:
> >       John Hubbard's put_user_pages() patch series.[1]
> >       Jan Kara's ext4_break_layouts() fixes[2]
> >
> > Based on the feedback from LSFmm and the LWN article which resulted.  I've
> > decided to take a slightly different tack on this problem.
> >
> > The real issue is that there is no use case for a user to have RDMA pinn'ed
> > memory which is then truncated.  So really any solution we present which:
> >
> > A) Prevents file system corruption or data leaks
> > ...and...
> > B) Informs the user that they did something wrong
> >
> > Should be an acceptable solution.
> >
> > Because this is slightly new behavior.  And because this is gonig to be
> > specific to DAX (because of the lack of a page cache) we have made the user
> > "opt in" to this behavior.
> >
> > The following patches implement the following solution.
> >
> > 1) The user has to opt in to allowing GUP pins on a file with a layout lease
> >    (now made visible).
> > 2) GUP will fail (EPERM) if a layout lease is not taken
> > 3) Any truncate or hole punch operation on a GUP'ed DAX page will fail.
> > 4) The user has the option of holding the layout lease to receive a SIGIO for
> >    notification to the original thread that another thread has tried to delete
> >    their data.  Furthermore this indicates that if the user needs to GUP the
> >    file again they will need to retake the Layout lease before doing so.
> >
> >
> > NOTE: If the user releases the layout lease or if it has been broken by
> > another operation further GUP operations on the file will fail without
> > re-taking the lease.  This means that if a user would like to register
> > pieces of a file and continue to register other pieces later they would
> > be advised to keep the layout lease, get a SIGIO notification, and retake
> > the lease.
> >
> > NOTE2: Truncation of pages which are not actively pinned will succeed.
> > Similar to accessing an mmap to this area GUP pins of that memory may
> > fail.
>
> So after some through I'm willing accept the fact that pinned DAX pages
> will just make truncate / hole punch fail and shove it into a same bucket
> of situations like "user can open a file and unlink won't delete it" or
> "ETXTBUSY when user is executing a file being truncated".  The problem I
> have with this proposal is a lack of visibility from sysadmin POV. For
> ETXTBUSY or "unlinked but open file" sysadmin can just do lsof, find the
> problematic process and kill it. There's nothing like that with your
> proposal since currently once you hold page reference, you can unmap the
> file, drop layout lease, close the file, and there's no trace that you're
> responsible for the pinned page anymore.
>
> So I'd like to actually mandate that you *must* hold the file lease until
> you unpin all pages in the given range (not just that you have an option to
> hold a lease). And I believe the kernel should actually enforce this. That
> way we maintain a sane state that if someone uses a physical location of
> logical file offset on disk, he has a layout lease. Also once this is done,
> sysadmin has a reasonably easy way to discover run-away RDMA application
> and kill it if he wishes so.

Yes, this satisfies the primary concern that made me oppose failing
truncate. If the administrator determines that reclaiming capacity is
more important than maintaining active RDMA mappings "lsof + kill" is
a reasonable way to recover. I'd go so far as to say that anything
less is an abdication of the kernel's responsibility as an arbiter of
platform resources.

> The question is on how to exactly enforce that lease is taken until all
> pages are unpinned. I belive it could be done by tracking number of
> long-term pinned pages within a lease. Gup_longterm could easily increment
> the count when verifying the lease exists, gup_longterm users will somehow
> need to propagate corresponding 'filp' (struct file pointer) to
> put_user_pages_longterm() callsites so that they can look up appropriate
> lease to drop reference - probably I'd just transition all gup_longterm()
> users to a saner API similar to the one we have in mm/frame_vector.c where
> we don't hand out page pointers but an encapsulating structure that does
> all the necessary tracking. Removing a lease would need to block until all
> pins are released - this is probably the most hairy part since we need to
> handle a case if application just closes the file descriptor which would
> release the lease but OTOH we need to make sure task exit does not deadlock.
> Maybe we could block only on explicit lease unlock and just drop the layout
> lease on file close and if there are still pinned pages, send SIGKILL to an
> application as a reminder it did something stupid...
>
> What do people think about this?

SIGKILL on close() without explicit unlock and wait-on-last-pin with
explicit unlock sounds reasonable to me.

