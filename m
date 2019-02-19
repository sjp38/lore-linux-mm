Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DD34C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 469A421848
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:48:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 469A421848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80CC8E0004; Tue, 19 Feb 2019 00:48:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D55C08E0002; Tue, 19 Feb 2019 00:48:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47568E0004; Tue, 19 Feb 2019 00:48:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1C88E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:48:15 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id l5so8821734wrv.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:48:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=2s2UoIshcg+Lry9kl5cpTRzFGHWhySz8aruPidqxSaw=;
        b=ktRXUmhqeBoi5xT6u9ohTZ4FDsXZ7UUSqLlSGjTMWhLcUWCtMpjvW4UH6Nr7VVvo12
         k6e+ZaQjrny0DNxIvgxKP19/Yyya29+DCqDSkoA8/KFDW3fnaFhLIfJTzuiHfz8MxemA
         TNZnjRrletoF3NIgp3zxl4/IhcuQSn1U9bduIH99+iI35jXDc1ha1GPOrcPLNqzUWujd
         hyTR4D4UNlp/MBtbs+AURdrPnpOnv7/ZG0WZK8PwWP4ycvg6kmXoUYLxxKEVnpT5DGj4
         jIFS5Rqeo0JSDKAldNM5CY0OgRVj2GCAxrpnOqJT//+KJd506SFbi2q4rjMzt35mtX46
         9gXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: AHQUAuYVnp1dDVpdP8VcIqTD7Ny/V7s0rv0UnLswGv025rkqZE5zM2Gx
	rcjBOpbbG443L0kqqnHfH2gdKFkOc5cEiqqdLNSCPVwtuuxFCxTPVBO6qRIJh8m8gvNQlvWdBsF
	2lgQZwaEOiaIkfX7hkpNO9KvUkLVffESBCzzLtzJL1gBvatCXlx1OJucXzkiaqsLHKQ==
X-Received: by 2002:adf:afcf:: with SMTP id y15mr19692129wrd.261.1550555295002;
        Mon, 18 Feb 2019 21:48:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdIjeu2t1lqpyjOuZB8F+Ov3eumS9r2zxXdFbWFsNM2kiEdTN8S9ANwtnrvFUEXSsHiJhn
X-Received: by 2002:adf:afcf:: with SMTP id y15mr19692095wrd.261.1550555294246;
        Mon, 18 Feb 2019 21:48:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550555294; cv=none;
        d=google.com; s=arc-20160816;
        b=PUpoV25FYa6XItzwU2AXTS+av2w1GdPsPNjaIT4YKFCyTS+FLIocyAZ5RtPfP8Z/87
         OZmKs0OeOZRNBbNulCcXXIzHnmbGUiRB5WGjThTq8ta2cO9pSmkqKBsYqj7hxIcD5QSp
         pfuBip6hSAkycfyADJgdYN5IWwUqt0sRu5bZm6DaUlUDSt891xShwzlwV/TaLyKTh65G
         71Tx/bYnF1vw4frpgGp2/7llE4RIlhLMcXZMp3F23rpatbTk1Sq8jmGkKSXGn8CCQehB
         p6vTnSwILxVP+s0I/mzoW80oQTwrhszUfbUb8cYhySWQrtwlW4jY8d1EGEtHGbQOhADB
         mXhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=2s2UoIshcg+Lry9kl5cpTRzFGHWhySz8aruPidqxSaw=;
        b=Xu3gFI2mLSYj6ui8LkrW0QIJVM2+x8IrhMNbnzEl0GSQTZiBDF4SiUgMDwhsHKNZTY
         AZcVP/Jz9zwOq/6eAPFNDgw6snqr/GyoXUvCC3zQCKH7mC6vdstI7p7RE1851FYUS3z0
         oBTGGL38hpmrrgIM561JiDIHnkEsVTovXUgAcbHhCCD2T4c4dvcX2EN5lpxa9Lg/FCW6
         zCBGbW3qQ43Y/0V3dBvRo4mGU/osp8aGMinf1J6kzZgzVkSBZ79C4LMrZxJLsi6U4ZBQ
         XE7aAlUOrh6hxZhkEKSbUkF4fsZs+7pDqHmhqID8G9klND260cIg8y43i1TTEuzpV5rs
         S/cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id v11si781164wmh.35.2019.02.18.21.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 21:48:14 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.91 #2 (Red Hat Linux))
	id 1gvyGG-00086D-0y; Tue, 19 Feb 2019 05:48:08 +0000
Date: Tue, 19 Feb 2019 05:48:07 +0000
From: Al Viro <viro@zeniv.linux.org.uk>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Matej Kupljen <matej.kupljen@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] tmpfs: fix link accounting when a tmpfile is linked in
Message-ID: <20190219054807.GX2217@ZenIV.linux.org.uk>
References: <alpine.LSU.2.11.1902182134370.7035@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902182134370.7035@eggly.anvils>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 09:37:52PM -0800, Hugh Dickins wrote:
> From: "Darrick J. Wong" <darrick.wong@oracle.com>
> 
> tmpfs has a peculiarity of accounting hard links as if they were separate
> inodes: so that when the number of inodes is limited, as it is by default,
> a user cannot soak up an unlimited amount of unreclaimable dcache memory
> just by repeatedly linking a file.
> 
> But when v3.11 added O_TMPFILE, and the ability to use linkat() on the fd,
> we missed accommodating this new case in tmpfs: "df -i" shows that an
> extra "inode" remains accounted after the file is unlinked and the fd
> closed and the actual inode evicted.  If a user repeatedly links tmpfiles
> into a tmpfs, the limit will be hit (ENOSPC) even after they are deleted.
> 
> Just skip the extra reservation from shmem_link() in this case: there's
> a sense in which this first link of a tmpfile is then cheaper than a
> hard link of another file, but the accounting works out, and there's
> still good limiting, so no need to do anything more complicated.
> 
> Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
> Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

FWIW, Acked-by: Al Viro <viro@zeniv.linux.org.uk>

Or I can drop it into vfs.git - up to you.

