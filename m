Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FCA2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE626206B6
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:58:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ds0m1BM2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE626206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B4898E0003; Tue, 19 Feb 2019 00:58:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363118E0002; Tue, 19 Feb 2019 00:58:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 253A98E0003; Tue, 19 Feb 2019 00:58:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D829E8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:58:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e34so13643888pgm.1
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:58:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cS1DH879CcIl+bs6b1wVapY22RVLC7csNXI6tVxFYVA=;
        b=iOQE0b0GCYdWXOZ29IZDNj4/J0w9DbS5arx7+KNNLLSAl7lLaOgfo8PkRx20rWgrkd
         jCVzkL1Csj9nRC2ebQAZSYPzyds2CiyJbGb3hsKRdiktwmToCMPjaGvKbRGuvDgi0eMX
         N67Bk9GrbCljKD6elAbE/mcbDhc2erXYLEk6ctKuJWZdrSebarpsDqU0K5Uvnv2bWpqj
         L+oYggX7K1qfpsQQs5/OpOjalXJcPe0jkcipaNPAOamIuRUh3BymK/aBaCq8iFsNRnqH
         hBL3XW1APHflqnlkE/loNjzlguXbtb8TrNz4bspBA/FT1nR/zRmjD/9BEZ6bVZ6LfkEi
         OrIw==
X-Gm-Message-State: AHQUAua+mfyK2zo5GG8UIYsc6Zgy9vAhoGLtQDxQMwVudmyez1YA3Se1
	/eFgBdebYvdnGsodaEnIGwOqUPWh9c22nSIq3X9+E+Ayvd0y6eLi1rlcXe5ezR1rXhAL3rCqNtd
	MSBYQ45rQqj3H/mWMhGwmXcjQJK45AkGyPLYJV8ZH7YkQvd16R9S9WxxVajhllUBiAg==
X-Received: by 2002:a63:981:: with SMTP id 123mr22464070pgj.444.1550555936390;
        Mon, 18 Feb 2019 21:58:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxA/6MA98yRrf875REy+BPSPTpWGA7QraXtnnvQ2Y1//IHk8OUd7OTF972H6enEhfAkIC7
X-Received: by 2002:a63:981:: with SMTP id 123mr22464025pgj.444.1550555935468;
        Mon, 18 Feb 2019 21:58:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550555935; cv=none;
        d=google.com; s=arc-20160816;
        b=nXTWb/BpYf0AlIP+qyZJEOZhDtjVmy5F3E5XmlVubk51rda/M6KhUWiUT4HfJCd9BY
         x9n7O94/FE7uo1OmeHC0W/TMh0x2MFWuIoS8ARqC2Zs13060i3rSxTtVSqCKPpDaJgbo
         hh7wp07iR9kSVWUcDTmt4+lH/KyFmIAlp7J9JF7ZoOY07Mngm/Wd6MH9j5be+zcm2VmH
         T0NIB74kt2iF+8XxZH3WdWpRyXd5cdC2P757U1Rtl4NCiMRB8aZBvGf3U2L8Fxa0tLB3
         buZsrXAtzmnORVfVjfEfBJayhwoYLEQ1GoioaSP9GqqsT+BE2vERXkp7PFQjhL2qmgU2
         vpCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cS1DH879CcIl+bs6b1wVapY22RVLC7csNXI6tVxFYVA=;
        b=eERNS8usXcgWdczWuI1Bsz4LZ/ZwXCrYPZQ/RtFpqSZdr3efp0FRsVFAHGBSWUFUws
         rJ0ZHhYyg0IvVpLICQ05zrqwtnujjtAsuRdG4mriFgYY0zSzCnxuWSkL9DAIWlo1a5Xd
         9IVOIKYP+iw+NZ431cLWrzwynEuXRxK08M0/HUCVi/rzwOweirYOLU4g9QCryLkf1ta6
         bd/YWOigsVA4OsjLl6k196c3Cy0fniR1ut1pH2u9QBeWUAkbbaqZq0SiLMLGbVfI4FoQ
         lov5LBEt5cGBuSyardLUZ4DIif7PbdfUmydFayCdHtA5rrVqzqJXDPzWhhxZOMx5jAq0
         57mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ds0m1BM2;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u5si1471865plm.225.2019.02.18.21.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 21:58:55 -0800 (PST)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ds0m1BM2;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1J4YG05071284;
	Tue, 19 Feb 2019 04:34:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=cS1DH879CcIl+bs6b1wVapY22RVLC7csNXI6tVxFYVA=;
 b=Ds0m1BM2QxOJ1KJN0N2goUBwoMP5EWX5pR1QMMZWCWHcyBitekTTRFXRCiKgxpndQ1Un
 RRAiGkbatWXNAL4DP/KgNlgRq7IATMm1yAyKf0S2YDmzy9DXSro7CSBvWoXesIF+mDHT
 ooieNsOjgRKOiJH07uyN9+0nPTwTJiaNnzIhF691mzfwe6D4JZdcrWv3Dg5p0kbHpEjW
 PJzjEHU9mwz4vq1K06m55ivhHwspKi5kBZrfnQwk6+0fQaumzjYydlj0xEZIc8K5M63n
 uZO4tQZNwtfJ64qTcUNR1UF/SQDl7dBL0NAMMiTkGKoJ2ceP7w+DtmAvr1+JJhTI6F2y Uw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qpb5r8qn7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 19 Feb 2019 04:34:16 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1J4YADm022085
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 19 Feb 2019 04:34:11 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1J4YAHO025021;
	Tue, 19 Feb 2019 04:34:10 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 18 Feb 2019 20:34:10 -0800
Date: Mon, 18 Feb 2019 20:34:08 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matej Kupljen <matej.kupljen@gmail.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: tmpfs inode leakage when opening file with O_TMP_FILE
Message-ID: <20190219043408.GG6503@magnolia>
References: <CAHMF36F4JN44Y-yMnxw36A8cO0yVUQhAkvJDcj_gbWbsuUAA5A@mail.gmail.com>
 <20190214154402.5d204ef2aa109502761ab7a0@linux-foundation.org>
 <20190215002631.GB6474@magnolia>
 <alpine.LSU.2.11.1902150159100.5680@eggly.anvils>
 <alpine.LSU.2.11.1902181945240.1821@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902181945240.1821@eggly.anvils>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9171 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902190034
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 08:23:20PM -0800, Hugh Dickins wrote:
> On Fri, 15 Feb 2019, Hugh Dickins wrote:
> > On Thu, 14 Feb 2019, Darrick J. Wong wrote:
> > > > On Mon, 11 Feb 2019 15:18:11 +0100 Matej Kupljen <matej.kupljen@gmail.com> wrote:
> > > > > 
> > > > > it seems that when opening file on file system that is mounted on
> > > > > tmpfs with the O_TMPFILE flag and using linkat call after that, it
> > > > > uses 2 inodes instead of 1.
> ...
> > > 
> > > Heh, tmpfs and its weird behavior where each new link counts as a new
> > > inode because "each new link needs a new dentry, pinning lowmem, and
> > > tmpfs dentries cannot be pruned until they are unlinked."
> > 
> > That's very much a peculiarity of tmpfs, so agreed: it's what I expect
> > to be the cause, but I've not actually tracked it through and fixed yet.
> ...
> > 
> > > I /think/ the proper fix is to change shmem_link to decrement ifree only
> > > if the inode has nonzero nlink, e.g.
> > > 
> > > 	/*
> > > 	 * No ordinary (disk based) filesystem counts links as inodes;
> > > 	 * but each new link needs a new dentry, pinning lowmem, and
> > > 	 * tmpfs dentries cannot be pruned until they are unlinked.  If
> > > 	 * we're linking an O_TMPFILE file into the tmpfs we can skip
> > > 	 * this because there's still only one link to the inode.
> > > 	 */
> > > 	if (inode->i_nlink > 0) {
> > > 		ret = shmem_reserve_inode(inode->i_sb);
> > > 		if (ret)
> > > 			goto out;
> > > 	}
> > > 
> > > Says me who was crawling around poking at O_TMPFILE behavior all morning.
> > > Not sure if that's right; what happens to the old dentry?
> 
> Not sure what you mean by "what happens to the old dentry?"
> But certainly the accounting feels a bit like a shell game,
> and my attempts to explain it have not satisfied even me.
> 
> The way I'm finding it helpful to think, is to imagine tmpfs'
> count of inodes actually to be implemented as a count of dentries.
> And the 1 for the last remaining goes away in the shmem_free_inode()
> at the end of shmem_evict_inode().  Does that answer "what happens"?
> 
> Since applying the patch, I have verified (watching "dentry" and
> "shmem_inode_cache" in /proc/slabinfo) that doing Matej's sequence
> repeatedly does not leak any "df -i" nor dentries nor inodes.
> 
> > 
> > I'm relieved to see your "/think/" above and "Not sure" there :)
> > Me too.  It is so easy to get these counting things wrong, especially
> > when distributed between the generic and the specific file system.
> > 
> > I'm not going to attempt a pronouncement until I've had time to
> > sink properly into it at the weekend, when I'll follow your guide
> > and work it through - thanks a lot for getting this far, Darrick.
> 
> I have now sunk into it, and sure that I agree with your patch,
> filled out below (I happen to have changed "inode->i_nlink > 0" to
> "inode->i_nlink" just out of some personal preference at the time).
> One can argue that it's not technically quite the right place, but
> it is the place where we can detect the condition without getting
> into unnecessary further complications, and does the job well enough.
> 
> May I change "Suggested-by: Darrick J. Wong <darrick.wong@oracle.com>"
> to your "Signed-off-by" before sending on to Andrew "From" you?

That's fine with me!

> Thanks!
> Hugh
> 
> [PATCH] tmpfs: fix link accounting when a tmpfile is linked in
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
> Suggested-by: Darrick J. Wong <darrick.wong@oracle.com>

Or if you prefer:

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/shmem.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> --- 5.0-rc7/mm/shmem.c	2019-01-06 19:15:45.764805103 -0800
> +++ linux/mm/shmem.c	2019-02-18 13:56:48.388032606 -0800
> @@ -2854,10 +2854,14 @@ static int shmem_link(struct dentry *old
>  	 * No ordinary (disk based) filesystem counts links as inodes;
>  	 * but each new link needs a new dentry, pinning lowmem, and
>  	 * tmpfs dentries cannot be pruned until they are unlinked.
> +	 * But if an O_TMPFILE file is linked into the tmpfs, the
> +	 * first link must skip that, to get the accounting right.
>  	 */
> -	ret = shmem_reserve_inode(inode->i_sb);
> -	if (ret)
> -		goto out;
> +	if (inode->i_nlink) {
> +		ret = shmem_reserve_inode(inode->i_sb);
> +		if (ret)
> +			goto out;
> +	}
>  
>  	dir->i_size += BOGO_DIRENT_SIZE;
>  	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);

