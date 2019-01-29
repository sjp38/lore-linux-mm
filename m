Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B8F0C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:51:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 275A1214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:51:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RzAlWWCf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275A1214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B85F08E0002; Tue, 29 Jan 2019 10:51:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0C7B8E0001; Tue, 29 Jan 2019 10:51:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D47F8E0002; Tue, 29 Jan 2019 10:51:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C28D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:51:17 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id y6so10257846ybb.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:51:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=KPvAmBd7SxWszJX5z25Se4g5haPwrJDLEnstw64/0iE=;
        b=YRAgtBu+Xp6v3x08e/SsD9KvfeeUj+wWkG2y3X2rthY6sBDZtaDEA/8x/nSZzIwHGQ
         Eb3Wd1GNhQY+S7xAmF5UzhNasFH32No5m6z8NojRFZ6jPwpYEYO7R/6K+lyzdpWzd9Oy
         ShnafDBbU9KrEmJmQk5v6xivVZ+lPK6XZOk8vLK8ozWqoaZUHQRIWWICpHN3JMirZnaV
         d+T92T8jz2N5Pa8ObotyIL/0sEvn6IUKI9yIrZjJkinuchvP/shs9NjhNJtgiAxxzlo5
         jKDltrA6ElCzsyzdVU3SfxG4xWfJinbjmoSI1oyQgA0sVk4lrz4PNcXMAffRSIr3ckKU
         C8YQ==
X-Gm-Message-State: AJcUukeKmk9iWdTctn8NzYjE4JX6fE/Tz8V31NplKfaqrslcSAYxITjK
	3xhxim0UiKau6klFP1JHsgefVjZXKLd+CGLLl52c4UD0mHOBCfuRIWhiSpd+b1ZJflygOCdPG7B
	fX99cK4lR9I52h1GmXIoaUZf2gxlolKmhYP17iMtXmxucxEmIny7b/8+EX1GSOQYu5Q==
X-Received: by 2002:a81:7c04:: with SMTP id x4mr17427163ywc.264.1548777077081;
        Tue, 29 Jan 2019 07:51:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4K6pm0EgPPELUcYgls/fkXHGqj4FX8mTF6OWw4Ag4Po3CduQN5KdkwOAM2GSeqaulxVE6+
X-Received: by 2002:a81:7c04:: with SMTP id x4mr17427123ywc.264.1548777076489;
        Tue, 29 Jan 2019 07:51:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548777076; cv=none;
        d=google.com; s=arc-20160816;
        b=FTbNnSqVZt54109vK+D1Q7OuXSQWyHzTcguJnoJMoEXneB4TgTj41MeJXYHRxNRe/w
         Rm3DJImoSmncg3jL9xe49eoBoJJEhMv0E10EnjhQsvmlRKVB/5cRY67YRtugj8Xn5IW1
         kWxvWGVUwd0Jv2H4yYQJkNFq52QQEYf+Rl6tt2mtOAbdSJlvqAHpRpnVvoacbqNn2FDF
         Xr9PNgXfyBRTm0jnEIdMNK2wPv5bKSz4tYFe0d6fY64uclD9FkJpYRGA1g+NHcK3WJiJ
         lCxN7lDkPr+vxwEPFv5UlUcthiJe8+cCXyIDkN/Zy3bEqtC+WiPdgnUmCCcxdQdNZdj5
         /bgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=KPvAmBd7SxWszJX5z25Se4g5haPwrJDLEnstw64/0iE=;
        b=JYnzx1zSB075okxhvBZXckMMM/G/Ct3Yt5I1FbZQ/4s+8xie6iKEGncX7wggacZ1Zm
         eBVPMGi+E9qSHxlTgxMkMr1ACZYewBtxQrqgxnBh/fPzPnpYeBTNcxXDGDr70I44G8pj
         mlPlUTu8rRZcRr8WSCU2CYAcLhcQtJsbTZYteqjVRPsDGkWHPyGs8mMb7xsW0/kaOx3m
         098Czljx0zI47MCFwUPE7MbN7ZdTM8/hRTbVmy+gT9QtPkfHCbpcyCjctDlGskLcMdIs
         DRGQJ3kH3uEUjwukMlKoOT72hmALOmxfm74MqUO+QyCvbHWEkE74R8SRMXPLWPYiojX2
         mVVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RzAlWWCf;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v70si21061574ybg.50.2019.01.29.07.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 07:51:16 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RzAlWWCf;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0TFi7Tg175709;
	Tue, 29 Jan 2019 15:51:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=KPvAmBd7SxWszJX5z25Se4g5haPwrJDLEnstw64/0iE=;
 b=RzAlWWCfOARACGa6A7lvdljgHCYFSyJubAzipcBJqX0AyvDMPxfd/L/kPXH4XULvu8G0
 0IvlsIbFwCoti6KU/Jld+PepDpD2pKWrbSRZ4p2nhQKR9HzEebBdhdtaCRFalMKtSMNO
 x9fU288znIHEEnFwNEAKLW3847SeE+HVFYLW4NvpQx6hIOuf+rLRQG3URX+32yW9SW82
 dZL1rhbF2jp17+DB9+o9TX41oKUc3eteSApX55HjcMimY2xC6PZ3qs7IexXjZIatEZtg
 o2suCnGCOoH2cga5XQxxQNrlwKgOJ+1XvidH5HkF0w55MHOboqx6ZdQr1O6WTUCkFREB 9g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2q8g6r55hg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 29 Jan 2019 15:51:11 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0TFpADc023200
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 29 Jan 2019 15:51:10 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0TFp9QB004204;
	Tue, 29 Jan 2019 15:51:10 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 29 Jan 2019 07:51:09 -0800
Date: Tue, 29 Jan 2019 10:51:28 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ben@communityfibre.ca, kirill@shutemov.name,
        mgorman@suse.de, mhocko@kernel.org, riel@surriel.com,
        daniel.m.jordan@oracle.com
Subject: linux-mm for lore.kernel.org
Message-ID: <20190129155128.kos4hp7rnqdg2csc@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9150 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901290118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000079, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm working on adding linux-mm to lore.kernel.org, as previously discussed
here[1], and seem to have a mostly complete archive, starting from the
beginning in November '97.  My sources so far are the list admin's files
(thanks Ben and Rik), gmane, and my own inbox.

However, with disk corruption and downtime, it'd be great if people could pitch
in with what they have to ensure nothing is missing.  lore.kernel.org has been
archiving linux-mm since December 2018, so only messages before that date are
needed.

Instructions for contributing are here:

  https://korg.wiki.kernel.org/userdoc/lore

These are the message ids captured so far:

  https://drive.google.com/file/d/1JdpS0X1P-r0sSDg2wE1IIzrAFNN8epIE/view?usp=sharing

This uncompressed file may be passed to the -k switch of the tool in the
instructions to filter out what's already been collected.

Please tar up and xz -9 any resulting directories of mbox files and send them
to me (via sharing link if > 1M) by Feb 12, when I plan to submit the archive.

Suggestions for other sources also welcome.

Thanks,
Daniel

[1] http://lkml.kernel.org/r/20180926130850.vk6y6zxppn7bkovk@kshutemo-mobl1

