Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0FB0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:32:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7855720857
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:32:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IK5jRT10"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7855720857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 285988E0003; Thu, 28 Feb 2019 16:32:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2330F8E0001; Thu, 28 Feb 2019 16:32:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FD058E0003; Thu, 28 Feb 2019 16:32:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6DBB8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:32:51 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id v85so2725691ywc.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:32:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=9cjAB8k482sCSDI8ZI00ufOwnTQdR1UDDejmT12EfLw=;
        b=I3bDqm4DGhPEIkD8lxIgaZrrNyiTarJ36/CTa2TZDmiopP3qAZ+fWZwMFS8jwmPFBQ
         fRwUTTZ6dr/UeYFn44bAqgOUnY+EG3rHGJ6f3rTEg3G3kGhkICKu3BIQIOMtzecnS1Db
         6Ub6UjJDFewkAU2QYvrVHM9JEz1M94GXtdC1D7M7YqqiU1H1JHV3y2V/6ut2zpHhRiAP
         g6Ehm2cbK6LKwQM961XLZF/2gmxeVHIP5dnZLxg+6VHq6eUOvlVVu3ixe9jKrmyp6R0s
         sei/CTvxUKBCdXhaBGNaeJ2SZkDOvb7T6q31/oTlmHIaj7nB4YSbMM6XRpRLDVlXS3Zd
         0S8A==
X-Gm-Message-State: APjAAAWU1/TdSpCY1JQeiAe+TpIJ5WlVkf9+NXNLGyf3H7sKEbUgbp88
	GuVEaLvsvyHDSgEFP8H14AZ5x0iZaQXJ7njmsWXcoAnmNo4KJboz5q0oCCEa2YqMnUK2iRPp6oe
	em0/049q8Zv/Gk3oFV5HUPwjv+R6lUELcpSK2O3Vdfma9y155kZNCZJvB9a+seLYiTA==
X-Received: by 2002:a25:e80e:: with SMTP id k14mr1566028ybd.104.1551389571592;
        Thu, 28 Feb 2019 13:32:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqyfnkxcKQWJXHv5k3qk/A6c7NBWgMlpoEqkp32iDoq3n6woZJBai7zXXC+CdjD7EFUDos2a
X-Received: by 2002:a25:e80e:: with SMTP id k14mr1565993ybd.104.1551389570959;
        Thu, 28 Feb 2019 13:32:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551389570; cv=none;
        d=google.com; s=arc-20160816;
        b=D04axDGifLkUnO8g6YAFml/huwvnPu9v/cESMCyfkFvxf/C67tNXWLMkeyWmfOIKBw
         iZLZEdV3foS8KsOPFZyaXs/+0V75EW7VIAx7JZUOq4txiaOrocxB9NI6gQJo+yW96ujD
         +MfP8EAPrCOms9eVmFl4RTpc/YmjsMp4C+7kcN3J5KaSOXxNTONaPXgltYmJoCmdncc+
         uPaRq9jPShPxMDMfyycKeyFnIgbKUq+ccwCjvD26MsB+AZ62YeV70ju70ElH4rZ3lGWu
         e4UyOOUFDLIg8jE4onqMR/AR2uukF3BXUNt1C6PaNDJubAoJSdLb+o1hX5A7cZPxXNMf
         1usw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=9cjAB8k482sCSDI8ZI00ufOwnTQdR1UDDejmT12EfLw=;
        b=RORx8QHT2DWhXC7bx0N/NmDgRzteAp6KbrSq5No0RLhvoo9tlY4Qv2QaTZqfIjlKJZ
         o+5CqIVfAzStt0LxVRndc80L4dqtdKMV9zB+2b+CtWVvW/cjU15F4dRCICanlFcZmLrV
         vUVSRjOa9tmdeHK/pFdqUXDrkBv5xG2QKksL8Zwnuh3fGij4pxsY1tc5M9AB80qcjSjC
         8VUz+DSJIRLM5GgGt6ucuz+yA/1i3PYNhn1KFoS6G6JoLV+InpMUcRhSYslx8fKat8gH
         h3cxW/EW/8CZiQsg2YNvqmeGi1FlR+hnZMJ8j3XtYdhs+5HZFWrqOfzsdFyckwn9bPlN
         soiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IK5jRT10;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w9si11092897ybk.359.2019.02.28.13.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 13:32:50 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IK5jRT10;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1SLERO7082133;
	Thu, 28 Feb 2019 21:32:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=9cjAB8k482sCSDI8ZI00ufOwnTQdR1UDDejmT12EfLw=;
 b=IK5jRT10KiIbs+MeoHXGnViw+Wx/ztx1TQ64VQFsmz/NDvWk/EY8F4zu981bXu9nXBlY
 gYMcea/eyZwUF+2B2InUG4rF0Jbk9Uw4SQZcbEEuc/SY7P0QgUPo237+giHa/zCMhc+k
 00aRoV3Ylx7HE9Vhj1UeR0tYq3Un84ADOOpNDKZ4+QnaFngOKZYUkNxis3C2Q+URspUa
 Y9JNtHv71krIi7EjnqDs52vbZk2pGIFgG0ISETkITPgDtkftWdrG14oQ9yqleZaYIwCS
 H3Hc2r9fYyc5BWe2fgC+LXFnmyFD0ymL01M0dX7nlqsfHorUGYL3S7uC9aBpl0FJX9AS pQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qtupem174-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 21:32:46 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1SLWjpS008053
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 21:32:45 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1SLWgrn022976;
	Thu, 28 Feb 2019 21:32:43 GMT
Received: from dhcp-10-65-148-83.vpn.oracle.com (/10.65.148.83)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Feb 2019 13:32:42 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190228102229.dec5e125fc65a3ff7c6f865f@linux-foundation.org>
Date: Thu, 28 Feb 2019 14:32:41 -0700
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
        Rik van Riel <riel@surriel.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@techsingularity.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3682FD80-92AD-4388-8751-00FD1CC74D46@oracle.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
 <7AF5AEF9-FF0A-41C1-834A-4C33EBD0CA09@oracle.com>
 <20190228102229.dec5e125fc65a3ff7c6f865f@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9181 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=712 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902280142
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 28, 2019, at 11:22 AM, Andrew Morton =
<akpm@linux-foundation.org> wrote:
>=20
> I don't think so.  This kernedoc comment was missing its leading /**.=20=

> The patch fixes that.

That makes sense; it had looked like just an extraneous asterisk.

