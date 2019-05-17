Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BE97C04AAF
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:02:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE3D12082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 00:02:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="goD8WGYW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE3D12082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28A6A6B0005; Thu, 16 May 2019 20:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23A6A6B0006; Thu, 16 May 2019 20:02:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1281D6B0007; Thu, 16 May 2019 20:02:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2D386B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 20:02:01 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x23so4279278qka.19
        for <linux-mm@kvack.org>; Thu, 16 May 2019 17:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=wOL7Y2USzQ9HfFUmu2R99hBKeQx5shjfX/gs/NjLiiA=;
        b=GVLcq71dfL0yC1ZInuTCbj8OMMTofXPrn1z0R/F/JO4t73sflj5BxdIBHlN37pszBV
         oOz4cGununD4RCkfDUpgzHrBzcrz2WYpAxxo2OzpD6yOGM4YQBSWGH/AQUIUQmDEltqC
         jWCn915xqVnYyErY2taLwhBOICrIRtUWBLr+vcDSeqDTXUrWi7cW5VKzZ7r3qOfSvq3v
         HpmXKSR1/XUi9G7+Jq7co3YQWJh4H7C6mPD37g1HIGO/CKZxU8fCqUi9MPLUkXvH+gDR
         uDzV+qiX6mK9SMOZw3mLJ3WNun4lQDYDPkclpomzXYjGUVdPC6L2rv2xs6sk/fEmcSeH
         9wrw==
X-Gm-Message-State: APjAAAWsVBKGFB2HqqId6GQa+1Y9tY4RETW+aLQk30TVIlds4L4rFAjJ
	TMxyAiCQ4xOSGi7DeqKWwjELQCMFLfujHODX58tg3/JRgRpMmOuw8W2DtvtuSAjTJVN7U2sxRD4
	Jm9XtATnhJdFhQaUyzYL144yVbKbivhej37+5X75W5lyCRcZT8rnGsm+GSz2pYQDwwg==
X-Received: by 2002:a0c:8069:: with SMTP id 96mr42865363qva.1.1558051321613;
        Thu, 16 May 2019 17:02:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjeAEvAUU1re90xLt8IU73AamvfW7zXIY+5hOqITDGyGev4XBozUD6ZAMW6UooTzgg5L3k
X-Received: by 2002:a0c:8069:: with SMTP id 96mr42865288qva.1.1558051320716;
        Thu, 16 May 2019 17:02:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558051320; cv=none;
        d=google.com; s=arc-20160816;
        b=V+E9fTlgb4q9+fL/B4UmXKOempAu/ng3L8eDlvpKPpwRzTrNwKL6acu/o3Mw0b29SX
         oux88NrK0pq+wBYDSW4ekooCBOCaT+xLrdPr8UuctHSOcyU3OMa9izsqubRO+TX4TmF0
         cOPYFxwT2866Sn0qjkFux9e55foFQK349VlYR4kDKvsmOppns1H3hJPTITnhlQvFvyG7
         NVsnm/YOarAn6zjXN4c3CdQfgbKrYkoqG+BXk4mFId8zvWcsmM9AxBN5clGofOpdmopD
         sAGxMykr9HTO6FQ4qf7ebbFDuEZ3f00KAqOZZfXQzmXeHk2G5ounX68mD/IZi0cXknpQ
         +Ciw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=wOL7Y2USzQ9HfFUmu2R99hBKeQx5shjfX/gs/NjLiiA=;
        b=I4JEiEscKwFEPh080oHAyWQUjAiv1bIXSKpSxWHaF1G9uReFsfeNI51ytwy8qdETRz
         RVQqLo+naaKLAVRY6V9DOjLLO//6iOokkR8qmcFa8RLbmeTjI0GJ4J6VKY4CzsLY0vF1
         Y+rePd2PA0gAFvQTzplHlmg8WJDiaK5PFafvPN7kIYCcfqWZFfJxjyTgWtDHU0huOWd3
         eVwgT9MTT5+O6wsspIigvN+sYQ8brA+/8NVOCd54Et7CEeDbCHXoBucoXHSytnaUPzi5
         19L203uVZEy0+Ut+yDFfMQxHI7a5B77KZ1nKmSuCJFCUHWLFwAO0pVmSe/pvzm2GUNhV
         sFRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=goD8WGYW;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j18si4927789qkk.199.2019.05.16.17.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 17:02:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=goD8WGYW;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4H00CXw195918;
	Fri, 17 May 2019 00:01:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=wOL7Y2USzQ9HfFUmu2R99hBKeQx5shjfX/gs/NjLiiA=;
 b=goD8WGYWY/LAAhT5aiZ0jrWwtFG6K8R4fBt8JVShsdYUyQbaHl5ZLD9eG9+qjTQUq4mE
 p/NmNhQ20FZck+Gpa/+hT6rMeKX2wgb6IH5QT9FW53IxeSx8YNJf0N7n/0ZdkQHYEEUj
 vLp/vf8cLl6fC0zr5n+xc0dZYZQAtMMBB37k5cW8kg9DtBjrWIPQXKlvJzrBgdcnqWOz
 p8JItLa1I1LXbi5xwHHri0p09VjJhfQ2YFBbIQOAo5S1IDWzYsxuk/gpqhK7iPeP7qy1
 JCSbEAbJ/APZqXenrBVpFZnuEMK/zySp9evjKGVBOkyt9mQOEe3GfqI3q3mYiUCiZv4d Sw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2sdntu6mtu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 00:01:55 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4H01iJs127295;
	Fri, 17 May 2019 00:01:54 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2shh5grkv2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 00:01:54 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4H01peW018225;
	Fri, 17 May 2019 00:01:51 GMT
Received: from [10.159.143.229] (/10.159.143.229)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 16 May 2019 17:01:51 -0700
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@lst.de>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
 <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
 <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
 <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
 <6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com>
 <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
 <CAPcyv4hujnGHtTwE78gvmEoY3Y6nLsd1AhJfeKMwHrxLvStf9w@mail.gmail.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <d5227f37-4e44-169e-c54b-587c335514c1@oracle.com>
Date: Thu, 16 May 2019 17:01:46 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hujnGHtTwE78gvmEoY3Y6nLsd1AhJfeKMwHrxLvStf9w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905160146
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905160146
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/16/2019 2:51 PM, Dan Williams wrote:

> On Thu, May 16, 2019 at 9:45 AM Jane Chu <jane.chu@oracle.com> wrote:
>> Hi,
>>
>> I'm able to reproduce the panic below by running two sets of ndctl
>> commands that actually serve legitimate purpose in parallel (unlike
>> the brute force experiment earlier), each set in a indefinite loop.
>> This time it takes about an hour to panic.  But I gather the cause
>> is probably the same: I've overlapped ndctl commands on the same
>> region.
>>
>> Could we add a check in nd_ioctl(), such that if there is
>> an ongoing ndctl command on a region, subsequent ndctl request
>> will fail immediately with something to the effect of EAGAIN?
>> The rationale being that kernel should protect itself against
>> user mistakes.
> We do already have locking in the driver to prevent configuration
> collisions. The problem looks to be broken assumptions about running
> the device unregistration path in a separate thread outside the lock.
> I suspect it may be incorrect assumptions about the userspace
> visibility of the device relative to teardown actions. To be clear
> this isn't the nd_ioctl() path this is the sysfs path.

I see, thanks!

>
>> Also, sensing the subject fix is for a different problem, and has been
>> verified, I'm happy to see it in upstream, so we have a better
>> code base to digger deeper in terms of how the destructive ndctl
>> commands interacts to typical mission critical applications, include
>> but not limited to rdma.
> Right, the crash signature you are seeing looks unrelated to the issue
> being address in these patches which is device-teardown racing active
> page pins. I'll start the investigation on the crash signature, but
> again I don't think it reads on this fix series.

Agreed on investigating the crash as separate issue, looking forward
to see this patchset in upstream.

Thanks!
-jane

