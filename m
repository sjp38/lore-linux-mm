Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39E4AC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 01:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEB9D20844
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 01:44:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEB9D20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79EEC8E0003; Thu, 31 Jan 2019 20:44:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725ED8E0001; Thu, 31 Jan 2019 20:44:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C62B8E0003; Thu, 31 Jan 2019 20:44:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1621A8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 20:44:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so4138418pfb.13
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 17:44:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=How+MWPN7ghiO9CTppj1maBJk4oKZ02E9FoKcyM36vY=;
        b=BAsZc+zjZgdiGFeL2OocbWsKSW60JsT+23PdtC2xWphRreXCGPhv55f+0qtWKYH3iV
         uy4nqco0JbYHZ4Vz9TPCnATQbN9sBBkt8Q2uHy1jl7RGRaU1He0tIUd+4WyxY7SMwXwV
         9hGPuack3XruTZJbPJXZyZB7FumgOeKKFJYO7yH8C09Yp3KsCsiOgteITfmbgP+KEjJY
         c4fAFBzSB09jxJuymERmwCMHfAvq+5FFEkmyQzQk3TlbySLiCuWnD4fl0DefCz2pcsYl
         BVJVuJvzbnunj9Ljv1j95o3DHC6mx3ZMHUvzz9Lm06B8S6zfaLBwkR72zxAYNzgBtIro
         Qsjw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZNTUDG9AW6gU/Wzvy4Zd+wHjkxciE3Xxnn0Tm0Ak7Fp2MElozw
	isplWy9nIjQ1hcdyNaHZeznogi4erN3wnslT9YdowHDE06w9fZO7XVpbimRaqinP/29DvoNJ/uy
	zmGCBlEtt7y77nqA1LuccFAgq+dCiaMG6PNmIt3y6vaBoYc9c9TyMFJ4Nio8fUKM=
X-Received: by 2002:a63:a401:: with SMTP id c1mr267368pgf.403.1548985491667;
        Thu, 31 Jan 2019 17:44:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY44OZWjDZrJZDlWk3y9e7zjbGRmI59Qo7irwtjrzjYdlrYn74mdgV3M5UJVyiN1C2Yafdv
X-Received: by 2002:a63:a401:: with SMTP id c1mr267325pgf.403.1548985490730;
        Thu, 31 Jan 2019 17:44:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548985490; cv=none;
        d=google.com; s=arc-20160816;
        b=YLVNcWPQiPTY/gqo4yyXi0j2MWAy1IGQZOYFK8/owfQcvsrnmiubtE2wuO+f3e1oiI
         zzIL+IKXUKI6lRq5oxtOfawMhDcxhFqOoXspiDL5Zsk2EAtREl6LkhtNhhcJgA4mpHLb
         o+ksSLzzeiz/wK7opWUWVDoRlXgEs9PaLROXMvAY3TH1Mi4gBAu5LUNmcIduckGnIZPq
         9McOsy9yO1o88dm9akkayE6O7G3vnchKgP/S88+fYXVhoHmXoECk3+s39VGeHtfid7E+
         btrAi+6iRthzDMAoWNGZD6hJ+wEGAfmdH7uLD2g7dbUnqbstcpYrLL7H9ggGYsY+nHpM
         TApA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=How+MWPN7ghiO9CTppj1maBJk4oKZ02E9FoKcyM36vY=;
        b=tNQv58kZmdYreNlsIM6sReaXSGmm7BAeNPzksOjLgGAg/tlkoLej6o8DW4kxDy/ymR
         zmDVZg13zeaKzw9sLmgJXAxbRVRppeMGX4i8OXt+oIFJTJORZrHAGN6JqGChKMFV/uZI
         LzPS16bwCJR0NP/uIBSrXsMDbzYiy8a2Ovia80As9Z0vWqUXk0fa1VcqXTDiqsJlhkZr
         IZiiiJBHBGKG5grtNWLsJvNEo6aW/TkRc3uTUwzB7vsrJ7TwA9SyESOl+Uy/2c08CT+7
         eS5bRQ1X4bBRg6c/bm1N3655QcpfNygw+dHkRoSOf8rKT1hVgDhvoTrKDdlVp2BoyTBz
         rv2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id i5si6097284pgn.243.2019.01.31.17.44.49
        for <linux-mm@kvack.org>;
        Thu, 31 Jan 2019 17:44:50 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 01 Feb 2019 12:14:48 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gpNss-0003Sc-JE; Fri, 01 Feb 2019 12:44:46 +1100
Date: Fri, 1 Feb 2019 12:44:46 +1100
From: Dave Chinner <david@fromorbit.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
Message-ID: <20190201014446.GU6173@dastard>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131095644.GR18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 10:56:44AM +0100, Michal Hocko wrote:
> [Cc fs-devel]
> 
> On Wed 30-01-19 13:44:19, Vlastimil Babka wrote:
> > From: Jiri Kosina <jkosina@suse.cz>
> > 
> > preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache contents, as
> > it reveals metadata about residency of pages in pagecache.
> > 
> > If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page not
> > resident" information, and vice versa.
> > 
> > Close that sidechannel by always initiating readahead on the cache if we
> > encounter a cache miss for preadv2(RWF_NOWAIT); with that in place, probing
> > the pagecache residency itself will actually populate the cache, making the
> > sidechannel useless.
> 
> I guess the current wording doesn't disallow background IO to be
> triggered for EAGAIN case. I am not sure whether that breaks clever
> applications which try to perform larger IO for those cases though.

Actually, it does:

RWF_NOWAIT (since Linux 4.14)

    Do  not  wait for data which is not immediately available.  If
    this flag is specified, the preadv2() system call will return
    instantly if it would have to read data from the backing storage
    or wait for a lock.

page_cache_sync_readahead() can block on page allocation, it calls
->readpages() which means there are page locks and filesystem locks
in play (e.g.  for block mapping), there's potential for blocking on
metadata IO (both submission and completion) to read block maps, the
data readahead can be submitted for IO so it can get stuck anywhere
in the IO path, etc...

Basically, it completely subverts the documented behaviour of
RWF_NOWAIT.

There are applications (like Samba (*)) that are planning to use
this to avoid blocking their main processing threads on buffered
IO. This change makes RWF_NOWAIT pretty much useless to them - it
/was/ the only solution we had for reliably issuing non-blocking IO,
with this patch it isn't a viable solution at all.

(*) https://github.com/samba-team/samba/commit/6381044c0270a647c20935d22fd23f235d19b328

IOWs, if this change goes through, it needs to be documented as an
intentional behavioural bug in the preadv2 manpage so that userspace
developers are aware of the new limitations of RWF_NOWAIT and should
avoid it like the plague.

But worse than that is nobody has bothered to (or ask someone
familiar with the code to) do an audit of RWF_NOWAIT usage after I
pointed out the behavioural issues. The one person who was engaged
and /had done an audit/ got shouted down with so much bullshit they
just walked away....

So, I'll invite the incoherent, incandescent O_DIRECT rage flames of
Linus to be unleashed again and point out the /other reference/ to
IOCB_NOWAIT in mm/filemap.c. That is, in generic_file_read_iter(),
in the *generic O_DIRECT read path*:

	if (iocb->ki_flags & IOCB_DIRECT) {
.....
		if (iocb->ki_flags & IOCB_NOWAIT) {
			if (filemap_range_has_page(mapping, iocb->ki_pos,
						   iocb->ki_pos + count - 1))
				return -EAGAIN;
		} else {
.....

This page cache probe is about 100 lines of code down from the code
that this patch modifies, in it's direct caller. It's not hard to
find, I shouldn't have to point it out, nor have to explain how it
makes this patch completely irrelevant.

> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 9f5e323e883e..7bcdd36e629d 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> >  
> >  		page = find_get_page(mapping, index);
> >  		if (!page) {
> > -			if (iocb->ki_flags & IOCB_NOWAIT)
> > -				goto would_block;
> >  			page_cache_sync_readahead(mapping,
> >  					ra, filp,
> >  					index, last_index - index);
> 
> Maybe a stupid question but I am not really familiar with this path but
> what exactly does prevent a sync read down page_cache_sync_readahead
> path?

It's effectively useless as a workaround because you can avoid the
readahead IO being issued relatively easily:

void page_cache_sync_readahead(struct address_space *mapping,
                               struct file_ra_state *ra, struct file *filp,
                               pgoff_t offset, unsigned long req_size)
{
        /* no read-ahead */
        if (!ra->ra_pages)
                return;

        if (blk_cgroup_congested())
                return;
....

IOWs, we just have to issue enough IO to congest the block device (or,
even easier, a rate-limited cgroup), and we can still use RWF_NOWAIT
to probe the page cache. Or if we can convince ra->ra_pages to be
zero (e.g. it's on bdi device with no readahead configured because
it's real fast) then it doesn't work there, either.

So this a) isn't a robust workaround, b) it breaks documented API
semantics and c) isn't the only path to page cache probing via
RWF_NOWAIT. It's just a new game of whack-a-mole.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

