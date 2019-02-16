Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34F2DC10F00
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 18:28:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0B6F222E6
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 18:28:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mit.edu header.i=@mit.edu header.b="QHCtm45T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B6F222E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F4B58E0002; Sat, 16 Feb 2019 13:28:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CBB18E0001; Sat, 16 Feb 2019 13:28:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094508E0002; Sat, 16 Feb 2019 13:28:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8C4B8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 13:28:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x47so5224563eda.8
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 10:28:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=o3jWc0TlZfxsex/IIVq4IitiFbLVH0HYFCCn1AFy1vY=;
        b=bryl0u/rERz7MubN+9vdysmlh2GlRNnWWrIqJun79brtJR+DBTnkEYjkH0ol51xFg0
         A6lYHmkH/XVPqu9o2pFOjYl/mVI5Qyeip/tV662GfGBxRHIthoMV0HXSwVmQ1+j6WzND
         /vODxoZPF7zBhVUCvcZbO3BbGuxmVcwNmbuiOJAoZva6nRv0znUYW8ifAFpj8R/814OP
         J1MP4UmyHTZoFrT9rJ0Z4pV7/OlA/+dVIneaPAQfnhPHXry3Q5FeK3Wun8N79m5ionok
         8jQIeCxJ/mSOOdTsGX8KxVk2MuNVsyu82qwTNRaTzaFO7T+brkdNQfIyzmfRtZCBLGvV
         efGg==
X-Gm-Message-State: AHQUAuZsV8DOtZmGyrfR6drvE7fYkFRr4Qi7QVcw5x3IeRa3UUrukDtY
	UCSCyx+RHLlmeONEuLAmfAKWl4k3YpaDnVovkcFSPQlTWLcTX7eFZwL318hZvP6KKJS2/kvtFiN
	kkjz+2Enf4zndYrqfahptM3MrOD5gKscdxCPzMCPrteES3uuGbfJpiSeWpd/A/I+GHg==
X-Received: by 2002:a17:906:3759:: with SMTP id e25mr5743086ejc.69.1550341725100;
        Sat, 16 Feb 2019 10:28:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYYeL4lL6DZBuvUK4o39bIuE3XldqSqV6erdwU6MkhBpD7+Z8iiR+BM3ONzax3zCjynAvoc
X-Received: by 2002:a17:906:3759:: with SMTP id e25mr5743046ejc.69.1550341724121;
        Sat, 16 Feb 2019 10:28:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550341724; cv=none;
        d=google.com; s=arc-20160816;
        b=hMdBqAKttMCNthxRfesTOKmw2ZWqQ8K2bUBV0yEgh1uuNIdBT2SDHz73KQBdQEVrQb
         YSRwJhQnr4vi7i/asGrcicMCWyFCJXwZH9LuulzqsWuqLCsCxp5Y3qNvBn9dwJG4Fdu1
         m8vCc3eiYuhmzO/4UVKJWHta2JKpvYEOrcdgjSPdhVtaukrJPvVIZmVY/55aqcgnnKsr
         pcMr+CUMhODpK3oiBevh7g5DTt6x9YD+RHxFjJDHpQqqXouArpdf7JZxYE9MSSC3iOsP
         58KYlFYhCbFQxK3bBzxE1GhbptmBPB/567pzpPnh2SEtgRQN5k6cnP2zdzq/35rUNcl1
         vohw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=o3jWc0TlZfxsex/IIVq4IitiFbLVH0HYFCCn1AFy1vY=;
        b=JTanPHWfSO4ZwtYhphPIRDK8jZSaLNffNLvhUBZp8qKgcHRoorStZk+X5eYJHRLTz0
         pBAnoZ8uZsbDibYO0+Pra66nmUOH2zG83b+jpEy3E30ok7ugTNeFTLnF3fzrN9cNPVxo
         6lLrPt50+mpTA5jFy34ut8ipAVOKjMxEfJcasTQpX4yCXUdbQPNPpHT38HCLGc4hV1/Q
         5A89ii4vZ0XvbNgrFzWVBxOinmpvBFpCLBjHfgMF0FLlHOUwaUr0z0pXAoHRTu5qYbDE
         v6vfNHj/pc/dUGRhQ8b2gtXFAS0AsynKWwYjAsdqkcBD06a4kGj0ul7xX321oIxJMpkY
         6H4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=QHCtm45T;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.70.96 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700096.outbound.protection.outlook.com. [40.107.70.96])
        by mx.google.com with ESMTPS id g3si3221171eje.216.2019.02.16.10.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Feb 2019 10:28:44 -0800 (PST)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 40.107.70.96 as permitted sender) client-ip=40.107.70.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=QHCtm45T;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.70.96 as permitted sender) smtp.mailfrom=tytso@mit.edu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=o3jWc0TlZfxsex/IIVq4IitiFbLVH0HYFCCn1AFy1vY=;
 b=QHCtm45TyKXrpXzRZxNaCBq8Z0FmTnbEAiDNZ7KO77RkX8+BamkFjNKBoltlu903BAjcKdrbgNN1GQAZ9CyRs9WkuIBneDA54bm5XhTln9E2tjKQO9b6KzjnAPMVAVGwcBI8K+/BibDC2Nfx+IU40lv2FPt6CYW3VBf4FWHU6E8=
Received: from MWHPR01CA0047.prod.exchangelabs.com (2603:10b6:300:101::33) by
 SN6PR01MB4861.prod.exchangelabs.com (2603:10b6:805:d8::20) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Sat, 16 Feb 2019 18:28:40 +0000
Received: from BY2NAM03FT006.eop-NAM03.prod.protection.outlook.com
 (2a01:111:f400:7e4a::203) by MWHPR01CA0047.outlook.office365.com
 (2603:10b6:300:101::33) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1622.16 via Frontend
 Transport; Sat, 16 Feb 2019 18:28:40 +0000
Authentication-Results: spf=pass (sender IP is 18.9.28.11)
 smtp.mailfrom=mit.edu; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=mit.edu;
Received-SPF: Pass (protection.outlook.com: domain of mit.edu designates
 18.9.28.11 as permitted sender) receiver=protection.outlook.com;
 client-ip=18.9.28.11; helo=outgoing.mit.edu;
Received: from outgoing.mit.edu (18.9.28.11) by
 BY2NAM03FT006.mail.protection.outlook.com (10.152.84.100) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1580.10 via Frontend Transport; Sat, 16 Feb 2019 18:28:39 +0000
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x1GISZct005659
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Sat, 16 Feb 2019 13:28:36 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id B0A087A5779; Sat, 16 Feb 2019 13:28:35 -0500 (EST)
Date: Sat, 16 Feb 2019 13:28:35 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
CC: Sasha Levin <sashal@kernel.org>, Greg KH <gregkh@linuxfoundation.org>,
	Amir Goldstein <amir73il@gmail.com>, Steve French <smfrench@gmail.com>,
	<lsf-pc@lists.linux-foundation.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190216182835.GF23000@mit.edu>
Mail-Followup-To: "Theodore Y. Ts'o" <tytso@mit.edu>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Sasha Levin <sashal@kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>
References: <CAH2r5mviqHxaXg5mtVe30s2OTiPW2ZYa9+wPajjzz3VOarAUfw@mail.gmail.com>
 <CAOQ4uxjMYWJPF8wFF_7J7yy7KCdGd8mZChfQc5GzNDcfqA7UAA@mail.gmail.com>
 <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <1550088875.2871.21.camel@HansenPartnership.com>
 <20190215015020.GJ69686@sasha-vm>
 <1550198902.2802.12.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1550198902.2802.12.camel@HansenPartnership.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-EOPAttributedMessage: 0
X-Forefront-Antispam-Report:
	CIP:18.9.28.11;IPV:CAL;SCL:-1;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10019020)(396003)(39860400002)(136003)(376002)(346002)(2980300002)(189003)(199004)(76176011)(356004)(26826003)(90966002)(786003)(36906005)(316002)(75432002)(42186006)(1076003)(93886005)(478600001)(46406003)(33656002)(58126008)(16586007)(229853002)(106466001)(54906003)(47776003)(88552002)(2906002)(50466002)(23726003)(14444005)(11346002)(446003)(126002)(2616005)(103686004)(476003)(106002)(486006)(26005)(336012)(6246003)(6266002)(4326008)(186003)(7416002)(36756003)(52956003)(6916009)(97756001)(86362001)(305945005)(8936002)(8676002)(5660300002)(246002)(18370500001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR01MB4861;H:outgoing.mit.edu;FPR:;SPF:Pass;LANG:en;PTR:outgoing-auth-1.mit.edu;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 8ed7cacc-2342-45d0-466a-08d6943c92e8
X-Microsoft-Antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060);SRVR:SN6PR01MB4861;
X-MS-TrafficTypeDiagnostic: SN6PR01MB4861:
X-LD-Processed: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b,ExtAddr
X-Microsoft-Exchange-Diagnostics:
	1;SN6PR01MB4861;20:ueY9ZOD/gXvrb2e1UMfF0y1XIjjNA/H8Ekm5zZUimBBsd1huTW+ZOgwnPKu1r4BmqmDiQ/We7qmJ3TF1MNCpTV3i/iBLQxhlk6BpOBKbujzi3Oo0ld6CbLc2JT8sZfSCg202Ptpf0rXkTQ64lM6MnwgjE67towk2XFX+prtx6WDIuE8KMRWE+knfpbt7Bb3TUxfqJBC6u6p6qDLSTMkH/6Q+IzXqsqjwSRqYNEv34tXF+XwM6SbqnB9BcQ5S/ZNhfxuGifcRsTE2JnF0jxq94KX9L7oK/U+VEz73IfGcpLALhFXKdXVMSuNrMOmnTy2WVeTpN/sNve2xnFavzm/mOje7qRhVjc+i1qSGWEqZx0hrzfTq/oCUCJ/gq1nI9O/E5WTiSE5D4Ji7rTwQkwnLwo23G3KMjldSbgFGfiF5V39Ar3xuMOHZUZB0D0QFcIgU9YRfuXKmRVZ7CzvX/CjS7lbXoDlR6ImxKIYBygnUWdjkl9o5yT5k/z1TMgAK7TpIPyYmayM0vtoBTd1/jw2gwWtGr7lQ/IExPAvsIp6mqJ8m2Cuugk193kVK0hQJt2oTO9rgujVboix6fsF2F1CQel6iY4CZrVc1XNCYEgs/u2c=
X-Microsoft-Antispam-PRVS:
	<SN6PR01MB4861663437775A896D23C603B5610@SN6PR01MB4861.prod.exchangelabs.com>
X-Forefront-PRVS: 0950706AC1
X-Microsoft-Exchange-Diagnostics:
	=?us-ascii?Q?1;SN6PR01MB4861;23:UmrAUhT7DiITxiXc/tswO4NbOkrDVPEGg2vmTHI7Q?=
 =?us-ascii?Q?dBeUS7OyXdzO+K1rjmg1hmXdd08Idtw2ua1uTQ3FCIhRZLghsnqgFWEg3+VX?=
 =?us-ascii?Q?3ytzCV8mhR1BLm49NDh0Ov1COuonBeDMk5/HxqDzJ+cc8UeK913ReR16aFGm?=
 =?us-ascii?Q?KhmkNCRItmyNDypWYR8za3zDAUm/1ahdnLTY+AIQ3BsFObGhmQ64bD9JFeO2?=
 =?us-ascii?Q?JkXrPhQXCF0tGj+vA8rFzieqshRMbmrBEhC7az06j2+HJQ+b6tcECI/B6ePf?=
 =?us-ascii?Q?VSRD6hoepGZOhrGjm7XnrQ0jHv7yApkWl99CMN1PfB7oJnqE/SYTZRP9gGZA?=
 =?us-ascii?Q?bt9JOQt6YkqH1wXuMWjPnbsew4lL8iLnE7/L+0GcXnppuInAz4ho3hpo82qH?=
 =?us-ascii?Q?NL4j62OfIAgsNu50PsU+YXpY1SOtARG4IVFB3eBxIr/u2dvmEB93RMJOBuHY?=
 =?us-ascii?Q?lXtiaUdwYCLHjAamMZJDJysWmjuXQtM+QoK/YJogFdxUTBzxyQtVLD7ME+0v?=
 =?us-ascii?Q?/xEAJHIJxA9idAP6NyaDVY6K5MmZnDB7BMA733CaLMtqAeKgdWomUtjmrLJ1?=
 =?us-ascii?Q?rTO+0pqNRF83JkE/iMRORgcj7C8c3Di7AU/rlXdl9w76qy0vtnmn3edp8JZw?=
 =?us-ascii?Q?zAQvR8WyPhI9NKHnPQhD/9zz9bLYZyntOxLe7qhDYL3A4uB0KJrPY6jjqZvP?=
 =?us-ascii?Q?nBXmcUlfMdLJNLoU418f+K67oduDnLXHwMGWDB27VDxNruKQsYUMRyVK9TmD?=
 =?us-ascii?Q?PgGe/gmlxLmVpGGQlM3pDo/0yd34JdY9AneoSAnWKrPBSQgyk5IW9yKZ6K0+?=
 =?us-ascii?Q?+oFU6mVfGjNgKo1VhqVTyq8LfrmyFU4BnS6ArE7H2eGWjz8aNz5DdKVorSyx?=
 =?us-ascii?Q?rkCKlZ89A3OqzQF2flAUE8OuBJHCbSj887BWmx+CNQ+lHOodVb8BH9bO95aX?=
 =?us-ascii?Q?V6rd79C6gOWXWTCjHsRIcf3Tl3sWr6yQCo7ipYcdjbEPa5xuYuK/cIn1jtqx?=
 =?us-ascii?Q?KWSP0a+7hGPVip7trYZLBL0eTJPIwyyidStUVhMXiyc1ZRkOU3noPxSTNZjR?=
 =?us-ascii?Q?wcgTsCIeYEzCSMAVD0k4+ztqMMw9QoLRHARvl1u+2Kdte/vpIj1gB0moCiYO?=
 =?us-ascii?Q?GRNh5HDaFR00mMfrxNOX/4hmtd6y0TDHamUxCUW2FYh41zAkelTzBwDv5bvW?=
 =?us-ascii?Q?DhKysm78oIUYWcEg+PvNBbdDzfRUMy7EJ/cwrqtL+gmkxNAgNt9qrYDYw/fu?=
 =?us-ascii?Q?MMEOAx7XAZQH0xyucsXi9e81N7lcDNqHk0ooYcsbfRevbTW5wwdnE2ce5St9?=
 =?us-ascii?B?UT09?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	qvPzD2ZBLabAEF0eOHxYgT2yFv3dp3SsJipU+gom6LALcWgjxIRpJfZPATG0pGIa0VvF/o9ZrN2G6qwKxTS/2as95pctkd/DbwfteZcWXQ7fb3dmHrMuLEma9KIgNWOD8NMVcz+bySdyPV16xl4qqdYEWX36YEzz5G9J3fUL+DNbdFmKrj0pIhnxzcHxeduIwMavUVPsy+LRi1z6IjwFiJYRov7dr6TcWhB6Usq0m210O5AvgL9m7u5iTvngCp4zl0B3xziYxhBHWL2xY/5ANdhJ9xxOLIhN4s5u+jhqij+y/WXemD1PXi5aZYf9ii/O600UILTOUHE/jUU6WTz9zaJn9AGieoNZYUci4Jp4PGr5h/N4qvuHSPoHl7aUHEnMpIB9avaZEBJWQO16/LtM8zw1+4WnJaTjbTHpl0zdErM=
X-OriginatorOrg: mit.edu
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 16 Feb 2019 18:28:39.9125
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 8ed7cacc-2342-45d0-466a-08d6943c92e8
X-MS-Exchange-CrossTenant-Id: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=64afd9ba-0ecf-4acf-bc36-935f6235ba8b;Ip=[18.9.28.11];Helo=[outgoing.mit.edu]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR01MB4861
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 06:48:22PM -0800, James Bottomley wrote:
> Well, we differ on the value of running regression tests, then.  The
> whole point of a test infrastructure is that it's simple to run 'make
> check' in autoconf parlance.  xfstests does provide a useful baseline
> set of regression tests.  However, since my goal is primarily to detect
> problems in the storage path rather than the filesystem, the utility is
> exercising that path, although I fully appreciate that filesystem
> regression tests aren't going to catch every SCSI issue, they do
> provide some level of assurance against bugs.
> 
> Hopefully we can switch over to blktests when it's ready, but in the
> meantime xfstests is way better than nothing.

blktests isn't yet comprehensive, but I think there's value in running
blktests as well as xfstests.  I've been integrating blktests into
{kvm,gce}-xfstets because if the problem is caused to some regression
introduced in the block layer, I'm not wasting time trying to figure
out if it's caused by the block layer or not.  It won't catch
everything, but at least it has some value...

The block/*, loop/* and scsi/* tests in blktests do seem to be in
pretty good shape.  The nvme, nvmeof, and srp tests are *definitely*
not as mature.

				- Ted

