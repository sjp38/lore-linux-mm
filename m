Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E812C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 18:53:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBA0920818
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 18:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LUSkCcyZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBA0920818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37A016B0005; Tue, 14 May 2019 14:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32ADC6B0006; Tue, 14 May 2019 14:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3A96B0007; Tue, 14 May 2019 14:53:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id E67986B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:53:25 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id w5so320oig.18
        for <linux-mm@kvack.org>; Tue, 14 May 2019 11:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=31OE527D1rWAirfTB877GDNGJC88ito9E6Gvugy4RfM=;
        b=URl/TQQdfxkyikPjNq6/DdLClX1BJLGMsxoyUwvync/s0URpiCaW/MfVnl7gie3gP8
         eWYgLkwUeSjVyXKFd7vlP0gj8T6LESxbPEGzYilrjEZatkP0dW+AgC4+c4L5Hl3TNyxD
         OcHds1I8vtsIIHBxprjmi4szwgdDpGVrKh+Imm0+4s8CHMrqzp/BdPLshLqHXUrRQnMw
         krJpkBraIBXW0S1zJB7XZhsREXetniloJbR4TbDXPAuAFdMgMpIodVPPyItFhYWZ9yif
         tF+5bl36hAi7KMFAFVZV8jzsOCfA0smYzwCCHry1fJHlgZHjXMwRXJmTgpN1xyHZ0wVz
         bY1Q==
X-Gm-Message-State: APjAAAXcPToNhixuM1s2Yt+pd0cLWL21EWMIkflC5UhEeFpDdwspietL
	2A6TESYP91vOgg3DKk4GJCxQrpgimXuKIHYYh7NwUwvyIvgN7yWeuyRSMxNSu9S4OrhkNhDNlcQ
	KEDo7y1kLtVgpM7WjZ5PneeknnwJvr6Xn1C2ZBUOIifA22aIWPmIUP+XVWlP4FalfQw==
X-Received: by 2002:aca:c5ce:: with SMTP id v197mr4223848oif.106.1557860005498;
        Tue, 14 May 2019 11:53:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQOgxP3lATbIRhq/BU3F+V2UogipkGg5tWUdQ1KWIhy6SZSFJnsaoEqo4tGv12deXJf4eO
X-Received: by 2002:aca:c5ce:: with SMTP id v197mr4223808oif.106.1557860004685;
        Tue, 14 May 2019 11:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557860004; cv=none;
        d=google.com; s=arc-20160816;
        b=JK9g1+ihi1xuTEfZfZXUgfMoFCn8mD9rRZaq2FLCEpDS/tVZoXe/QoMaiAiD1wNfop
         6hQBw4C2znq6kMTTVopy4f4uugBv0moZ8uBkF1dbgIgBn5dBArKDqCVz2yKfpauGeAcS
         aDQLWfWXkhMT7Mb7I8gAEEP20ISMBwaEacgbxAJTtrcPxKKYKuuZ4VTrbXr+DVGMnDnu
         FOSWw4Ku1SCzTZ3/3qvhTADeWN91QC/ORKgL9sfIbUNlQUZo9dhDoUvaRxwZH4TdDe/J
         7rZMA+ShBQIzGnT7cQbG7ARbSnW5YOmddFbPQaQYYyhe0Uxcv44nQjmIlNQ1TF3LX09J
         GvNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=31OE527D1rWAirfTB877GDNGJC88ito9E6Gvugy4RfM=;
        b=Sb9RVf108DGSRJkFdh+sBovkPLWslF0KycXtLBOqKtZYEloSGN96dwq1yHg0pcKa2H
         WelSW+QOhS9ErHC/slAc1tEAXqPhdaGfAKqZB6cUKkatgd7qCbMSgSoRJyhD6Pg9ToSc
         2fyPntlGKL5N3gAsAPXxBri0EXJ6emdvBqEJlPHO+QKd2BQYhtdjTbkq1J6egxgUC4z0
         ojjiuObiaY6A7XRXLS30qiq+1aexxQ1u9FHqm4dE1G1uImhOPrNi/cL4fGMRQ0fTpjP9
         GfoUQItAbGvpuFpYsUbdbPaU6yxP0pbNR5a0o+WiAQH/ICHX2jQUftAI3wF1+8JfEZsX
         ZuwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LUSkCcyZ;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n9si8605538oif.113.2019.05.14.11.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 11:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LUSkCcyZ;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EIiFBn023209;
	Tue, 14 May 2019 18:53:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=31OE527D1rWAirfTB877GDNGJC88ito9E6Gvugy4RfM=;
 b=LUSkCcyZ25L9H7hizXGBi8Ar9iUmwXy5ekupLpY0mAcKTKhjjc7wtT0Rk2SaKOO0uJX/
 1zm5bhxPwY/5hRN6PalXPtRuWcRrmMuoaFQD5mSMxx2l5sImxbTiYJjAMaAvHl7C9br7
 FaxmShgLq7rOtOr6HIFZ4nbXNPuvZ9MXVt9ktoTEjGuFk3GTSa77NpRkm4ot9SEFzzdf
 Zu2HhJMNRVNxYr9OveBl9ZozmcAbTEWd/M+sflIC87c55xPG9MGA4N3OdwvvmKOYVLOA
 Y+QiwHa0ZX0wAM0Ow5w9xmYwxYaBIVYEebqbMPkteoIN4cTss8OLwb+7BQNTW4LLC+EJ Rw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2sdnttr78x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 18:53:09 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EIncCx181596;
	Tue, 14 May 2019 18:51:09 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2sdnqjqv4u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 18:51:09 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4EIp6Q1024918;
	Tue, 14 May 2019 18:51:06 GMT
Received: from [10.159.158.136] (/10.159.158.136)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 11:51:06 -0700
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Logan Gunthorpe <logang@deltatee.com>,
        Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: "Rafael J. Wysocki" <rafael@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
 <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
Date: Tue, 14 May 2019 11:51:04 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
Content-Type: multipart/alternative;
 boundary="------------2351910460E6DD5DA1D32EA8"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140126
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140126
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------2351910460E6DD5DA1D32EA8
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:

>
> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
>>
>> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>>> Changes since v1 [1]:
>>> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>>>
>>> - Refresh the p2pdma patch headers to match the format of other p2pdma
>>>     patches (Bjorn)
>>>
>>> - Collect Ira's reviewed-by
>>>
>>> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
>> This series looks good to me:
>>
>> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>>
>> However, I haven't tested it yet but I intend to later this week.
> I've tested libnvdimm-pending which includes this series on my setup and
> everything works great.

Just wondering in a difference scenario where pmem pages are exported to
a KVM guest, and then by mistake the user issues "ndctl destroy-namespace -f",
will the kernel wait indefinitely until the user figures out to kill the guest
and release the pmem pages?

thanks,
-jane
  

>
> Thanks,
>
> Logan
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--------------2351910460E6DD5DA1D32EA8
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p>On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:<br>
    </p>
    <blockquote type="cite"
      cite="mid:17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com">
      <pre class="moz-quote-pre" wrap="">

On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
</pre>
      <blockquote type="cite">
        <pre class="moz-quote-pre" wrap="">

On 2019-05-07 5:55 p.m., Dan Williams wrote:
</pre>
        <blockquote type="cite">
          <pre class="moz-quote-pre" wrap="">Changes since v1 [1]:
- Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)

- Refresh the p2pdma patch headers to match the format of other p2pdma
   patches (Bjorn)

- Collect Ira's reviewed-by

[1]: <a class="moz-txt-link-freetext" href="https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/">https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/</a>
</pre>
        </blockquote>
        <pre class="moz-quote-pre" wrap="">
This series looks good to me:

Reviewed-by: Logan Gunthorpe <a class="moz-txt-link-rfc2396E" href="mailto:logang@deltatee.com">&lt;logang@deltatee.com&gt;</a>

However, I haven't tested it yet but I intend to later this week.
</pre>
      </blockquote>
      <pre class="moz-quote-pre" wrap="">
I've tested libnvdimm-pending which includes this series on my setup and
everything works great.</pre>
    </blockquote>
    <pre>Just wondering in a difference scenario where pmem pages are exported to
a KVM guest, and then by mistake the user issues "ndctl destroy-namespace -f",
will the kernel wait indefinitely until the user figures out to kill the guest
and release the pmem pages?

thanks,
-jane
 
</pre>
    <blockquote type="cite"
      cite="mid:17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com">
      <pre class="moz-quote-pre" wrap="">

Thanks,

Logan
_______________________________________________
Linux-nvdimm mailing list
<a class="moz-txt-link-abbreviated" href="mailto:Linux-nvdimm@lists.01.org">Linux-nvdimm@lists.01.org</a>
<a class="moz-txt-link-freetext" href="https://lists.01.org/mailman/listinfo/linux-nvdimm">https://lists.01.org/mailman/listinfo/linux-nvdimm</a>
</pre>
    </blockquote>
  </body>
</html>

--------------2351910460E6DD5DA1D32EA8--

