Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72992C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ED7D21903
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:23:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TUZD2SJn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ED7D21903
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C27C58E0003; Tue, 19 Feb 2019 02:23:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFDDA8E0002; Tue, 19 Feb 2019 02:23:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC69B8E0003; Tue, 19 Feb 2019 02:23:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7FAC18E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:23:25 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 42so7734068otv.5
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:23:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=IB+siECYR5IIMpiyXWF2nXOjV0iGgr1gIiWvp15AgwU=;
        b=c7Qx6CnKe7MqrFA4iZ4ojy15M6AoZpa1bsCSnWFomxkQNSlLCQR9thdjqMwtaVHupb
         u18I90EArCsNP0U7TpffAk9vapccVhJ/NwYM1ee5iQIb0Ua1Ih7d44ujRtcxUgk9T87V
         pbWalOkH1cFkiq42zylV4BRE2uR2jsF36pSWkahdD1jp3Mu1Sgvzy7m24mzjVwzroOEc
         7PmPIM5RxSh+1tXE5klqNX694z9ENbWDFELsoMNjJtTre9l5Y4VzEsajPFFWFy3wIQ52
         G0+z+e+eODoNKypqFgIhV61I+oyV48/acC1hN9N/uMkhG5EYYR2AYfux3fnRpCP4CzpJ
         refA==
X-Gm-Message-State: AHQUAuaiLGHdGH/PiMt61iAPXRkRKcRCv6a36S6A+mcGZNXD6eX8Fdk3
	pH+25WM3TiyLDh75Qi8UJNGK+CK891gmXZ3dQOxqKglGmC4Mpc8Icec8MzfzyDLsMGGZvcMw+/p
	tCnNLqIrDODj4zolxK4pyJDBAc29RDFJDo3cUXRZG4w6KQ3Fbx68FRbEpGGQHOJ5mlbuiX9Sp/6
	LfnURfCFH0XUf1STJ1MAgjgGqppu5vLJhelD0/hFWBlZ6hw0GY5SUHLwdD/sSMq31jYf0JFWYxw
	fiBpI7mZXESkecKgMF1VefEIMa4ADV0lknSvcwuz7htifpo4wcpWWsPwIjcuroa55U9RkRBp/Ce
	xSFqBjnMAtx00yYnW+GPiXkUKI5HASmVNwLE33cbRKcwCI90aNNTrakxyTTrOQ9zyT9crtW93ul
	M
X-Received: by 2002:a05:6830:1d8:: with SMTP id r24mr86507ota.264.1550561005248;
        Mon, 18 Feb 2019 23:23:25 -0800 (PST)
X-Received: by 2002:a05:6830:1d8:: with SMTP id r24mr86486ota.264.1550561004589;
        Mon, 18 Feb 2019 23:23:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550561004; cv=none;
        d=google.com; s=arc-20160816;
        b=geM3Rd8mv2H/QAPW2FotY01OnEqKmYXHXxJyDkhHzkY4fAYjGnV68YMEqGgFy3xhH1
         +r9gzYEsA4FSZDYTT8JIb6r4d+Vx+UYmkSwXuZJ8GZgqVr9GH0BD8ELpWAjlyXgZKEMB
         VpayOGcQtc3RZ8NyPTJ57u42D+NeHRIWPxnZ78IFENJOqKDD3IYqDibEQ36kuvMbVyOX
         bliH3jSpXjLJrAE61iBJ24qu5916f6NLKfvc9S0FMseo9RrhITd8KqA/5sjBLMlm/wdv
         O+4v0Lj2xeEyGfg8NYpQ1N+iNX0Ohzoo0dtnX0fdzsHAjjI8/fIgRjmgIRsLW8xsZU/h
         biaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=IB+siECYR5IIMpiyXWF2nXOjV0iGgr1gIiWvp15AgwU=;
        b=liHb3y0vei/U5MySPMq07JSOtVYnNYjaAgE8fIf9oR2RqPHizK0p1gfd2VowVrGPIW
         bQFQfhP++Y9AO7nNgOyrVAqbB+MMA90o3T55HhveiOQBX6x+37k1B9Z2NMAVXk1EDWpy
         +yXK6UhQSW8saNtCQcX8DXur0MmEeTzD4Ubpvbkr79i5+ogIei3ZYwPjMxUxgwxrmQEw
         xwO1oSPSA5easS+eiLUoMkZuzWAHkwO/qoU3Ea/LyDfosqGHc0CLehkHsooETKzomtU2
         TkUw8pXX9vv2bzvm/IgvImpJGyqKsK/Sbz5cB7mAo0XfpwWFVjdSEiAaGXR9OXgGoDEA
         OIFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TUZD2SJn;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u16sor8122759oiv.13.2019.02.18.23.23.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 23:23:24 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TUZD2SJn;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=IB+siECYR5IIMpiyXWF2nXOjV0iGgr1gIiWvp15AgwU=;
        b=TUZD2SJnIeXFVhzdcKWhm4U//GslWQDFT0ndoaKYqvy5Pp5fla6hp2/GZSts3pCYB/
         gv6n9j8oKv43JVGhYBoq2RtsXVv91eQg8mVjyD5SkCFZ9jjGEpA9i1cf6HWFRU/ptuTo
         WhVW5skwf6mLtZHh0JuKhqYL8XSM+efSAuR5UR5cWOfdHwnzvrZVsxS5DjZHg7Z5hWch
         Cx3QXUjv3QUFpzn3aFg1CTfQVezmMg99pfOi3ZkUQRwfkDJDWJjmsUGgn3dNICyvlBvD
         iRCs3qHQoqB7A3DfhdAujU3qkn/L+8/3zJPqt0ghKAu8zbYQfDI7whDmqadkwjolPs9/
         OFNQ==
X-Google-Smtp-Source: AHgI3IbSlYnqTF2XEQcKXpeVYysnSj6+N68KP6i2pmo9Ku7KV6WqCJzRA1Th7km08dOF3N7fwmjtUQ==
X-Received: by 2002:aca:aa55:: with SMTP id t82mr1707844oie.29.1550561003715;
        Mon, 18 Feb 2019 23:23:23 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id u65sm7128614oib.5.2019.02.18.23.23.22
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 23:23:22 -0800 (PST)
Date: Mon, 18 Feb 2019 23:23:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Al Viro <viro@zeniv.linux.org.uk>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Matej Kupljen <matej.kupljen@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] tmpfs: fix link accounting when a tmpfile is linked in
In-Reply-To: <20190219054807.GX2217@ZenIV.linux.org.uk>
Message-ID: <alpine.LSU.2.11.1902182311410.7559@eggly.anvils>
References: <alpine.LSU.2.11.1902182134370.7035@eggly.anvils> <20190219054807.GX2217@ZenIV.linux.org.uk>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2019, Al Viro wrote:
> On Mon, Feb 18, 2019 at 09:37:52PM -0800, Hugh Dickins wrote:
> > From: "Darrick J. Wong" <darrick.wong@oracle.com>
> > 
> > tmpfs has a peculiarity of accounting hard links as if they were separate
> > inodes: so that when the number of inodes is limited, as it is by default,
> > a user cannot soak up an unlimited amount of unreclaimable dcache memory
> > just by repeatedly linking a file.
> > 
> > But when v3.11 added O_TMPFILE, and the ability to use linkat() on the fd,
> > we missed accommodating this new case in tmpfs: "df -i" shows that an
> > extra "inode" remains accounted after the file is unlinked and the fd
> > closed and the actual inode evicted.  If a user repeatedly links tmpfiles
> > into a tmpfs, the limit will be hit (ENOSPC) even after they are deleted.
> > 
> > Just skip the extra reservation from shmem_link() in this case: there's
> > a sense in which this first link of a tmpfile is then cheaper than a
> > hard link of another file, but the accounting works out, and there's
> > still good limiting, so no need to do anything more complicated.
> > 
> > Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
> > Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> FWIW, Acked-by: Al Viro <viro@zeniv.linux.org.uk>

It's Worth A Lot, thanks Al. And I apologize for the cheeky "Fixes"
line, when a fair view would blame me for earlier adding the
weirdness fixed.

> 
> Or I can drop it into vfs.git - up to you.

Andrew usually gathers the mm/shmem.c mods (unless it's you doing an
fs-wide sweep), so I was pointing it towards him; and I don't think it's
in dire need of a last minute rush to 5.0, though no harm in there either.
I'll say leave it to Andrew - and leave it to him to say the reverse :)

Thanks,
Hugh

