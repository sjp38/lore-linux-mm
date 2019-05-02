Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E20AC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 305E520651
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 19:48:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TaNNMa2B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 305E520651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915306B0003; Thu,  2 May 2019 15:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C5376B0005; Thu,  2 May 2019 15:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78D796B0007; Thu,  2 May 2019 15:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5788D6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 15:48:11 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id c4so5486839ywd.0
        for <linux-mm@kvack.org>; Thu, 02 May 2019 12:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=0nSq0kzqdxwXiYYsldtvVwitvvszvDIgIGmFM1J8Go4=;
        b=NdLeUuJQxWteEICGNwYpU81gBXdEcbCoCBKAm3p43HJm2xZGR8OX3XY6+dhOZFg1BP
         AtiJpOCGhR2bnetWVC9+PDdr0p/PyA9ZUbBaZrG2d/5ifJDdLvBofrFlQ1O4KpHrZe1n
         j+g8A1BRuyKxRasstln7nDD+3Ngkx65HfedUMk+tU+2gEQXneateVcFX1YdvTeq4RJyf
         8AXIAGkovhP2lvArXg8uJGeudaNXn/3mvLVEUb2x/bnVJVKJYU38LP587/xYByVrFVuk
         +iBcXceVcJ8eBumgoueVQlhe5pfsfAXDLVLqnk3gbGqzYy8ZkcV38ifOI5jiXxhzRISe
         f+ZQ==
X-Gm-Message-State: APjAAAXcnfSVtLytqg0+EO/YbtD7VZ/ZRKOrdrqB8Xo/ybehGaUFlsam
	3iUHNlsRcGheYePTFUUgNU/tPPyPO+ztilgTNoJl0z9wfw3bSJ8UENBmcu5Vkej5+5QI8bNqmv4
	Cq2UMJWG+p4N01yfiST+inlNbleH9h2DAR6Kz9YRAu1rojvmbCUH3Ks5uOfa9fYX5aw==
X-Received: by 2002:a5b:c4b:: with SMTP id d11mr5000668ybr.380.1556826491007;
        Thu, 02 May 2019 12:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk04r4WKBUyH8QtJ725EVButPsRYKbYkGr1pW0DAaR5GN1kfvRskckUuP6SRO2W+9ScYml
X-Received: by 2002:a5b:c4b:: with SMTP id d11mr5000635ybr.380.1556826490539;
        Thu, 02 May 2019 12:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556826490; cv=none;
        d=google.com; s=arc-20160816;
        b=R/czc6zqw53ZOoe69cGB4u2V9BYKqH31o2Rt8qlKoCpC1Ts7wKVXzIwD7+sx9avS4k
         sKe5aANT1zKSVXJAfRKct3sg05jbMQsonWL3g3yQqS/yllPVj08m5IOWiZ84aeMEVBii
         ptJ0Zb1cDffUk5zgnTpPrhuSZhR8OgeB/hqM3/BM1mFrx+t5HoBDRhtmRBM63Ym5mdS9
         zC1CJhzED+7pKM724tS1astQNEYq/Fo5JD9zI+LD3EBnHrom2Y1A1ty73I85GHK4T1IE
         ZPdCEi2IC6HeU8V/6C4yIIt3tVocufwyomfXgA8RkZJ4JcWPf53om7RIna7g13v7Dovb
         C15Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=0nSq0kzqdxwXiYYsldtvVwitvvszvDIgIGmFM1J8Go4=;
        b=jjvLLdO0d2JEW0/Vjf/wtjFBXQeEiY+YaTd/wxIS1qJUQEIQYJj5L73qAkuHGhymse
         /1eOSJmU4xezPvr7Vybbu+dSzkS1CWaZJqkJT4DC0LhxX/nG8XgONuBWLZcsyW03pqWq
         8DJpfiGFTaZXC7Bqk45NOUDW9zYEht0E3X0wOSPa0x4dYbV7AfxSERxwDHtRlo5vFb2t
         JRmnyt9xxajLlLcI1AGxwHVuvqXWyfnN71XCEp3uFA//r4soCMxdV7Z9QvTa/WoHYxBo
         eHqYbYAnmAp4sUVm5g3bBQMrVvZd3j4Fn1MR+Jrv02Wmf/I7oTbiPSzeMP6JigDobzQK
         ElnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TaNNMa2B;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 129si28283676ybw.247.2019.05.02.12.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 12:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TaNNMa2B;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x42Drld9044213;
	Thu, 2 May 2019 14:01:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=0nSq0kzqdxwXiYYsldtvVwitvvszvDIgIGmFM1J8Go4=;
 b=TaNNMa2B3szcnIGTjpzw1y1uhWHK5FEUEBlcSR2DulIaKvT96+earpB9CbzqWvqGVbOx
 AdEX4IKYdgxldbmlRba25NlSm4YTPHKwg3QyMNbAXI31CTjrJuMEd5gksl8sgz1Gxxvd
 d9Dy2vxr6LzweCNieFFFperDLIsKtfJ+LKcILhN4tVEvcMemNhql38e9L1/W0vY7fOrO
 htOyxx8D5TrxxlvoFakCqeFcy3DisS8ryorQfhsul2q8lhxVNo3lvzkvNTWaPWxX5oCT
 82JOZShN0I331KWTO+RLcmYwTg9v4okJIjt6DLI0HjeugL3zVQ3wxAcrG91DIRcP7gqp 5g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2s6xhygtmp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 02 May 2019 14:01:51 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x42E0kBR104040;
	Thu, 2 May 2019 14:01:51 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2s7rtbr047-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 02 May 2019 14:01:51 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x42E1l7Y006859;
	Thu, 2 May 2019 14:01:48 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 02 May 2019 07:01:47 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 5/4] 9p: pass the correct prototype to read_cache_page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190502130405.GA2679@lst.de>
Date: Thu, 2 May 2019 08:01:43 -0600
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Sami Tolvanen <samitolvanen@google.com>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <1CFA4656-2E3E-40D2-A0B2-A49F174F2420@oracle.com>
References: <20190501160636.30841-1-hch@lst.de>
 <20190501173443.GA19969@lst.de>
 <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
 <20190502130405.GA2679@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9244 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=780
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905020095
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9244 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=826 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905020095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 2, 2019, at 7:04 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> Except that we don't pass v9fs_vfs_readpage as the filler any more,
> we now pass v9fs_fid_readpage.

True, so never mind. :-)


