Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 535CCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:30:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F11AE21928
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:30:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uOOtJqOt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F11AE21928
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 735DA8E0002; Thu, 14 Feb 2019 12:30:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E6338E0001; Thu, 14 Feb 2019 12:30:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D5718E0002; Thu, 14 Feb 2019 12:30:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E45E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:30:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so5295832pfd.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:30:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=ZDnSGb7HkaLIn3ieo9EA5WXs8Eea/qqfp6fJCQp9l2Y=;
        b=GOaqdcZEM3hGI+95JbWkT9yenSo2F2aVxzs3pOOCVVSQNIaq45gVdqCbLooKLsl/1j
         hzaEPiQpkCjmS+134FIHaoLacGwOedf0cgx0ofQOvu/FXcsu/+w68aL8wc0PNT0bYDiH
         KjgKCClxE+LIgzdPffz6yVdCdmurVAr+iq55JCr5FX4os6EMEF1mmYcszFkInu07d6lG
         nrc2jjcCsXfjl4lI599XUIs0ne/vu+w8Prtx53F/8qu973Ss9HYa8frfth6xZ2onXdEE
         4h2ogs4kFI+WcA6x3ordgh2Ee3mwm93mdO2UEr9zGbnUDcCvxkbVCF1Pw2kO8tWKF4Ph
         nyfQ==
X-Gm-Message-State: AHQUAuZhZUa/V6HlVHGDZQcHj3yH/xW+3lh2xGndUhGsADVwv6eggMml
	qTAx7Smtc0eRyacCJRih3l5Sy1fP7UJ7gwvvHDoU7KIpBVBKqZSkvgt2IKI/uelhral7TZa0wjU
	yZutqz9Q5i8Tu4kXvp/iSd3uGX6pihrnekEhrr98l3ktEcttS8QEh1r0SIVPTWsdP8Q==
X-Received: by 2002:a63:4a21:: with SMTP id x33mr968646pga.428.1550165420723;
        Thu, 14 Feb 2019 09:30:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IalBFsm3crBOgFlEcom85lW3Le4DDsjQLUbzqq+LyDyIIlD7f9No9bcGeAIxKiIo5w43h9G
X-Received: by 2002:a63:4a21:: with SMTP id x33mr968586pga.428.1550165420050;
        Thu, 14 Feb 2019 09:30:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550165420; cv=none;
        d=google.com; s=arc-20160816;
        b=tgeR4vqPvJ5UANTXDCnivGRMXH3Y+IMGaFUMgaTJZddrk0yGltWwFUNDjn2QwOT/aJ
         U+O4P40GurhINXXifjnU+KaeUEZnNhuz+orDpuPecuEJrJL0rw1No/9wqiL2NVO/lIbT
         kXKldljLsCT9a1/BRl+nCIK/TZ7+wmkRTO0jX+xrSh7brw8XKf7pwgjYU7xoKeHCXaTG
         tNIqpHwyS8HZLA+YktqlvzITA5g3yHA70lh6xpa+aoKv8/wMBwchq61XxFB5y0jt1e2n
         rJMFXuxmgiUge1E4W/2yuyTzppMjJEWWzxuVD8ah11lIE6clFS4W2mAF/zEhFHiozl0v
         FF9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=ZDnSGb7HkaLIn3ieo9EA5WXs8Eea/qqfp6fJCQp9l2Y=;
        b=Ec+5555pqg/6fHosNETfTGnqPg8bd1m2gqgwInO06QLb15098z6rYhqxhZQA2c/RuJ
         oZBMUqmXFOrv9GJsb8pxFbnMmQVHxEWO3j+LKOp5CVdPq6FvpJuuBakyriaXrelePwo6
         Kn3yb3/WeRRqDmjZQRiv5zARKEs/jyCdQLDF8jtrEnWbXG8yryNrXSKhBt5G2YFfbZJ4
         Rw2ADQKOQTaXYjnHbgpier9moBD+8o/UcjPPadz4r3qtVOURJLofLYXsitCuNslYMFtk
         awpqAh8YUWJwAeABR7HytZcLeKqnUSRiqyz9XsIM5V0/OdY7F31N3UIfDZhX/1CGthMA
         mjGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uOOtJqOt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f33si2148451pgl.437.2019.02.14.09.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:30:20 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uOOtJqOt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EHNeAr141911;
	Thu, 14 Feb 2019 17:30:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=ZDnSGb7HkaLIn3ieo9EA5WXs8Eea/qqfp6fJCQp9l2Y=;
 b=uOOtJqOtbC48aiUYK7vBMB1Txf0pPmrAz1wG7bZGH1ULEm3z9SX4+p7Zhyzv5iZVXp5J
 1I3xEGEtox+EuAVdei/dp0z0cJKmIv6Vx6BHKJBBuXaskVUE9wYOS1vyq4rZhuptj/HL
 FIKGhwG+SqTCAYxIyKqgM8K9s/Ite23JIHLsQVHfmdYb/T7O9vQ3SOs0iMQybbur4kGK
 PAE7YgZf5dcj3XQcXe8KcbTfGYFKzrnqET51jqquZz4nZRop3L1tBg2Svw4x0eoUiPFu
 bkGwO67djEi5QY+LklsyWMBHg0sWLI8ph6uSsPG8FzaHRgx87V5yhzNMoPKMtBcUOjFg lQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qhre5scjb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:30:00 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1EHTvpe010398
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 17:29:58 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EHTug6027865;
	Thu, 14 Feb 2019 17:29:56 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 09:29:55 -0800
Subject: Re: [RFC PATCH v8 07/14] arm64/mm, xpfo: temporarily map dcache
 regions
To: Tycho Andersen <tycho@tycho.ws>
Cc: juergh@gmail.com, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <ea50404604bdbe1547601b6ea0af89e3da8886b0.1550088114.git.khalid.aziz@oracle.com>
 <20190214155435.GA15694@cisco>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <92787149-bb9e-6ee9-6d04-431ec145e9a4@oracle.com>
Date: Thu, 14 Feb 2019 10:29:52 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214155435.GA15694@cisco>
Content-Type: multipart/mixed;
 boundary="------------831B727C76672501BCC5E3E8"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------831B727C76672501BCC5E3E8
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 2/14/19 8:54 AM, Tycho Andersen wrote:
> Hi,
>=20
> On Wed, Feb 13, 2019 at 05:01:30PM -0700, Khalid Aziz wrote:
>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>
>> If the page is unmapped by XPFO, a data cache flush results in a fatal=

>> page fault, so let's temporarily map the region, flush the cache, and =
then
>> unmap it.
>>
>> v6: actually flush in the face of xpfo, and temporarily map the underl=
ying
>>     memory so it can be flushed correctly
>>
>> CC: linux-arm-kernel@lists.infradead.org
>> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>> ---
>>  arch/arm64/mm/flush.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
>> index 30695a868107..fad09aafd9d5 100644
>> --- a/arch/arm64/mm/flush.c
>> +++ b/arch/arm64/mm/flush.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/export.h>
>>  #include <linux/mm.h>
>>  #include <linux/pagemap.h>
>> +#include <linux/xpfo.h>
>> =20
>>  #include <asm/cacheflush.h>
>>  #include <asm/cache.h>
>> @@ -28,9 +29,15 @@
>>  void sync_icache_aliases(void *kaddr, unsigned long len)
>>  {
>>  	unsigned long addr =3D (unsigned long)kaddr;
>> +	unsigned long num_pages =3D XPFO_NUM_PAGES(addr, len);
>> +	void *mapping[num_pages];
>=20
> What version does this build on? Presumably -Wvla will cause an error
> here, but,
>=20
>>  	if (icache_is_aliasing()) {
>> +		xpfo_temp_map(kaddr, len, mapping,
>> +			      sizeof(mapping[0]) * num_pages);
>>  		__clean_dcache_area_pou(kaddr, len);
>=20
> Here, we map the pages to some random address via xpfo_temp_map(),
> then pass the *original* address (which may not have been mapped) to
> __clean_dcache_area_pou(). So I think this whole approach is wrong.
>=20
> If we want to do it this way, it may be that we need some
> xpfo_map_contiguous() type thing, but since we're just going to flush
> it anyway, that seems a little crazy. Maybe someone who knows more
> about arm64 knows a better way?
>=20
> Tycho
>=20

Hi Tycho,

You are right. Things don't quite look right with this patch. I don't
know arm64 well enough either, so I will wait for someone more
knowledgeable to make a recommendation here.

On a side note, do you mind if I update your address in your
signed-off-by from tycho@docker.com when I send the next version of this
series?

Thanks,
Khalid

--------------831B727C76672501BCC5E3E8
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------831B727C76672501BCC5E3E8--

