Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DBD7C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:33:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E4FE20675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:33:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mit.edu header.i=@mit.edu header.b="s+SMx6MY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E4FE20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62C28E0003; Tue,  5 Mar 2019 16:33:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEA278E0001; Tue,  5 Mar 2019 16:33:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8C518E0003; Tue,  5 Mar 2019 16:33:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE728E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 16:33:54 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id f82so14905922ywb.6
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 13:33:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jUXD029kXzWcNYaxE3ZREQ2DV5W0a98pslnv7FCYIXs=;
        b=j6JA2fpkBHp2Ttg5732bQ98JxQoKpL3JnoYccx6PkrpuaPKXgBogl14TPCam/0Y67s
         mggEYmaDgYEDN79ebbW+ZRue21X7+GLHoJRWnpjutvZvVwct8cuVj3LTuCh0ZH3FdlZt
         CVAiu/fzBABqUrq/movelXLIzN0SHZkTGJXlx9Zpo22pDhFFq1KWJdUrsSjaPxqhHDqj
         a1QZtMzsQE9t/OO3hRbh2duthkfuJDDVM3qc+2AWl/BH1x0aMClMb+CVRLJrgW9Kakme
         cgdL13ueJlciLIHEX2hXSZbJn166mkB4TF+pb0p1L/HDMsxVcJPyLxoofdXSurW13b11
         mwlg==
X-Gm-Message-State: APjAAAUlDpZ7G+8KfLdJI7R0ZaCROu0Bq6jcSlh0GPndg8kg/s14RvXl
	L61NqcS3xKmsL6VzYRmTY3ah4Srn+kBjVR5WnQABqCGsPMHw5yBigflPJaI9gNRbF8sF7tPF9OH
	9tFGPJ63060iZ8gDEjkm4O+5+o2EDtgwpCKMm6TmfzRZxpWqg+iDTTPYz7eYryqjyjQ==
X-Received: by 2002:a0d:d245:: with SMTP id u66mr2868603ywd.256.1551821634377;
        Tue, 05 Mar 2019 13:33:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqyLCrD7bss+tcHVgo4JCwx3P6i2ynhTvIhig+yJss54LUB5a4X4nzeEubk5kWdQetV0VbMc
X-Received: by 2002:a0d:d245:: with SMTP id u66mr2868544ywd.256.1551821633387;
        Tue, 05 Mar 2019 13:33:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551821633; cv=none;
        d=google.com; s=arc-20160816;
        b=c+ZdR3HSNY/xkI5JW3y2ifX2pL3p/k4vTtUq+rMNCR+ZshMP/T26IFQ7R4gGKRBxbk
         YGxXVEKY9UJ+ewuXBZM8+MyviJGEkDVZeYH7f2ZIcWeMwVufP/D0bJpFtlxNEDBSpdy/
         imbxxMgLnBq4noXO+2WYVlA7+6WTKoclQBjW1IlVyOHXUYG4U0kIPcctFzBVedB3viEB
         mdiHlzG5QlHOiMjxU8hy/6QdThCZQCHG/p6wcaHr/yoqBiwbh5jgH6fHSrTcAo9mtNdU
         bmFSWmEcj1V+ZDbq7ww0c3RaW6PmiOGmNwCguoJd+s8tDlortLjSFNmw0dDQeVTy8/F4
         +h7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jUXD029kXzWcNYaxE3ZREQ2DV5W0a98pslnv7FCYIXs=;
        b=WYdZQHnEzBN+7Bb6ifomN5e+K0+kL71ARx2eQ9zHv662IDCTSSdSAYDaYIrmT8T2Wa
         veYpTCZcM4iw0wD9noaCrLm7mG/71ppk70RfFKNo8WSgjzpBAFuD6EI/nNJH+cYCkUh9
         n7rJn2uboU1SydIQ/Iy4WfL4iCLuaSwjHiyCIyuNOqUyBi9m9/0h4C8PKK+2lOSN8jBJ
         DKFcyrbTr6RntOP733gjKnEARumIS24TQrv3cHl8aKg2mvr7dZIEa2ATAZ0VToC8yjSQ
         CeAcmOCfvrYf4hm+cWBd+uL/V5VKnCPjE/E3b5iQ/dP4JgR8mtKCTIeMdqg/DVfyFeSz
         F50w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=s+SMx6MY;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.76.95 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760095.outbound.protection.outlook.com. [40.107.76.95])
        by mx.google.com with ESMTPS id e185si6083781ywa.355.2019.03.05.13.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Mar 2019 13:33:53 -0800 (PST)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 40.107.76.95 as permitted sender) client-ip=40.107.76.95;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=s+SMx6MY;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.76.95 as permitted sender) smtp.mailfrom=tytso@mit.edu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jUXD029kXzWcNYaxE3ZREQ2DV5W0a98pslnv7FCYIXs=;
 b=s+SMx6MY283LMd3CWuJuvxqokQeJxce+kGDBEzsJQdF4cNXLzID7FDfRaRMk3p8Zb/k6YCDofaEIOJSRflfQVIvHtD4aWq6v8nsjOelcucIDwQajuHkC2jU311G0bQmPTK5pCTa59TfgzCjHJypXmoRWxoLA4Tf1W8xG+09hT+E=
Received: from MWHPR01CA0031.prod.exchangelabs.com (2603:10b6:300:101::17) by
 DM6PR01MB4858.prod.exchangelabs.com (2603:10b6:5:6d::23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.19; Tue, 5 Mar 2019 21:33:51 +0000
Received: from BY2NAM03FT019.eop-NAM03.prod.protection.outlook.com
 (2a01:111:f400:7e4a::200) by MWHPR01CA0031.outlook.office365.com
 (2603:10b6:300:101::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1665.15 via Frontend
 Transport; Tue, 5 Mar 2019 21:33:51 +0000
Authentication-Results: spf=pass (sender IP is 18.9.28.11)
 smtp.mailfrom=mit.edu; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=mit.edu;
Received-SPF: Pass (protection.outlook.com: domain of mit.edu designates
 18.9.28.11 as permitted sender) receiver=protection.outlook.com;
 client-ip=18.9.28.11; helo=outgoing.mit.edu;
Received: from outgoing.mit.edu (18.9.28.11) by
 BY2NAM03FT019.mail.protection.outlook.com (10.152.84.221) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1643.13 via Frontend Transport; Tue, 5 Mar 2019 21:33:50 +0000
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x25LXmkC022697
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 5 Mar 2019 16:33:49 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 64E327A4218; Tue,  5 Mar 2019 16:33:48 -0500 (EST)
Date: Tue, 5 Mar 2019 16:33:48 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Pavel Machek <pavel@ucw.cz>
CC: <adilger.kernel@dilger.ca>, <jack@suse.cz>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: Re: 5.0.0-rc8-next-20190301+: kernel bug at fs/inode.c:513
Message-ID: <20190305213348.GC6323@mit.edu>
References: <20190304160255.GA6914@amd>
 <20190304223232.GA6323@mit.edu>
 <20190304231426.GA6191@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190304231426.GA6191@amd>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-EOPAttributedMessage: 0
X-Forefront-Antispam-Report:
	CIP:18.9.28.11;IPV:CAL;SCL:-1;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10019020)(136003)(396003)(376002)(39860400002)(346002)(2980300002)(199004)(189003)(36906005)(316002)(54906003)(47776003)(75432002)(1076003)(126002)(336012)(11346002)(6266002)(476003)(486006)(6246003)(58126008)(446003)(8936002)(5660300002)(14444005)(2616005)(52956003)(106466001)(4744005)(26005)(6916009)(229853002)(186003)(86362001)(356004)(26826003)(97756001)(246002)(103686004)(76176011)(4326008)(42186006)(88552002)(90966002)(786003)(33656002)(46406003)(50466002)(36756003)(106002)(16586007)(478600001)(305945005)(2906002)(8676002)(23726003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB4858;H:outgoing.mit.edu;FPR:;SPF:Pass;LANG:en;PTR:outgoing-auth-1.mit.edu;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 7feab0a0-72af-4be0-0af5-08d6a1b2428e
X-Microsoft-Antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060);SRVR:DM6PR01MB4858;
X-MS-TrafficTypeDiagnostic: DM6PR01MB4858:
X-LD-Processed: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b,ExtAddr
X-Microsoft-Exchange-Diagnostics:
	1;DM6PR01MB4858;20:mS6uTyHUqaBX0GcvgPK+3InywZnteRVfuwGdJFGgJCHgRUK2BlKCw8IigXNDdDweLOL/u7FgzPrN1OZke/D5WSHZIn2Zj/hEm9VOPK/9qkitKtMIieN9AWVsX7KclS0QHbyHTfjMO0opY9wlbG6Nb8oEIFLso8xxRP+H+FiEdATu3D809QmiYVDSGJXfkEhmAVb1hSysQKyXDJ2e+8GtjLMOjdVOAc+F7cCn2lPjO8Nu4quZDTXw2YrclFRwdGwgah+BGjAQGDt7FW9GtLSF7D0QBJobEzncGhhcZ1WuLgPgR5X96wjKadRIVu1ix25JsmO6qilUqNFnWI5H/6bLFGqRZwZfdCfg31YfI8Kigx/zmW3uo1BtbVeorCOpQsLzT6N25NV0Bq6WyOKMbOyaV3lZXO9W0ZvWv2yrU19aLu90AMYpb+dEW7PQxGAP2eS0YsoHdEb5BMuLzsISoWxRgAuyGSKJAcBy0nBYVZ8puJG8w+pmMhGVuaj4vJZKgt2PDXFmXX/NUcdXfivnaHnC+AykKEdXd1Fb9OBjnBsiJdM8n7ucG+auJY1bHf92kXsS9xVM6Fy5t4zBjaDE6n4ofmpTBtaZNeNDmIFML7gMltM=
X-Microsoft-Antispam-PRVS:
	<DM6PR01MB4858CE5EC1AB4D910970CE72B5720@DM6PR01MB4858.prod.exchangelabs.com>
X-Forefront-PRVS: 0967749BC1
X-Microsoft-Exchange-Diagnostics:
	=?us-ascii?Q?1;DM6PR01MB4858;23:he3ADG/2H5T4H7uhsCytC+ssbJHVBbcagrvj5p7oi?=
 =?us-ascii?Q?e+68V/IQd/pBdZ/ehRsXr8lYyzMCUwhSxw86ki0WXrNG1TXQ2FAzlGckFqIo?=
 =?us-ascii?Q?wh1FV/7aZ4/H4dZcTm+91HUqLIWUezUz9lA00eRIGNe+MiJytiCzVHdk3w43?=
 =?us-ascii?Q?CdPYG4+gkMqpDECPcRBjA5fCc/pLU0XWwMUFB7q7tUvc6h6tviLX4Es33KBx?=
 =?us-ascii?Q?ZaopvUFYRcCxwPNAMERNdqHpDHbGPNTJelDw3jED7NSyYYhYgcCqx/Q1KzTh?=
 =?us-ascii?Q?0BRXVJZNvCxaRlLJhECmaTdkTIQz3ld3bb0CYuI8xFShdHl91GclwjHMJKd5?=
 =?us-ascii?Q?Slul2PUe9qJa2o0BwamohS491tQvuWFy0QpgdRPPvClRKUa7krWt/ZwC9Ar5?=
 =?us-ascii?Q?tTo+QG6rN7zax8+lTNyOFRZRgZy6FN42nBe341wdtldyBRwhzgckAySvgm37?=
 =?us-ascii?Q?feG8FYbbWPy8/odKYCZJivD8dtgmKaTZOztPu1CopYWepQOmawpFN27tVv11?=
 =?us-ascii?Q?XyI13J/IfZ6nnGhMtF/FEo+v2PEMlYfslJwCHHX+to9D582N2m6NWpj75r5A?=
 =?us-ascii?Q?Us0WFu6sWMau4rURcMDaplkSG+dHpjJV1ztdyg+mUuJ/VuqNL71kkqDuokLU?=
 =?us-ascii?Q?QY/EEL5jHzqvlJPxfwPGlR7KFP3uvisEikxDNdk7QkrZemquyXE1G6QOunkA?=
 =?us-ascii?Q?NEn+wjXy5bYcWAkexKYwR+D3TxhqQzcpFFK9NcQGiesROlipPnonNs274Tj4?=
 =?us-ascii?Q?seUpNVBkQ1JTCHYTZogT1jxtMAbLCgw+Mc0IsRyqOqKKsKcmrtajQsDakEWe?=
 =?us-ascii?Q?yOcjftj2i3HShG4DuN3ci6aoIKSWrRUZiHa5bT6z/Ai6fiXaQwjk+0950vMn?=
 =?us-ascii?Q?3icW/97m7Iy2+SQW3xN8a2XpYz3Pm04SgJnDSDyuumftX31ibbWjDpi56mlk?=
 =?us-ascii?Q?OwNfKjnAJj+xjPamPlEqFt0cqaXZrti1wXNDSk+XBb9z2e1kI1yoTqfos5ap?=
 =?us-ascii?Q?KCl29Jl/XiadoST28SBg51VmZDb9+ShtWOYPp6txSAFsQhDWeM+6hfgGH741?=
 =?us-ascii?Q?bVIZEdFDMaEUKfDiR2rNjLK42X6cEyhUXUsiO+NZYD+4fMWQG0EEh6C1HtT4?=
 =?us-ascii?Q?Y+hHSauezyn5ITI/8eV3bDreKTsWswIZ6sr5npzwmeguwevFZVe6EdQ/tk3D?=
 =?us-ascii?Q?6fDIV1Vqy51Ly62XtxtfiBePMQF9vH6gJO+E3SEkcTpafQyiaW1PHWOxndZ3?=
 =?us-ascii?Q?u3vueM4Xsea8qobmDM=3D?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	C6m/EczGNsP9COj3+IKaueo1ry/QAQt+YD7gTvc3YSJTdaGiYDIpsOWFNcQvDcB8E/1JhjNazjj/TftPcLkZmmCQNkPBO0ubf8IGv4zGKQEY7esPD9DC/geKmxsovM4K7xzPVBa7wCRqHsicox0HuO/e8Cpi8V3Yj+rWkkJIZ9Qh2msYyNLvvaB93YyJudDSMM+NhpUfXlKAn7IxgxeLj4/NnH0Y/V7XJnpQG8mNOVpKmAQfdEKLMVdn9rnsMkH4DA4ySy5ctqCfJvYQIfevuOB01Rapg12vxZdqYPh8fk5Tt+DL/42h8KO0ceaQqgXc+cWy6vPQvMQErnBsqXwyBJbN/LS4J6Vs+W9juA9jEbFFXmXXenLD9wPwqkcQoDCxjVH/wt+dFKqaQ4k4ITdv+7AN2yoCBZecxR4elWqbOrU=
X-OriginatorOrg: mit.edu
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Mar 2019 21:33:50.7986
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 7feab0a0-72af-4be0-0af5-08d6a1b2428e
X-MS-Exchange-CrossTenant-Id: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=64afd9ba-0ecf-4acf-bc36-935f6235ba8b;Ip=[18.9.28.11];Helo=[outgoing.mit.edu]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB4858
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000045, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 12:14:26AM +0100, Pavel Machek wrote:
> Hi!
> 
> > (Adding linux-mm and moving linux-ext4 and linux-kernel to the bcc
> > list...)
> 
> Umm. So I ... bcc them too?

Nah, I bcc'ed them so that people on those lists would understand that
I had dropped them from thread because it probably isn't appropriate
to include them on the thread.

> > Do you have a reliable repro for this?  If so, the next step would be
> > to bisect...
> 
> It happened just once... so I don't yet know.
> 
> I'm not even sure what file was affected. unison was showing some kind
> of png from openstreetmap cache, but I could read it using md5sum just
> fine.
> 
> -next is normally pretty boring, but it seems to get pretty
> interesting around -final release...

OK, let's see if anyone else reports a similar failure.

    	      	 	     	 		  - Ted

