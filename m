Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5FDEC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 22:32:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34FE920823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 22:32:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mit.edu header.i=@mit.edu header.b="rHWr2qmn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34FE920823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF4B08E0003; Mon,  4 Mar 2019 17:32:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA4308E0001; Mon,  4 Mar 2019 17:32:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96B118E0003; Mon,  4 Mar 2019 17:32:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56DE28E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 17:32:41 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 19so6886987pfo.10
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 14:32:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QW/mdqHkjKKIUcQAnlv7zyRg2yakaNhHG0aNy4v8bi4=;
        b=iLr/EdZ/Jo8HZsg5UUdbWCE/N77WE6eC1H+BkYTSDOrkUr3ZP/xBxUdA1T0HxeRY4/
         FUSwKC7+90+2XyEeJPqZMaXtKTwWLMg+8yVm2kB/XuTkjlPBf/MOPjWWs+D4zBLIBsW/
         74R3t73uXpH1GsKVUAqau1rhF/8Z2MTCAHfgGQrxsUBc6qb1tYi4xdlNdo9axCrGTid6
         0ebg17USu0hm5XuP15RTqFTF6c15inmMzz2UlLxK/JSoXKU/P2gGZoisAuykqWDVlR3c
         He9JOthYgSssGQyB2lw6idXxSqFD6KbxzWmzR7kmdlbfBMwttOj6okftMdXUZa/tC98T
         03lA==
X-Gm-Message-State: APjAAAVaShPbEUIeGPdRZlxYaylWKhpKeh2EmK/G634zMvhUh3KHrWc4
	5rl4u1p+Jo/yr+yIG2Bkc3Pyfw5JGGAajhNFWGBm9e/+FEoLE2p4G2Oek/bPDcW3XaOQ+H8kYS3
	kAhLJEqIqJP+KaQOCJzfW0tu/bGPQyH7sUGYREH+S/BaXVlVf/rjWbP4omrev4Iml1Q==
X-Received: by 2002:a17:902:bf05:: with SMTP id bi5mr22852059plb.259.1551738760952;
        Mon, 04 Mar 2019 14:32:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqxJ3l3W8rBw9jqQivnruv9fAsrRxuTAOJlkFKcguZ2AMmAolhVJ6vtHYt8sNgjQyuIQ/2mx
X-Received: by 2002:a17:902:bf05:: with SMTP id bi5mr22851959plb.259.1551738760014;
        Mon, 04 Mar 2019 14:32:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551738760; cv=none;
        d=google.com; s=arc-20160816;
        b=hbCZUyaoo80IRzll45Uk4xKnWz6q2sMFRvuDLN1L7WHEySXORU2trnxMkKIxnZ91uk
         6sxJXZFvgxqTCBKyv/NcNb0zipBssTaef6YRZhLQ7kk9IB3USfSsnNwmT/na4kpRwjbF
         6NaaFnk4Rq4/u5ILALhyTlhLMnEaQVkX1VDdEV0mi56TqUQ19nPkzPYaP8a+s/ECpPgn
         TfqeLjTrMFwtbbKb7LcANcGCyF3gXrIUXRW1959ntPuddJTs8iqmuSOrkMBeWvZ7XWME
         5lCspS+auunwdvrRSswDIMGYWBOEY18xWR/qWre/P+0Plm4kApi333ZE4zacZHpvTKJR
         dI1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QW/mdqHkjKKIUcQAnlv7zyRg2yakaNhHG0aNy4v8bi4=;
        b=IxZQ6mV2DH3gvzjgWmpWslJVPZGDqbh87SUebda1ESHEsN5k2/oVsyYLZ5A4cWl050
         UoEdNA4lgVs/U5YG1RTQa7Q25gssPUSUHaUYRTT4cgAG8+7proOg2gjtuywOG8D4ZbGq
         5cxd/uwsQylBotYZ+BZnxmOnaErlI4GK42nTQ18bWYf+Noc/Oxqe1mDg4QkP4eW2UDGp
         1ARQz/tX70IJC0vf3RaGPgLDjR0ceUDfcu+k90s3zsMOJQWKx7Og++BniOMeS1oUVE7g
         UjwYQ5y1xqrRexTmbTFBO9KNxuFUBsxBkySbLS+EVX75/ZTRIMq1GjJh1Dbxi5Azz8Ib
         s3jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=rHWr2qmn;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.80.92 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800092.outbound.protection.outlook.com. [40.107.80.92])
        by mx.google.com with ESMTPS id t63si6312698pgd.367.2019.03.04.14.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Mar 2019 14:32:39 -0800 (PST)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 40.107.80.92 as permitted sender) client-ip=40.107.80.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=rHWr2qmn;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.80.92 as permitted sender) smtp.mailfrom=tytso@mit.edu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QW/mdqHkjKKIUcQAnlv7zyRg2yakaNhHG0aNy4v8bi4=;
 b=rHWr2qmnxHOJvOQfLxOFnF5R5LOADbiE065dZ2BM++4clN2Y2QgzTrnATs5T5EBu3V5yZByejC0hxfOd6sjAzgy0Mt3Qv6dC6LihONJND9AkAuI/KO+n+w3Ai/6SJ6+0bAte6hXYZfMk06RAmuVwYHeelkvJoeDmclWwIylH0/8=
Received: from BL0PR01CA0019.prod.exchangelabs.com (2603:10b6:208:71::32) by
 BL0PR01MB4850.prod.exchangelabs.com (2603:10b6:208:7e::24) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.15; Mon, 4 Mar 2019 22:32:36 +0000
Received: from BY2NAM03FT039.eop-NAM03.prod.protection.outlook.com
 (2a01:111:f400:7e4a::202) by BL0PR01CA0019.outlook.office365.com
 (2603:10b6:208:71::32) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1665.16 via Frontend
 Transport; Mon, 4 Mar 2019 22:32:36 +0000
Authentication-Results: spf=pass (sender IP is 18.9.28.11)
 smtp.mailfrom=mit.edu; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=mit.edu;
Received-SPF: Pass (protection.outlook.com: domain of mit.edu designates
 18.9.28.11 as permitted sender) receiver=protection.outlook.com;
 client-ip=18.9.28.11; helo=outgoing.mit.edu;
Received: from outgoing.mit.edu (18.9.28.11) by
 BY2NAM03FT039.mail.protection.outlook.com (10.152.85.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1643.13 via Frontend Transport; Mon, 4 Mar 2019 22:32:35 +0000
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x24MWW6a021873
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 4 Mar 2019 17:32:33 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 40E857A3F4A; Mon,  4 Mar 2019 17:32:32 -0500 (EST)
Date: Mon, 4 Mar 2019 17:32:32 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Pavel Machek <pavel@ucw.cz>
CC: <adilger.kernel@dilger.ca>, <jack@suse.cz>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: Re: 5.0.0-rc8-next-20190301+: kernel bug at fs/inode.c:513
Message-ID: <20190304223232.GA6323@mit.edu>
References: <20190304160255.GA6914@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190304160255.GA6914@amd>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-EOPAttributedMessage: 0
X-Forefront-Antispam-Report:
	CIP:18.9.28.11;IPV:CAL;SCL:-1;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10019020)(39860400002)(136003)(376002)(396003)(346002)(2980300002)(189003)(199004)(103686004)(26005)(6246003)(4326008)(2906002)(229853002)(75432002)(88552002)(476003)(486006)(186003)(126002)(4744005)(356004)(6266002)(47776003)(11346002)(2616005)(446003)(5660300002)(336012)(1076003)(42186006)(8936002)(8676002)(36756003)(97756001)(76176011)(58126008)(305945005)(246002)(106466001)(52956003)(86362001)(54906003)(33656002)(46406003)(90966002)(6916009)(23726003)(50466002)(478600001)(26826003)(106002)(316002)(36906005)(786003)(16586007);DIR:OUT;SFP:1102;SCL:1;SRVR:BL0PR01MB4850;H:outgoing.mit.edu;FPR:;SPF:Pass;LANG:en;PTR:outgoing-auth-1.mit.edu;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: d473da07-916d-4f71-dc24-08d6a0f14d2a
X-Microsoft-Antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060);SRVR:BL0PR01MB4850;
X-MS-TrafficTypeDiagnostic: BL0PR01MB4850:
X-LD-Processed: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b,ExtAddr
X-Microsoft-Exchange-Diagnostics:
	1;BL0PR01MB4850;20:3/bddI18WnM/WegNfL93VxXNZlFPqxLWv7V4Ee4A+etp/rWpgMSiTByFDr3/QVlC7/4jLVQJhsaJFcm7gVDwX5IXIy9tEQBwKZFQFNUHwj+BNNRe+T7NR4CukGjGs4J8lwGvR5wV+xlMesvS5T0FB+yHqP0mQ98F5gUaoKeEiUnS2py+arCMAJjIRMDc7Db2HBdjkryTak3+bHUCWOJ2wzUWggyOUPeeL39OMyPx0nPmxM1P/YPnGVxBD+YisVMzdR4br8v6J2OY4yiXCzuqZ4+j7BmtiVnyyS/CreSjecV8bYGCp95B4IJfLY4LLOrKCmTpEa6hSiU33v+Er80meWc3cHglOIZ9Koptjz/IUIyUmTf0JRXNrDM5CJoANE8kRFxREXrYxCDIeCfkJ0R7TdFxjt3SlOaLzVGlb6MFcZKSGrO/pGzfuTAUAcChu4NEPWSW4v+AQrLnDOr2RGwNrMHpo8yhCDT5C4MFKxxw6GcVIpPqZX6bP4LhDQ6lZa/djJpq7ChbwTIHKbdS4B5+fheImxDabZRrIb7UazNQXV68CbuMmqa3QCzzWCLNFegvvdETpl9AqHQasED/h4bUL4a1+1lqNpOVWXta3xjHoSM=
X-Microsoft-Antispam-PRVS:
	<BL0PR01MB4850B8827CEE7958CF76FA6EB5710@BL0PR01MB4850.prod.exchangelabs.com>
X-Forefront-PRVS: 09669DB681
X-Microsoft-Exchange-Diagnostics:
	=?us-ascii?Q?1;BL0PR01MB4850;23:4zhErKdINpePj06FPfGRhysWYQVsQC4dlQUH/khmI?=
 =?us-ascii?Q?jjf9B6dZWTFzWpP+ViMbiAZ3BZIJgmtRXVIALhsqsFYZ6CriPNkC8ovrY1Mp?=
 =?us-ascii?Q?Ek6jFi5WEsCc1QVY3tQgYb6czfom2on1/KYDNdLZbosi9Nn7gZbLYHVeIJhk?=
 =?us-ascii?Q?mXOHuYkmelQaBEQYngyt/7pVGEk093jSSvqzIZEOTJkkWMLLPI6aF08udBfA?=
 =?us-ascii?Q?jkqepqqUWsLSLFsK8T/x3qOvEsDW5nfNgCvSk8TwRcBfmnR/lMCJRpkXE0sp?=
 =?us-ascii?Q?6mNKRNDTpCVA+1WU3h2WMf5WyPhAuHn3q/J4Z6NFJL4B9mdpzVD5rCucHuvW?=
 =?us-ascii?Q?yOGQ5HBO85BCyClpfl9EM0UJnXhWzHwAbuFaMPDmy/Ys4SajcuBC5IsuwEHP?=
 =?us-ascii?Q?5MyhiMwI33Gty1z/gnCb+SQFIyq6F3ADr4gA1Fnuj5eseahxLCC+ETTgsNcs?=
 =?us-ascii?Q?qYd+zPnGhMFg9iNpGWOcUzrqKimQNPOgFwHFr1eGws6+zYMqQzB+eGibTTg2?=
 =?us-ascii?Q?cXkI13T4DNgig6WWUwUEBOmeI1/YtY/al/67+FEiltjPsBBdpjfz+cr+4sqr?=
 =?us-ascii?Q?RPPi/JUECIqR5MtqhCvZNkEIvSYkWbmWIglNZZ6E53+GYiOjDQ7tzRTSyOe+?=
 =?us-ascii?Q?6QwCJsGZhnpbrAA01gurhpWlcawJnz08qFSWkqgHKxiAitZcIkjQqMMEG6Mi?=
 =?us-ascii?Q?hBeMB52ENvinqfzoKnLKfDmmugLiBI1K49jRC1I+4kig1/PjfMx8X7IdUpwq?=
 =?us-ascii?Q?aL4ihdwIp67Y/2PkoDrQfcz+1l9dapp/COVaVJWBayTwYNLb/j5Sjl6wjRVF?=
 =?us-ascii?Q?F4hGzt4UJ3fsSLwy8qOT52jc7C48GTsFDLa7DoTUJ/gPF7dA/zE5a/4uQgz5?=
 =?us-ascii?Q?aEWx2isrj7eK8X/q5789CWGnQSCljmMGCD/DHeqiSarq6iRpwOTXwQes7pSL?=
 =?us-ascii?Q?ohjQy1hLVidFoI2zqg7XC650N1LdkbAiiExAKmLhxP4YxGJbHu6JRLxJFCPq?=
 =?us-ascii?Q?o3+WwLP0ZvJwgmhUxR18VL20nw2Y8bDIyqBlG4QSxK1tirQuBU+UtTdF9ICI?=
 =?us-ascii?Q?sD/YgfILJqnxEVj4Vvf4gT+1qhkmht4SYtC5lqEdK3T+uxKFXt7ENJTs1++J?=
 =?us-ascii?Q?GDzVdMaHFEwA8TaKY9QA88lcHvQXHTPSdmYDCK8h5binElpkSAbOkJPKw52/?=
 =?us-ascii?Q?WMPdV+iMOXw9iFq5ImiEeJT2XeJAHWY9yshyi86Rvzy2jZuGiGFxvjQWg=3D?=
 =?us-ascii?Q?=3D?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	0+pLxUYkT8adkPkzkUyLMgZRA7FupRw4RsvoNZySYZT6sWuiiWNXhFoaq1NLeABNyenDYNnjOxDXEwp9doqHjM0dmW3da9BehQEbYoJcvA+UZV3DQ2HXJec+0sd5vyWr/1oPYjkdErSvGnCpEjAMZKhQWJv/EpO6uo4Qe7baIZdzp6stZ3j/mAtFPwnENH9MPpale5Ng3cXSdy/hWONWYZ0ael9dQvj1F1H+EayA6QzKg0yL4k9hP6X8aUOE2FyBOo48agtgQgVqx5UvpNTmKQdIh8dV90YqIakWj1YNv2zzMwnqbNpgJhEBemnJY1F6TxDugnFOkCFkzb7drkoiRd/X209mZxGmQyZwJq6rAUr3RFgFNtp3AaFNAVpyQ/bSRWidUJpOuH85Y7CqAGWdShV+S2Q+h6AMrtkWYJk1CKs=
X-OriginatorOrg: mit.edu
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 04 Mar 2019 22:32:35.8498
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: d473da07-916d-4f71-dc24-08d6a0f14d2a
X-MS-Exchange-CrossTenant-Id: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=64afd9ba-0ecf-4acf-bc36-935f6235ba8b;Ip=[18.9.28.11];Helo=[outgoing.mit.edu]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL0PR01MB4850
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Adding linux-mm and moving linux-ext4 and linux-kernel to the bcc
list...)

On Mon, Mar 04, 2019 at 05:02:55PM +0100, Pavel Machek wrote:
> 
> This happened on trying to sync filesystems with unison:
> 
> Any ideas?
> 
> Should I be forcing fsck soon?
> 								Pavel
> 
> [12717.827444] ------------[ cut here ]------------
> [12717.827465] kernel BUG at fs/inode.c:513!

It seems unlikely that fsck is going to help.  The BUG_ON in question
appears to be:

	BUG_ON(inode->i_data.nrexceptional);

This is an in-memory accounting variable which seems to be related to
tracking DAX and shadow page entries --- and it seems very unlikely to
be the sort of thing triggered by an on-disk corruption.

Do you have a reliable repro for this?  If so, the next step would be
to bisect...

					- Ted

