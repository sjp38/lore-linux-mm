Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0665C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 08:49:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 703B520856
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 08:49:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RABwLnvH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 703B520856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1498E000F; Wed, 23 Jan 2019 03:49:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F418E0001; Wed, 23 Jan 2019 03:49:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85C378E000F; Wed, 23 Jan 2019 03:49:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 552F58E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 03:49:12 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id m200so806683ywd.14
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 00:49:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=zHcaJ9Q5sxtTyTYmUjqFPY7mRE6scDruydhRmv6TwHM=;
        b=O/t+hGR7X6sIq9Wjdvd4LC1/C98GGZI26kkx2K7q5LBy/78tYuNjFYa6AVFKN4OPBo
         dolWfuu5ELuTPFIEzO3/WgLxaLqbp68wdLMTIk8O1i03dYcS/O52UgOc1mDl9YozfdkE
         NAcXv5UjK9OuXWonmP2GTp07V28gXSQzBVEtrnUSNABhnQRR/xLLPLP9IrCFoQrG+Z6G
         WM+Kizwa8aSHqPky+tOz/tc0Aq9Ejj63k4CuqU1bmaf3eLfetdao60iiwNFFSsapqQUH
         USfnAWF2reI/gnQk12aVtjFnzEUpuTy5DutpVbUJo0E8BYNyUvH0YgV27dedvQDtAnvx
         9jRQ==
X-Gm-Message-State: AJcUuke7YyXmDpskvG54RERuylQDg4aFT4zksM3hQ8VFxFKzmGNpYnWG
	O48x2SQcWeOdsMRta4vEF873xdQcarikHTqDBL0L+eGj3FaXPzYNyF1wdxDNqNkJRlGRqabKt3O
	9fK/x+5eW3Vl3CAkJNJEl4fHDccCw3IA3BbGDpDJZgWVfncIWkmLkopxT7jAJ1T/66t5uWNM12Q
	JiwkA3ASCse9jJgxUTSxLa27UdKw/dWUHpjaxQb+A+Prs6eYrfjz56hO5DMLMpQtUoHmW/qIz84
	m+VPrpEMTyU6ogpCoGb27pPvRhTu1wQuDC0chu/H3JWTxP0aPNQFFwiSGVgA7ZeZIXLHwL4u8Pn
	c/EmBmaPOZPBCQ2cn+pS01/2ID8v+51xKbEyt8uPRUMqWqGlKyxYj+EiIz3jU2amkWXK4ZFPOk9
	7
X-Received: by 2002:a25:cb0e:: with SMTP id b14mr1101090ybg.498.1548233351640;
        Wed, 23 Jan 2019 00:49:11 -0800 (PST)
X-Received: by 2002:a25:cb0e:: with SMTP id b14mr1101067ybg.498.1548233350689;
        Wed, 23 Jan 2019 00:49:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548233350; cv=none;
        d=google.com; s=arc-20160816;
        b=fI2bEgF90ZuHYvDVGImD+2dit+8BgE2IwJBxvDkkwBwEkyqMYbSejQMWzjQpf2KtBf
         rh4wxDpthtDkdzrPhGYI5g6HwfzMZzBJF5upO6j5FrDJn1s2UKcGN/2jyL+qH5uB1NLj
         dYr9Le24IpTVgb48uhneJHN3cMzRhtBgeZwsKkVBFrrcDDlmlN8/ZpkULtXXTgRahS/b
         ltYocqO2EnYGaVt+EdwmArPlkXPtXZPOjb1SmNLfnfro1GJ0u0ccsAN3vZaKm6++WvKk
         k9rPjmpn0Nd2um29Qmq99n3p5cCYfHvw5V1W0ICfiWgjGjSwTs6jK1CWwkV0ZIGRs3QB
         c33A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=zHcaJ9Q5sxtTyTYmUjqFPY7mRE6scDruydhRmv6TwHM=;
        b=a3T12FZ9ngqJa97L5ow3gkCJxdK71QxDWhXZytGCzmte5e/1HvAxcrcH4MMAO56cWt
         dzczO69GRh3ogTLs1vRYras7KYKtf6frnpJIAulDRkMyVb0GKnplKPJj1akh5w69anfi
         AtXU6xbHJetYq1lj+KX/g42yAhD2q3KiXDV/Fp468r0gnBGcRmVJRo+Lgq0QYid6LGID
         CnlvJuevy7ent/zpydlbT9y5Gl+1pXXhXM4ZwboNLLweSH6o9JRXa6XmM1B92/xFY9OH
         cia8M4OvNR2PcQyPwxUqsLKVJYb+fFPcaAUgpUdzptWY5gKHGN2ANhHOrNZ3nwkuTubt
         T19w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RABwLnvH;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o127sor2408903ywf.31.2019.01.23.00.49.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 00:49:10 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RABwLnvH;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=zHcaJ9Q5sxtTyTYmUjqFPY7mRE6scDruydhRmv6TwHM=;
        b=RABwLnvH/yz6HLRyyX4+96KjX7GLmjk198p1LjMt2Dn3arkMlBvKddfSs/RnRietY9
         HZVohIp6A80qcxclZvnaqCH5WyIJJOqj0O9wJzrxjIbPDfR2CWingNYzN7I2K673Fh/a
         qWABxS4ZfBbtoSUAzI4MeYNBoop64GR0molSqmTfVEy9O5jUqa3A+MR1H0KspQeHjcYz
         SyALr6hJzwc15g6q65CFlYAYBBhJ8Ydp4cGDk1BueP15z84a7pvW2sX81bepIPYWcuYA
         EUrjgjfh//6g4aXQpPS6zxDGS8xbIdfFf2eW3fQUbX0krcRDmdPg4UVmdOGPuxt4I2ct
         zChQ==
X-Google-Smtp-Source: ALg8bN6wResBMAYuYDExcP2bQbmLjsKb8oJ6vGWSBOJbTP+kJJ8ZKzN57LS2M0tnr0CI1VlkSXOeQMjgIj/tlF1/3do=
X-Received: by 2002:a81:c144:: with SMTP id e4mr1157905ywl.409.1548233350234;
 Wed, 23 Jan 2019 00:49:10 -0800 (PST)
MIME-Version: 1.0
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 23 Jan 2019 10:48:58 +0200
Message-ID:
 <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Subject: [LSF/MM TOPIC] Sharing file backed pages
To: lsf-pc@lists.linux-foundation.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, 
	Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123084858.dRGoraI9ciCkTtK6M8mW7dB4FDNz_2SbGTq9WhuseBs@z>

Hi,

In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
up the subject of sharing pages between cloned files and the general vibe
in room was that it could be done.

In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
that Matthew Willcox was "working on that problem".

I have started working on a new overlayfs address space implementation
that could also benefit from being able to share pages even for filesystems
that do not support clones (for copy up anticipation state).

To simplify the problem, we can start with sharing only uptodate clean
pages that map the same offset in respected files. While the same offset
requirement somewhat limits the use cases that benefit from shared
file pages, there is still a vast majority of use cases (i.e. clone full image),
where sharing pages of similar offset will bring a lot of benefit.

At first glance, this requires dropping the assumption that a for an uptodate
clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
Is there really such an assumption in common vfs/mm code?
and what will it take to drop it?

I would like to discuss where do we stand on this effort and what are the
steps we need to take to move this forward, as well as to collaborate the
efforts between the interested parties (e.g. xfs, btrfs, overlayfs, anyone?).

Thanks,
Amir.

[1] https://lwn.net/Articles/684826/
[2] https://lwn.net/Articles/747633/

