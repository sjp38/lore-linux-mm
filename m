Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44F95C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:23:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E31C4217D9
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 04:23:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fD3jJ7N6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E31C4217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 841718E0004; Mon, 18 Feb 2019 23:23:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F0048E0002; Mon, 18 Feb 2019 23:23:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705998E0004; Mon, 18 Feb 2019 23:23:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 485CB8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:23:34 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id a1so16200300otl.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 20:23:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=BZ70yCNh5WffCA/KWtAfL1gD23kmQ59Ev3rj/62a6ng=;
        b=UlAykwUbefbwgk6Fw4wmj0Lo+LyIcYk7LX+864ssBmWzMc05c2r8u4iVMp5gdDDlaZ
         6jB9tIjXRstilI37F++x7t8r+gXZ+kobEVV4vlpQLRTEfUp0/gcLcYF/War4UqGlbbOq
         AdaEXJW+96cNjJ4B9wW4BAdnXUCUE1zf2S5Cm6vadhLLcMpvdJQvSxqMh4kHHCk0stUf
         pySte9j+9YbAknmH1hKstoM+4DOPDfUZBC+xfauiCHYee3k3AeEV8jKKGg0c2/wKPD6Z
         624pFLZXMpF2b+JupZV+HT/nnRF+tZK4W7kWoY+ULarwLSMPzPY0F/TcC/K81yFQZxuN
         DAMw==
X-Gm-Message-State: AHQUAua6HRC0N9kIxNPTO9VVVIzURLZUVqxO1hYyeuuVz4S0mJxuZDA2
	gHaa19N5EUyR5YB5NWmxwxchoBw8cRsjypc23YNGqaQApW2ffMmV4hiFYaF/t+peWfijnbqAwZi
	C5QVxJryPfEewQvMErO0PDSFw1LmM3/U577J99dQA8sb8srHuoi0EKI9Znw/qO28oWVHPDt/UtZ
	N2pb9AQ2+0UtN0K1mp4NojP95y0OWSD00yfr0K9a3xNPr7sSFxGV5sIvRjXqUeZPUPvauR3i45l
	SEfnophph04+QoHy/Mzu6L7CwtowbBgqoq6WXfDWeyhw13zdMxJmfNynbbQ5KSfaUg38G/wZhZb
	TnGl5Mui6boGo1deTW14rwYOYN7JjxW6VHKIxtj7+QGnM3OnsEOHo8ir+qBPSmx9Z+JLHe2zr8r
	y
X-Received: by 2002:aca:5652:: with SMTP id k79mr1361922oib.19.1550550213891;
        Mon, 18 Feb 2019 20:23:33 -0800 (PST)
X-Received: by 2002:aca:5652:: with SMTP id k79mr1361885oib.19.1550550212952;
        Mon, 18 Feb 2019 20:23:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550550212; cv=none;
        d=google.com; s=arc-20160816;
        b=Ni4W9rzHxcFZ6rb4HpwEP8fZpmc9D+ynLkwhs71XuE1Ofcg1hFf2lpn126aypMLzbU
         2pGH1AR/7Ea5cbxz91c8AbMfuU6RAVK/zQOM5W/gk7+O7hpUw0zHFbpbYVHNTwArSDcK
         t33Zor/J9n9VTZ1c1AUNajNWVChShg/onHgZWVExGC4fsFdrR61T+rOQrs3YaHuuB2m1
         7aRG4z/FO6btt8lIJngNllQ41tJ2QRf2jNW4WUuMYb2UH1uj7UHRrtSYS4H2CMoPn39t
         Qf79RBLLo0LV8ds4g1QjCnQ0RGrA7kmt9kUYruhkx/d3lqxF2uje0YAMw6HH5M6AvMmc
         wz/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=BZ70yCNh5WffCA/KWtAfL1gD23kmQ59Ev3rj/62a6ng=;
        b=kCpK0L1i6W43FzdfJmdpqgnvd/MB9UhnZNcOnMe4BEuqJZ89lGFPlvSA0gNNc1g59y
         /hh1gd+VwTmLReZ0tOgA28L5yga3jScFnxBFC1gLk/zzqKxROyvEPpOBZvstxvgZUc8p
         kQPJQi4j7eR6PP2hL601YcMQB3ROFp8mo7xrRocUZrBaU57TyNXqPkluxuZgh/Opx2CF
         y/VwHPwBAGFMEGhx6Asqs2fLJtoH9nouvjYz9Y9wRE4NJktBMC/REU8oMLVJCdF4Hqyy
         verk1V7N+37Z4tFZ56mPhH9usJRL+OYuKqvt4xfw3RlF1JM39JL6+6RSD83QUD4pHDHo
         o6/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fD3jJ7N6;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z89sor8054409otb.62.2019.02.18.20.23.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 20:23:32 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fD3jJ7N6;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=BZ70yCNh5WffCA/KWtAfL1gD23kmQ59Ev3rj/62a6ng=;
        b=fD3jJ7N6HihGtcOWC2LovPGVLKbKldQsNTGYb3dSsabghPRkXPZYrw63tsVn0Xk+gd
         bbkZASYGg6P5A4xzLmuT2pUlz0IZ9XfkGK8pZkypA1sVlDzjDqldVOX9a/7xelBdqNR2
         E60uBZwCfJcP8BT+WGBa3AlL6t7RrouHqYGQj0xQtI9LTr15PJ/WIJrk7yumdIXan21C
         9+Gepym8/eINr2+IEYlcqv7U0KLD5xVX0BBVRbAD8cr8CMmJ8bg+2T9qDfxR8/2ZD2B1
         oEPPIQTXYIFqonOABx+rLVDyFVP+JW5XHNWxt/LWEICVqU9aYq1DCSWG/VyqIrDvdu1j
         L4GQ==
X-Google-Smtp-Source: AHgI3IaVd4kKac3ilff9QBN13q+IERycjBZdjfzSsSwOOWnKOYyrmZbzPzQ8Y4Q8MGxQakDToTYpdg==
X-Received: by 2002:a05:6830:13c2:: with SMTP id e2mr3431817otq.345.1550550212205;
        Mon, 18 Feb 2019 20:23:32 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id 30sm7280404ots.52.2019.02.18.20.23.30
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 20:23:31 -0800 (PST)
Date: Mon, 18 Feb 2019 20:23:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: "Darrick J. Wong" <darrick.wong@oracle.com>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Matej Kupljen <matej.kupljen@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: tmpfs inode leakage when opening file with O_TMP_FILE
In-Reply-To: <alpine.LSU.2.11.1902150159100.5680@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1902181945240.1821@eggly.anvils>
References: <CAHMF36F4JN44Y-yMnxw36A8cO0yVUQhAkvJDcj_gbWbsuUAA5A@mail.gmail.com> <20190214154402.5d204ef2aa109502761ab7a0@linux-foundation.org> <20190215002631.GB6474@magnolia> <alpine.LSU.2.11.1902150159100.5680@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019, Hugh Dickins wrote:
> On Thu, 14 Feb 2019, Darrick J. Wong wrote:
> > > On Mon, 11 Feb 2019 15:18:11 +0100 Matej Kupljen <matej.kupljen@gmail.com> wrote:
> > > > 
> > > > it seems that when opening file on file system that is mounted on
> > > > tmpfs with the O_TMPFILE flag and using linkat call after that, it
> > > > uses 2 inodes instead of 1.
...
> > 
> > Heh, tmpfs and its weird behavior where each new link counts as a new
> > inode because "each new link needs a new dentry, pinning lowmem, and
> > tmpfs dentries cannot be pruned until they are unlinked."
> 
> That's very much a peculiarity of tmpfs, so agreed: it's what I expect
> to be the cause, but I've not actually tracked it through and fixed yet.
...
> 
> > I /think/ the proper fix is to change shmem_link to decrement ifree only
> > if the inode has nonzero nlink, e.g.
> > 
> > 	/*
> > 	 * No ordinary (disk based) filesystem counts links as inodes;
> > 	 * but each new link needs a new dentry, pinning lowmem, and
> > 	 * tmpfs dentries cannot be pruned until they are unlinked.  If
> > 	 * we're linking an O_TMPFILE file into the tmpfs we can skip
> > 	 * this because there's still only one link to the inode.
> > 	 */
> > 	if (inode->i_nlink > 0) {
> > 		ret = shmem_reserve_inode(inode->i_sb);
> > 		if (ret)
> > 			goto out;
> > 	}
> > 
> > Says me who was crawling around poking at O_TMPFILE behavior all morning.
> > Not sure if that's right; what happens to the old dentry?

Not sure what you mean by "what happens to the old dentry?"
But certainly the accounting feels a bit like a shell game,
and my attempts to explain it have not satisfied even me.

The way I'm finding it helpful to think, is to imagine tmpfs'
count of inodes actually to be implemented as a count of dentries.
And the 1 for the last remaining goes away in the shmem_free_inode()
at the end of shmem_evict_inode().  Does that answer "what happens"?

Since applying the patch, I have verified (watching "dentry" and
"shmem_inode_cache" in /proc/slabinfo) that doing Matej's sequence
repeatedly does not leak any "df -i" nor dentries nor inodes.

> 
> I'm relieved to see your "/think/" above and "Not sure" there :)
> Me too.  It is so easy to get these counting things wrong, especially
> when distributed between the generic and the specific file system.
> 
> I'm not going to attempt a pronouncement until I've had time to
> sink properly into it at the weekend, when I'll follow your guide
> and work it through - thanks a lot for getting this far, Darrick.

I have now sunk into it, and sure that I agree with your patch,
filled out below (I happen to have changed "inode->i_nlink > 0" to
"inode->i_nlink" just out of some personal preference at the time).
One can argue that it's not technically quite the right place, but
it is the place where we can detect the condition without getting
into unnecessary further complications, and does the job well enough.

May I change "Suggested-by: Darrick J. Wong <darrick.wong@oracle.com>"
to your "Signed-off-by" before sending on to Andrew "From" you?

Thanks!
Hugh

[PATCH] tmpfs: fix link accounting when a tmpfile is linked in

tmpfs has a peculiarity of accounting hard links as if they were separate
inodes: so that when the number of inodes is limited, as it is by default,
a user cannot soak up an unlimited amount of unreclaimable dcache memory
just by repeatedly linking a file.

But when v3.11 added O_TMPFILE, and the ability to use linkat() on the fd,
we missed accommodating this new case in tmpfs: "df -i" shows that an
extra "inode" remains accounted after the file is unlinked and the fd
closed and the actual inode evicted.  If a user repeatedly links tmpfiles
into a tmpfs, the limit will be hit (ENOSPC) even after they are deleted.

Just skip the extra reservation from shmem_link() in this case: there's
a sense in which this first link of a tmpfile is then cheaper than a
hard link of another file, but the accounting works out, and there's
still good limiting, so no need to do anything more complicated.

Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
Suggested-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

--- 5.0-rc7/mm/shmem.c	2019-01-06 19:15:45.764805103 -0800
+++ linux/mm/shmem.c	2019-02-18 13:56:48.388032606 -0800
@@ -2854,10 +2854,14 @@ static int shmem_link(struct dentry *old
 	 * No ordinary (disk based) filesystem counts links as inodes;
 	 * but each new link needs a new dentry, pinning lowmem, and
 	 * tmpfs dentries cannot be pruned until they are unlinked.
+	 * But if an O_TMPFILE file is linked into the tmpfs, the
+	 * first link must skip that, to get the accounting right.
 	 */
-	ret = shmem_reserve_inode(inode->i_sb);
-	if (ret)
-		goto out;
+	if (inode->i_nlink) {
+		ret = shmem_reserve_inode(inode->i_sb);
+		if (ret)
+			goto out;
+	}
 
 	dir->i_size += BOGO_DIRENT_SIZE;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);

