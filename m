Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2488C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 09:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15EE420818
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 09:53:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="yHvqlUNR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15EE420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 756828E0003; Sun,  3 Mar 2019 04:53:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 706AA8E0001; Sun,  3 Mar 2019 04:53:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57F878E0003; Sun,  3 Mar 2019 04:53:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 037328E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 04:53:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o9so1204374edh.10
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 01:53:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qKla7ajTc5yB6+x/0Wo3/YSLiuf0G3cDL8t8DZs4SUU=;
        b=o3cAxLQP8qpTudQBBGchI8jzqeW1UDgIlRxcEo9DiyKJ3YV/SeTQuKOdLGf/CxrB48
         A3Y/BY8MbKMY+1Jx1aVa+ajsTAFnQp5uWL5SHoeXhpo+cS564PEFCMMcghywb7d8uhnc
         fPEszu4atPRWbmZi4pBLU3TkqNizFfnriA7FBiQ9UjsPB5rfiUyduzO9N0eR7JuVFJx4
         pk2JK7FfFUO1lsFhgQ0j5nviftUwruwB59dhY4GQTicQ1/J1X90wPc0YKjL5iG3OfLwp
         D5A2pO+5jILruGMxI+TcJNxPaXd0kKQ9vRT2hOuGH+sOWiWqNA9Y7FfKvf6gqtdxbRkq
         bJLQ==
X-Gm-Message-State: APjAAAXAkGmP2lkJ+XnUWKwGBBjbxFhgQoBK59cCh2iTWuVRti69d67/
	05curJBusFi0z6VqWw0J4s9LMUHasnoBTIfv1HctHj8KM9Gv5PFuiL4GIAlM0fzT8rVDYhu4LYi
	mxRBD3CSEmkyySBDwff6IV7yAxpLV22GydOYdpyupH0LPUiE7EVVgcszriC5cPW1f7g==
X-Received: by 2002:a50:b36b:: with SMTP id r40mr11479307edd.12.1551606811485;
        Sun, 03 Mar 2019 01:53:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqxub8MUgocgPFOjAGw0g4c56UKQEyCQZlFhj/+CWiGW3wCtXNnNr3wFUiOhRpX1WyX423mn
X-Received: by 2002:a50:b36b:: with SMTP id r40mr11479272edd.12.1551606810586;
        Sun, 03 Mar 2019 01:53:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551606810; cv=none;
        d=google.com; s=arc-20160816;
        b=ud7e2qFGkh1yRZfB3Xu8+Hm048iYAmH0Qd1p+Ip7TSbc4gwO/DAK3aRWSaLNoEvuZ4
         doABDVthoKqGSthhpTF/xqyrdpIOaF+0QSzizPxC46yU4mlsp+6VIZOvIwbtoAvMzYsK
         Y3Z4QA4Wc4XM4ezmRSIJMi124byUeU8RvD+ODFXsAIoNt7sgaqX6Au5P023XurrPuwrF
         HKtH6cBOL3E+ORqiQkaxo8rr1yAj8PWvKe7thzdcIBTQUSWXZp2BbAtZZ3z2i24V+rI8
         rnpRqNfSsUcosvZ8FCvyLJ95VJ0sU3GLxLwZiQooSXzmQw9mLoDN23a83Eb9S8zREbip
         s9TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=qKla7ajTc5yB6+x/0Wo3/YSLiuf0G3cDL8t8DZs4SUU=;
        b=WwFTzEtP+PfZzgw47pIOSkiaUl3Kd/ptdPL2U6TWlcP5gl/+7qi3j7Fl0Ivyv/lM9S
         7xCkYTy64e0UKVeuWrznMvb0XqECtq3z/oEdg8xJhZbgqjJdHpxD27/T2YwZKfHnv9DB
         2smNDFLE+GTbsyeTrs8aQqnnbxLS2LkXGqkuhDwNTwWpwVEYzCpTt9QG625i7wNWD0mD
         bH6DWeDJfA9QoFnbZbj5nw5VGVpDe7zpqopuDyzOa70OE5H5NT2JKeL2vby9tegZHRdh
         GuYwvbqT+JtYPiH9tYrH/LygP67vw2JXuvmFjptzv5TkS5sJ6/OuVa9F83wRafBvNDBS
         53Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=yHvqlUNR;
       spf=pass (google.com: domain of artemyko@mellanox.com designates 40.107.0.63 as permitted sender) smtp.mailfrom=artemyko@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00063.outbound.protection.outlook.com. [40.107.0.63])
        by mx.google.com with ESMTPS id b21si1195789edc.156.2019.03.03.01.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 01:53:30 -0800 (PST)
Received-SPF: pass (google.com: domain of artemyko@mellanox.com designates 40.107.0.63 as permitted sender) client-ip=40.107.0.63;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=yHvqlUNR;
       spf=pass (google.com: domain of artemyko@mellanox.com designates 40.107.0.63 as permitted sender) smtp.mailfrom=artemyko@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qKla7ajTc5yB6+x/0Wo3/YSLiuf0G3cDL8t8DZs4SUU=;
 b=yHvqlUNRWtPUkt9143w6K+O2v+YaMDd2nTdW3tqNXAzRy3GUJ6LDbtq6+fZ3MmnVeLyBZneZFMaq16M7e8qlQOojAx4Put0DOpty0ERZQdyYpk5+ly2Dz9H7TpPpVa8/UYW0aqdHaPNSW0vuEsdx7TPAhNTChz2A7zRGayp5thU=
Received: from DB6PR0501CA0008.eurprd05.prod.outlook.com (2603:10a6:4:8f::18)
 by DB6PR0501MB2631.eurprd05.prod.outlook.com (2603:10a6:4:8c::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1665.16; Sun, 3 Mar
 2019 09:53:27 +0000
Received: from DB5EUR03FT006.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e0a::207) by DB6PR0501CA0008.outlook.office365.com
 (2603:10a6:4:8f::18) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1665.16 via Frontend
 Transport; Sun, 3 Mar 2019 09:53:27 +0000
Authentication-Results: spf=pass (sender IP is 193.47.165.134)
 smtp.mailfrom=mellanox.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=pass action=none
 header.from=mellanox.com;
Received-SPF: Pass (protection.outlook.com: domain of mellanox.com designates
 193.47.165.134 as permitted sender) receiver=protection.outlook.com;
 client-ip=193.47.165.134; helo=mtlcas13.mtl.com;
Received: from mtlcas13.mtl.com (193.47.165.134) by
 DB5EUR03FT006.mail.protection.outlook.com (10.152.20.106) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1643.11 via Frontend Transport; Sun, 3 Mar 2019 09:53:27 +0000
Received: from MTLCAS13.mtl.com (10.0.8.78) by mtlcas13.mtl.com (10.0.8.78)
 with Microsoft SMTP Server (TLS) id 15.0.1178.4; Sun, 3 Mar 2019 11:53:26
 +0200
Received: from MTLCAS01.mtl.com (10.0.8.71) by MTLCAS13.mtl.com (10.0.8.78)
 with Microsoft SMTP Server (TLS) id 15.0.1178.4 via Frontend Transport; Sun,
 3 Mar 2019 11:53:26 +0200
Received: from [10.223.3.154] (10.223.3.154) by MTLCAS01.mtl.com (10.0.8.71)
 with Microsoft SMTP Server (TLS) id 14.3.301.0; Sun, 3 Mar 2019 11:53:24
 +0200
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: Ira Weiny <ira.weiny@intel.com>, "john.hubbard@gmail.com"
	<john.hubbard@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "John
 Hubbard" <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford
	<dledford@redhat.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
From: Artemy Kovalyov <artemyko@mellanox.com>
Message-ID: <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
Date: Sun, 3 Mar 2019 11:52:41 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.223.3.154]
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:193.47.165.134;IPV:NLI;CTRY:IL;EFV:NLI;SFV:NSPM;SFS:(10009020)(376002)(346002)(39860400002)(136003)(396003)(2980300002)(199004)(189003)(77096007)(26005)(8936002)(86362001)(81156014)(53546011)(81166006)(8676002)(31696002)(2906002)(65826007)(186003)(76176011)(230700001)(4326008)(47776003)(6246003)(65956001)(16526019)(3846002)(6116002)(6666004)(65806001)(356004)(58126008)(110136005)(23676004)(2486003)(106002)(54906003)(36756003)(16576012)(67846002)(50466002)(106466001)(336012)(2501003)(305945005)(7736002)(316002)(64126003)(476003)(126002)(486006)(11346002)(5660300002)(446003)(2616005)(31686004)(14444005)(229853002)(478600001)(3940600001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB6PR0501MB2631;H:mtlcas13.mtl.com;FPR:;SPF:Pass;LANG:en;PTR:mail13.mellanox.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 078ea771-00ee-484f-1613-08d69fbe15a1
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060)(7193020);SRVR:DB6PR0501MB2631;
X-MS-TrafficTypeDiagnostic: DB6PR0501MB2631:
X-Microsoft-Exchange-Diagnostics:
	1;DB6PR0501MB2631;20:tXDChfSYsZbIR8W+OsxCZ2t4Al6C5VLIzUtAXA9U74C4vwyc+GFd0sxK9y7rzvvy3XNggVnTT2txmVA9my4FkyMjh3kuRj2IJMMXjgv+LGfxyUCRd3eHEcJ5g8y9ERjpLSzRk3Rjzu6/AmH7ui4UYIxZDjBjW7zK5UyhumlcMpAFvHos9wN7eiTuG020ll7twi354uNmiN3Je0wtQQLWqAWJXdte/fvs36drZUhdeE6UD+vU0Koqeo3n9C/OIAsuyGH06h4nica+B+zaLSZFqFriBEZlzIJlta15EwmVbJHnzdlncSdkaa+hxWi7uLGc5/8q8n3/x+3ToMjFx5Lx18U0Dup/m52uBojVDo8KVVRnReR2OtHD6eXs3HArsmj+Mg76DquYqZWWZKbJd+jkGiteQ2psoVLnRizyB11SFXmqj68UZ7JFbc5AF6hejlBbzc1La25o6RR8+Z/xUysB3oNnOjXh9bHF/3Ddo4Ywk2kj3XffpoF2FdKsKAHxTw+L
X-Microsoft-Antispam-PRVS:
	<DB6PR0501MB2631E2673D06A8BDEF08DF21B7700@DB6PR0501MB2631.eurprd05.prod.outlook.com>
X-Forefront-PRVS: 096507C068
X-Microsoft-Exchange-Diagnostics:
	=?utf-8?B?MTtEQjZQUjA1MDFNQjI2MzE7MjM6M2JSRmxaZEZ5ZlI0aTRrZ2FCVStkdHIr?=
 =?utf-8?B?RDl5ai9HRFZ2ajFJdExWRE9TdjQ2UldMdEhWZnVkNkNya1dJRmpuQXhmTmpB?=
 =?utf-8?B?ZVVBT01oRXcwZ2k1S1ZjdDB6aUFyaS9tQThBSDB6WCt6VDZBMGtOYkZqQzM0?=
 =?utf-8?B?YlpPYlpMbWRNNlpBR0lsalJvS3hmVDNiN1loSmxuM1V1dzZxL0xncVI0L0Nw?=
 =?utf-8?B?MEdFY2RvbEVWVVpQL1ZBUHNxMjBJSFhaQnJDYVBIMWxvdUZTQVN5NmV6L2xX?=
 =?utf-8?B?UEgxN0UwVVQzcmx5MkhVSTlyV1dpSm9NcEVnWURsUC91aVJRSVU3d3RCRVhu?=
 =?utf-8?B?MDdKeEowT0w3WmNFb0pqd2g1OVZ3dmN5RWFZMi9FNVB0OXVIWE5BdytTSjBn?=
 =?utf-8?B?OVA3MGtpS3ZGY2xNeTlrdDM1UlYva2NhU2JubWxvZk55eU9nald5RG1aRU5N?=
 =?utf-8?B?ZzI5ZU1GMkJKbDVDaVgraFlVeis5OGRVU2ZrZ0xVcm1melpLZTZCSm52WWRD?=
 =?utf-8?B?OEV1c2lVUDQvR1dyeHRHNHlybms4Sm8rL3dHU0JUbitzSlpKSm50cHlHckxm?=
 =?utf-8?B?OVNlTGFkcXJTRm5WbzI3WWN0ZnhZd2VEekd6cEZTb0NCTSsvbTdhR25LN1hS?=
 =?utf-8?B?QmxxQXk1NU95bkhKNUJmdFFjVVJabnpXa082UXUwbG02cHRQYXlCL0pJcDUv?=
 =?utf-8?B?N29kTFU3SmtSTk9NNlZjOFBVUS9TVi9ZUjhEc1ErNXdocG0wM3d1YWVtdzdZ?=
 =?utf-8?B?SnROZy9NcmZPajcxdGhVY0ZtMjdzb0FpQXMxUGZKOGlRMkFLZGRMbUdldkpm?=
 =?utf-8?B?QllVaEFoU0l3bnpZbi80Mzh1dGtMRjA2SFd4YlN3ay9KNXhnb2xEaWY5K0tI?=
 =?utf-8?B?VklZUFRBMkpZMCs4OStvQkpUd1dUa3hiTE1EZ1NLdUk3WW4xemdSL09ma2pU?=
 =?utf-8?B?K2dycktVMnNrdEl5R1NHL1RwM1UyWWRuZVhSMk1CVnhkbUppM0NwRHRFWXRv?=
 =?utf-8?B?Tkg0ZTk3NXR2UW8zNXg4bXA4YWRaTTZNcXB4UWF0b2w5dHBWSnRxRWdvNUhB?=
 =?utf-8?B?cG9veC9zalVKVkQ1OXF1Z3FJcW5wVlhtY05HMXVZcDJhK1QrV3oxZ1ZOcnV5?=
 =?utf-8?B?ak81UHRDWkJkeUIyOFdjRlNNanZTS2twVFVFblBiVUVsQkxHUVBhUFl5QVdm?=
 =?utf-8?B?a2F1N1VtaFg2UHAwb05FR1cwMDE5cXk1WEI5eXBrbEc5NjNyakFBcE5LOGtI?=
 =?utf-8?B?ZnRVNGt6U0I4OWNqcUJINjhIUk0wbUMxSjQrQ0sxYTFvbE9mRCtiVmxQdWRL?=
 =?utf-8?B?eHRkOHk4SDFqYjBWWFJwcEE4S2lqa0IvdXhqWkcyNVVUMVdISkxDSGVmY2NU?=
 =?utf-8?B?VS9Ba09TVEhzTjFQS1doU3pjeTdkOUtsQUp4ZWRUajJWRDl5cUE3em9BNWdn?=
 =?utf-8?B?VUZadGMvV25PUVZ3Y2V5RDdyajZiRXgzQlF3dzMwVTNVV0JTVGdUaTZtdm40?=
 =?utf-8?B?UGZFYW1wM0N2QS9BSHgvMGw2M1NkWXU2a1BiVEsrTG5MVFNxTUZzeTZpbjR3?=
 =?utf-8?B?TzV5Yit2VGFNeHBGaHZ2azFZZVlNbEhSUWVxc0F4YnFIbVVNaW1VVlRYdUZm?=
 =?utf-8?B?Y0hYdXBGczBFb3BTSUhFekRBcEM1STBPSU5ibnkrZXlKaWNiK2FYNU1SK3U5?=
 =?utf-8?B?bkpuMGYyT0c0alVwQVdVbEdPVUJmR0ZsaGtRc0hZQXYvbHZFVG1GM1BPNmR3?=
 =?utf-8?B?Uis3Mjl5NGtUTkVlQjNyQ0xjZHFTTkQ1S3BhK0QxV1d1OUp6VVQ5OWJsTkE0?=
 =?utf-8?Q?3x6OHtNYHBB/b9C?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	eBeEpP01KdR240Vh/zowf5wyUrmz7hiVtYcxJm1JPzMBgg1kLLlAgSfwv7m6suoNK1i7ou96AaI19CYteVaO0s7BJ7xzmBaH/aOCykjXoYgv4u8j3/PIEwQCfeT5nSRmYO7xEfMIxRl1GhVVWnutjIPshiv158yaD1Fay2eLTqt5dvakJi2ECOVeuroZXtLqJ+B+XvzBHsxJ5cYeilncylgP/JIytDF3GsZJhxnEblox2YPez7pHqDCr6f8SvmA3kmQT0CFQlR9BtBo3A2re2EXgC+sh+tZEBoGcNPQZ4YjvmYOI1MHyEmS/cQMLn/jqOnJoo9B53qPT8m5aAE6ZCc/mpmY/8+E/dfgSpRcqDBexLLefZ7cBXmK7S5GKtttxi1QobhDxzB6Lgf7qzRC0Rm+Q8ZyW6n/EjZEjfifb6k0=
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 03 Mar 2019 09:53:27.1596
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 078ea771-00ee-484f-1613-08d69fbe15a1
X-MS-Exchange-CrossTenant-Id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=a652971c-7d2e-4d9b-a6a4-d149256f461b;Ip=[193.47.165.134];Helo=[mtlcas13.mtl.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB6PR0501MB2631
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/03/2019 21:44, Ira Weiny wrote:
> 
> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> ...
>> 3. Dead code removal: the check for (user_virt & ~page_mask)
>> is checking for a condition that can never happen,
>> because earlier:
>>
>>      user_virt = user_virt & page_mask;
>>
>> ...so, remove that entire phrase.
>>
>>   
>>   		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
>>   		mutex_lock(&umem_odp->umem_mutex);
>>   		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
>> -			if (user_virt & ~page_mask) {
>> -				p += PAGE_SIZE;
>> -				if (page_to_phys(local_page_list[j]) != p) {
>> -					ret = -EFAULT;
>> -					break;
>> -				}
>> -				put_page(local_page_list[j]);
>> -				continue;
>> -			}
>> -
> 
> I think this is trying to account for compound pages. (ie page_mask could
> represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
> But putting the page in that case seems to be the wrong thing to do?
> 
> Yes this was added by Artemy[1] now cc'ed.

Right, this is for huge pages, please keep it.
put_page() needed to decrement refcount of the head page.

