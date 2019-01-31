Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C884CC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 21:41:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84D8521872
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 21:41:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TgVNb1/q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84D8521872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20D898E0002; Thu, 31 Jan 2019 16:41:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BAC38E0001; Thu, 31 Jan 2019 16:41:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0843A8E0002; Thu, 31 Jan 2019 16:41:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D0C8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:41:14 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so3076794pgq.9
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:41:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=RQb5/8LhrDwHwIxWuRZz/TvSJI1H3crNeKps1AN49TI=;
        b=HeBIjmMLUxmKx24hJHDanbtleAGS6Thqcyk6oKL5eIEHCeSsb5GS88s/B8ngEnIYYc
         prTPd9wRd2x6ZSIUOC1eUzRfMasXx1Lp1rhLrQs+qzK49EQeoQK65Hv5U2H8Ab5bDVWb
         aKcXanwKTB+t6/wBKMD4EAT5sYwa1NvCH2NXIFtz9FO8D9hQAuJlPnsMUFT7Z/s7yn/R
         xiBqlfB2VVMAklstFPn5uqkmHQFUGSzGZwNfVSZbeKbovjEVdmwPjJyWaqhfStZ+oCak
         jo00WUFxIIGGzSt58MLCtXPfxaqdQSn5HDY6fMF354BcLx0x85Zz3IildXGqS1gmD14A
         +xvg==
X-Gm-Message-State: AJcUukefHFRT9DbZ00dqxiL1DSRFbqRbXxS3+foN+ngu+xAPWyEl66Ow
	1VkrOC2ly2bIuukiUfssaOwfabcmfmDCoHj+3Lza3Sz2jeFtFBFHW6iWDo+IzahYvaa4snJeo5j
	uPLV1E3pJgqXpWYTC/ML7+658GPHzjTtn5+zZZSCtmy6FFEjzVmB7HaK+ldVGxHlDDg==
X-Received: by 2002:a63:f201:: with SMTP id v1mr31089928pgh.232.1548970874359;
        Thu, 31 Jan 2019 13:41:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6/IxvNKUWTD3X6rFKQiBTRB1Lu3INsdDpx+AQXM9bxh/dhn60QgVPK+A4T0HIGchVv5oK+
X-Received: by 2002:a63:f201:: with SMTP id v1mr31089904pgh.232.1548970873719;
        Thu, 31 Jan 2019 13:41:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548970873; cv=none;
        d=google.com; s=arc-20160816;
        b=SF26a2mAo5t1y2BRaNU1cGk9tS32MsNDWqWPJrUyzWfvAm7ZjVgs4Abn5J9gl9KukF
         tG7KGd6yGffxyIICI7k0RRWPHUCVsGqz7956q2Xrd4Says6qE26g8o5oj4FpzMTalqD0
         rEJRtMViR2JotsUhoXv0b8HGj3eWZfR00etamC3zRC0wApobtMJZkkStCFLsKzWvtZfv
         s+COeackIuYw4hmC0MY4pd3VzlsvX8+OCJQHsGJaq2dE2/kWkZ9SCjp2YVWzk78YG5Hq
         3llbPk8xHiiBkJFf7u1VtawQhSUr+CwR9o/oWxeoq1lfbfSBW//NAsR7ui1cdve9xteG
         rWgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=RQb5/8LhrDwHwIxWuRZz/TvSJI1H3crNeKps1AN49TI=;
        b=s3XWXcjNjCiANuHXHFTR5jb5WqQvT849HU+ixHoS6VHsK/JXiM9X94coYYPusnsVsJ
         6gQabM2uOYp9+ZfwaxO8k3Lbpq35gDNJVPAYg1aNpv0+PGbtpK7N+g3o4oElXsQL2MV5
         OjyJyLvMc91ACKZoDtMoQNgK+POe2FWRuNfgXwb8EuqMEE5mNLmCudChXk2Ejp9F5noo
         PbmkCvEq4gZDOquyPXXiZAu4jUHXhnyvNPNBQYrrqjDxt9jbKFLOGdn6j2AOO0lMmqcM
         WF4O+hz6CMc5LxFaJ1hl6+Ro/wA+/tNN6QkrBtYIhar8f+qXtlwchMZx2+TfC37PTYW1
         uOBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="TgVNb1/q";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d8si5410407plo.196.2019.01.31.13.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 13:41:13 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="TgVNb1/q";
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0VLXaQK149776;
	Thu, 31 Jan 2019 21:40:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=RQb5/8LhrDwHwIxWuRZz/TvSJI1H3crNeKps1AN49TI=;
 b=TgVNb1/qiZIEv14vkpIyyWdGnYo+yNICxHomKlqYskcU4QzuKuEkYQ7kywzD2TOcieqU
 bkMFzoHCMWqWi2QZF2cqa4zv47JB49YtU2m2yEnp3pUxViMIZ/uG7oOsyusslJxQLe5O
 noNxs/MEvRZeTX34NJoL+F9UUBwvEW9n6ihPNxc6OIaos2tmPAwKAl01+7Bj6CGaxmn4
 +pmE4UAbRfEpmASMLpd6Ehmw3gKUow6ohrV2rltQz/wRe6pSGiFPvfW+QbBWsVmL08UC
 n9+jOPHTNGUegEQ+OE/nmubJ+B6FjSeNzYu4sZx3koLJkREdlEe1BuX8jXybg/yDSO9I Zg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2q8d2ekgaf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 21:40:23 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0VLeNJG002538
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 21:40:23 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0VLeLsR009488;
	Thu, 31 Jan 2019 21:40:22 GMT
Received: from dhcp-10-65-146-169.vpn.oracle.com (/10.65.146.169)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 31 Jan 2019 13:40:21 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.1\))
Subject: Re: [PATCH 1/1] mm/vmalloc: convert vmap_lazy_nr to atomic_long_t
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190131162452.25879-1-urezki@gmail.com>
Date: Thu, 31 Jan 2019 14:40:20 -0700
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Thomas Garnier <thgarnie@google.com>,
        Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <660AEEE7-0221-42EF-BFE1-808760AA7910@oracle.com>
References: <20190131162452.25879-1-urezki@gmail.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
X-Mailer: Apple Mail (2.3445.104.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9153 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=738 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jan 31, 2019, at 9:24 AM, Uladzislau Rezki (Sony) =
<urezki@gmail.com> wrote:
>=20
> vmap_lazy_nr variable has atomic_t type that is 4 bytes integer
> value on both 32 and 64 bit systems. lazy_max_pages() deals with
> "unsigned long" that is 8 bytes on 64 bit system, thus vmap_lazy_nr
> should be 8 bytes on 64 bit as well.

Looks good.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>=

