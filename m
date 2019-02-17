Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0DFAC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 00:29:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 755EB2147C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 00:29:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 755EB2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D927C8E0002; Sat, 16 Feb 2019 19:29:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40538E0001; Sat, 16 Feb 2019 19:29:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31118E0002; Sat, 16 Feb 2019 19:29:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67A9B8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 19:29:16 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j44so5655148wre.22
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 16:29:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=AHen3MfOAQSTJkIevZgr4e8H6mm4AVcx5rx7eJLQI0E=;
        b=mgvLAlAiuzaxLYRUemJ4n19DU75OAFS+6nsSXrhXC5wH9R6CKcZ8bco8wBa9r0LBph
         b8+65m6SgWn1nuDjXzqQ1KHlBGxkIUi2W7qOIyI2CtWiVinFbzvsGLo0JDCL/LSp4Vmh
         KEe3bBMKaBiDQSIbFDD85ELYO7ea5NcPjpcgICI9OFGoxlzJ/3d+p+y47USSUWSeBfLH
         PxdlSF06O4GBHqyRfpmFJqDPJcUnkhZRqCSTJ9EpPGT9J59Y5/lBdzaJOAysAX2Kty+/
         Ai6xA0WzBECKpYgvX3BfZt50raFkAWgiVEbdBHS9h78Y0QVWfFiROkhtPR02F9D+pRlO
         fwDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: AHQUAuZsHAB/Wl82KUE0D7bHBkr5NfUyajZi8N3MeGr5jeNVj7ZpJxrN
	MDsy/NB0dSkm0BIGtAazSBUHnTMofLh610Aqb/EAcQFq0bX8I+H/U5oiH5EQ9ggN4tmKgFXfriw
	PRmWDrvkDWdpDKM620E25Coluh/5+wD5ZRhLhyh1+0vRuNaGhjf0oCNQTMQ52zv0Hvg==
X-Received: by 2002:a5d:654d:: with SMTP id z13mr11249625wrv.270.1550363355957;
        Sat, 16 Feb 2019 16:29:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbfYZedKhGAJlMhyuOAGK01XnGTc2syfzPPTNDv8Ifb71EnbwHTtYJE1ZIzkGHoR4RPOJHu
X-Received: by 2002:a5d:654d:: with SMTP id z13mr11249601wrv.270.1550363355063;
        Sat, 16 Feb 2019 16:29:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550363355; cv=none;
        d=google.com; s=arc-20160816;
        b=V1jsXFRQhVXWrgK+Prb34zeiRyAQuwporRbglvNpaScdA2bmRVFlf72LByV7VQgwV3
         akwhFIBS3VFvYs5UwoN4bVkPtfWJex1vpUy7eibZ+uMKk6/Kfq5wDP4Lo2Ph4ElvgrvK
         uJAjBz+plSwcS0kpeMCShHaFIiHy7Rg1plleOmWWuVwaK9+eh6ZDV0eTKGuCnGLHMuVj
         eUqq8ZwslsyOeB/exCLV8mkDMJXlwuMPLhHlJhBLwrEKkNsTLLyocpoLtQEyTQdAE1q4
         iESokSYd7Ppvku6yDxLtezzAwpASP86GhA0oGQaGWHhfdnf8CuItDMTr9QYvzEjxZ5IC
         rNtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=AHen3MfOAQSTJkIevZgr4e8H6mm4AVcx5rx7eJLQI0E=;
        b=nXiFVyNQPCy48WDvp7DKI4zIbxKF1w+A3FmjHPfTvZhkJm7qWRQUX34Qxr2edBVlWe
         GxxtRcriK6huwbwvBkPewgWM247QgYKf1yS3NPBOjDHJMTD0u6rbtiuAGjKhaSdcHOGT
         C1z01zNfORQcg68RZv0yV6hv5C4+GfAckdJG4nIZbvLdvDIKEM7IMnRP04i53o04SV5d
         oL06zU3btBlGd/HR+2QO5ukN0ow4k9ivH9upTGyV0JUtSYG0pdtfmYlSgWeiZyxiRlIE
         hx0ZS95EgAkzG6a4XKSP9EmqqeumGBe97pM7d1KR0UFcVhC8V7LnBuAItK0KOpYwUlMG
         aZQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id l11si6361949wrn.177.2019.02.16.16.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Feb 2019 16:29:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.91 #2 (Red Hat Linux))
	id 1gvAI8-0002rx-Ve; Sun, 17 Feb 2019 00:26:45 +0000
Date: Sun, 17 Feb 2019 00:26:44 +0000
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: clm@fb.com, josef@toxicpanda.com, dsterba@suse.com, jack@suse.com,
	tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org,
	yuchao0@huawei.com, hughd@google.com, hch@infradead.org,
	richard@nod.at, dedekind1@gmail.com, adrian.hunter@intel.com,
	linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org, linux-mm@kvack.org,
	amir73il@gmail.com
Subject: Re: [PATCH v2] vfs: don't decrement i_nlink in d_tmpfile
Message-ID: <20190217002644.GT2217@ZenIV.linux.org.uk>
References: <20190214234908.GA6474@magnolia>
 <20190215223925.GO32253@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215223925.GO32253@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 02:39:25PM -0800, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> d_tmpfile was introduced to instantiate an inode in the dentry cache as
> a temporary file.  This helper decrements the inode's nlink count and
> dirties the inode, presumably so that filesystems could call new_inode
> to create a new inode with nlink == 1 and then call d_tmpfile which will
> decrement nlink.
> 
> However, this doesn't play well with XFS, which needs to allocate,
> initialize, and insert a tempfile inode on its unlinked list in a single
> transaction.  In order to maintain referential integrity of the XFS
> metadata, we cannot have an inode on the unlinked list with nlink >= 1.
> 
> XFS and btrfs hack around d_tmpfile's behavior by creating the inode
> with nlink == 0 and then incrementing it just prior to calling
> d_tmpfile, anticipating that it will be reset to 0.
> 
> Everywhere else, it appears that nlink updates and persistence is
> the responsibility of individual filesystems.  Therefore, move the nlink
> decrement out of d_tmpfile into the callers, and require that callers
> only pass in inodes with nlink already set to 0.

NAK.  You are changing semantics of existing helper, requiring to add
boilerplate to existing users.  With zero indication that such need
has appeared - no warnings, etc.

If you need a variant that wouldn't do nlink decrement, just add it
and turn the existing one into a wrapper.  Yield smaller patch, at that...

