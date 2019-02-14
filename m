Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B07C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBDD9222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:56:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FRLmD30R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDD9222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529468E0002; Thu, 14 Feb 2019 05:56:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D73E8E0001; Thu, 14 Feb 2019 05:56:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39FC48E0002; Thu, 14 Feb 2019 05:56:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED1338E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:56:11 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so4062563plt.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:56:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=MnGiBnQN2atIOsmm2xtueuCS5wsVO8PurpyWe54oMEY=;
        b=M0FIzhLc5K65+t/u/DckYyRbCVGvA/7diNXug7lP2EmuQmrbEfbu4wDt0X08SCv/y4
         sBqr/LfdERgVC/1TQRsE8fSfIG7j1IZ73ImTDSdlDXGce9OM9XaKuy0dnheN0lmxUjO+
         CRhK1FKkkmWh0A/M5tkkBqSpmuLseJPLoXSeLUJhVxibsojGXWayjccmRbSnFIxy8VEe
         jyZ7GFzX5d0ss78DpNkGQ+rCTAimWS/QvS9vNmx03uSNdwY1loEo4e3kIAyYCXQ+ay2K
         bhZM6xbds4MDzBhpmzPXQ8x37SeJhOc5dfsfy+8qQmAZjfCHplUXIb17EE6RkK0DtnQv
         X95A==
X-Gm-Message-State: AHQUAubzkHeCc0d6cbyL/b27dLSxmlq6zmlDJJp8XVWJkxynKxNVzP0A
	iIHuzspKZvdNpOwKIhlMD9yLT8S02PrBU8gis83wKMNjAIEjCKGrccw7+p+GStIUuOFXL43kcfM
	2shHktgrXCDJgj2Blh8abUksU38Ag6hiHQQK9WucTdhh6dgiNyCVvA/8AQOOsI9nnpw==
X-Received: by 2002:a63:3548:: with SMTP id c69mr3228423pga.256.1550141771149;
        Thu, 14 Feb 2019 02:56:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6u+6WxmPd/Dq0A0IAWGH/GxxZ52ZyBBTirOpkO3nFdkoTxfuySlh9acxPt90gHJJm+y0e
X-Received: by 2002:a63:3548:: with SMTP id c69mr3228374pga.256.1550141770418;
        Thu, 14 Feb 2019 02:56:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550141770; cv=none;
        d=google.com; s=arc-20160816;
        b=yQvF5uVGlUtdktnOdXl5asGZ+/7OPa7mrsKDXo1d4iN4izxv6V5CzSjV1FKXcLOx11
         ahXapihKW4Vd1j35NKn8jm7OElPOIYf65cQNsxMQh1SEV5oR1TW0fJoWAMNnb+ckHpTo
         +erV76ifEHhLSHIrPnftIQ6kj6zu/skDbv3IwY7LSIJpHU4dxHerS9lVbHsSqMDI9Hf6
         MKxhlLil42V233TV+0wHrkXCcXXBfX9ybcQskj0/hL75FRO4p+Sxwj947CJqBDTBsCLh
         UPbzVOSxe543OdxCA6+y0kSiP0GHAtXkCHEiXTpZqiZLZs66j47BYRek4w9rcUboHQiV
         avVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=MnGiBnQN2atIOsmm2xtueuCS5wsVO8PurpyWe54oMEY=;
        b=sXrlws+Bv3ILxRo7hq3y0mI2jbN+6sDmx/EQJmSoIKvltEo15Tpb6LpIIIPeCVFubY
         IEQAtp/PFTrY/4vv6L4hizUvgDEYiih18e84QYtVdOfCnGaGutfFVDSODWl2pP4xIj+n
         AS34kJJpeBzuCLYYSd0s9VX+U1u9qgFwsxW3W1VhvHA6vGoniujl7NMcdRIrbZLhvMPK
         W/vUqjHf8wXHVC/MNfqA2N4AQn7oddr6iU7T/QMeWG5QrlKjbIGzXPIDyggbYD1TY8H2
         6l/UGydexNsPbEOXrKc5HcDxZQeinBHRF8/XMAsmgA5E4LAQEI7jGQrU04mwTlmkP9GH
         9dxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FRLmD30R;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w8si2102004plz.37.2019.02.14.02.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:56:10 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FRLmD30R;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EAn0os187554;
	Thu, 14 Feb 2019 10:56:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=MnGiBnQN2atIOsmm2xtueuCS5wsVO8PurpyWe54oMEY=;
 b=FRLmD30RcQReYecFBxI9oMI/5aXV+duA4KBSBunkGGhGpFqeMB40KJIMWKgRqzg5rOmW
 8XyR3cjW2FGQARhFEshHXsJVbTrwVCbiXGHWwRexsHc1y/2/s6B32pG/xw8yN588TRDK
 MsRJZlIEiWfy46c8yn2OgjZuGcvVyHCrvGtmmGNy25ZefRRcFu8fxTx7G5S5tMCMNU1X
 8KZVO87X2USuIoF0No67oFRbWBDxeOf5mfGPXk1rpaEbzUzol683V82Tdmye7aXkuN8h
 abIWJBlOqEnTB8BtNC2eSNLhGaIOCHsWIs8t1Yr/RKIV3KThFIWp9+OF1qTYeakEwfwe hA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhree7b1b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 10:56:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EAtrm0000306
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 10:55:53 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1EAtq7D014060;
	Thu, 14 Feb 2019 10:55:52 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 02:55:52 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [LSF/MM TOPIC] (again) THP for file systems
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190213235959.GX12668@bombadil.infradead.org>
Date: Thu, 14 Feb 2019 03:55:50 -0700
Cc: Song Liu <songliubraving@fb.com>,
        "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-raid <linux-raid@vger.kernel.org>,
        "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Transfer-Encoding: 7bit
Message-Id: <98E2D333-409A-47AF-886F-3E661BD1C4EE@oracle.com>
References: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
 <20190213235959.GX12668@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 13, 2019, at 4:59 PM, Matthew Wilcox <willy@infradead.org> wrote:
> 
> I believe the direction is clear.  It needs people to do the work.
> We're critically short of reviewers.  I got precious little review of
> the original XArray work, which made Andrew nervous and delayed its
> integration.  Now I'm getting little review of the followup patches
> to lay the groundwork for filesystems to support larger page sizes.
> I have very little patience for this situation.

I'll be happy to dive in and look at the changes from an mm point of view,
but I don't feel qualified to comment on all the file system
considerations.

Perhaps if someone from the fs side would volunteer; I know well how
frustrating it can be to be trapped in code review suspended animation.

