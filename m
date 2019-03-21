Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED9B2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:24:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E339218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GdjYGLlt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E339218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B90126B0003; Thu, 21 Mar 2019 06:24:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3F686B0006; Thu, 21 Mar 2019 06:24:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56266B0007; Thu, 21 Mar 2019 06:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1636B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:24:49 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o66so7237571ywc.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 03:24:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=v0TkPBWgrLmRX0kAD4/pUy041dM3Z5H22OqMdbWAwiQ=;
        b=lH5g/pbzA67eKpA/NUa7zsWa7WQAyFWxspf4nEsGdwOBY8cGGZJXWPFyV2j9rxt3Qb
         qxquSqKMyUSuqkBw7ddBkIFc19/OfJHEWWAwbvFMbwjvSTNxXmsYJOCy61Q52kgB3INc
         TxO0rNOHCp3x7G995CR4NgaqjFxnLD7NO7iVpyTlN78yELoWSJuZOIqU+Mc16cxQbYYz
         l/ZhDbEGy9U6v9ML2bRpP63ppAI5UmlmzHWk3pN6CRCx9fdxYv7rElitlwhEh5OYq6Ug
         /vlJPIJV1o0Ngyv74AiIceoGSYwRSc6bAeKZ+kxu7EOXu2puX8c47JkgN56NJnYZaLAw
         4+/A==
X-Gm-Message-State: APjAAAXffF4j2XOcfQfB3meKEDLDLrpcjLH7bjZw/+6RSn/PVVoEBpej
	3e+U5XKaoEn9F0GGsiQ+TG+kh9TJyuSrVdGkQMIE8P8yU+EMRTBeghFh0s9scg5wcgwPQBr6Coz
	ER0TPX66Ly2jMdFCoSSEcSkEmHA/TTlvEfdCOZm5j+oL4VU7ndNr4lhHturEv1JJQgA==
X-Received: by 2002:a25:9a46:: with SMTP id r6mr2136407ybo.230.1553163889273;
        Thu, 21 Mar 2019 03:24:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhTquS73QEugZZgiMKOqAn3SQIYQoUAW36XeWYWMBF+mPHTRphpFK/VcwwOskZrZiwxQ43
X-Received: by 2002:a25:9a46:: with SMTP id r6mr2136370ybo.230.1553163888517;
        Thu, 21 Mar 2019 03:24:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553163888; cv=none;
        d=google.com; s=arc-20160816;
        b=dtAYMc+68HF0I2bouJqKwZwI9ceGW44X2YYFpZwYROrd57B96qt+S1Zl5hfuX7TuNK
         A22WySHVL98XpvxEFfVG4a9ajrprH6ne2kh0hX5YcHvVu9EtyLvxn4Mj3NA1iLdKpZS4
         JqAem7VFsvQeYH5fJ18TrfLnZsEW8eEWNU1HD1ONC8OJKv9dpeaBFXx6mi3VgVU05NBW
         zxBYq8CRPrhhIBX6VH4O8+6nwCAUIkKVs4gA9dwDAtAKn0YO1M0daDl9FMYJ6DrLjmWC
         02Oaob6GrLjZ5PtF4LLjNgyDWGMSPOSVWxCvkb/CL866lnBZhaT4dKGOtwBwdfplHNIm
         7TtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=v0TkPBWgrLmRX0kAD4/pUy041dM3Z5H22OqMdbWAwiQ=;
        b=Nf3YwxTGW1Rfu3jEhCxEttqy7s7CgpYUMofzO/wLUYdawZ/ujr66sQpaKCkpHfXbL+
         7ojCVV6Hi0WCCkKgyDYRfIbk/tSzVEeDRz9WhG0CbCYWz28R4O6CcFQHJIG2cDhoPeOK
         z1NaQw43jKdOUb1LgNmWExYwIkCEaA0iui2/jBclG4yiPdyUeiPQtk5XMoGA7YQ8GAEP
         OJ2uXeF4GeSD3ObqMAyQMjDj81MvqEdEk1TD3Bdd7/0Az4yFQcIJZbXqYATJ7iHvi96V
         fZfM0v+jBm93IB5XEAkzGPMOEDnD+Ghelk1mbsd36IJyXkqbZLSKFpoAJLC2gqs+5ar+
         mxNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GdjYGLlt;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p63si2064998ywb.295.2019.03.21.03.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 03:24:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GdjYGLlt;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2LANrov181609;
	Thu, 21 Mar 2019 10:24:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=v0TkPBWgrLmRX0kAD4/pUy041dM3Z5H22OqMdbWAwiQ=;
 b=GdjYGLltvDLGMZHSRme1wNhT4CI31vSNtgLgbKBD+Mlik4G/oKKhIoa2TgAWu3d9hMeT
 ymdyuokeX1t24yqCTrbFsJ9F56yMQWGgAL4xEH3Cuw/Q35s/A7bzEHarazvIOMh8PRg1
 c7kbR8h6JnnvC1wiJa5w7+499U6o3XatZmfRBUY/LZrf9B99wXwdRAnUW1FZB7Q6p0BW
 OtxQpf9Lt2pjwMDAoZ4U9bLhbsFRHyQRYvYt+gGg3vPoesQKn1mSfOs5o6I4akyqFPcg
 XTPogUTpurVUqn9+sx9dsoCYL1G49mPBQc6jg+Dij+omfmqF86EMCrbYr2ubGq3lwcg4 Rw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2r8ssrqgb3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 10:24:39 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2LAOcMu024317
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 10:24:39 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2LAObFu013098;
	Thu, 21 Mar 2019 10:24:37 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 21 Mar 2019 03:24:36 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190321092138.GY18740@MiWiFi-R3L-srv>
Date: Thu, 21 Mar 2019 04:24:35 -0600
Cc: Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.ibm.com>,
        Oscar Salvador <osalvador@suse.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>, mhocko@suse.com,
        rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com, linux-mm@kvack.org
Content-Transfer-Encoding: 7bit
Message-Id: <3FFF0A5F-AD27-4F31-8ECF-3B72135CF560@oracle.com>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
 <20190321064029.GW18740@MiWiFi-R3L-srv>
 <20190321092138.GY18740@MiWiFi-R3L-srv>
To: Baoquan He <bhe@redhat.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9201 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=760 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903210077
X-Bogosity: Ham, tests=bogofilter, spamicity=0.015415, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 21, 2019, at 3:21 AM, Baoquan He <bhe@redhat.com> wrote:

It appears as is so often the case that the usage has far outpaced the
documentation and -EEXIST may be the proper code to return.

The correct answer here may be to modify the documentation to note the
additional semantic, though if the usage is solely within the kernel it
may be sufficient to explain its use in the header comment for the
routine (in this case sparse_add_one_section()).


