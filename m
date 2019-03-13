Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B003FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 17:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E0C2077B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 17:51:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3VV16VNB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E0C2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD5728E0003; Wed, 13 Mar 2019 13:51:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAC278E0001; Wed, 13 Mar 2019 13:51:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C2FF8E0003; Wed, 13 Mar 2019 13:51:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7669C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 13:51:12 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e1so2115477iod.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:51:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RMimn9X+ayHxW3yKR0QTtUya8qLch5jMuq89RAFqKac=;
        b=osyQvOKDYhoAEVhCQnsy+pMa9/lIGpa0wiR4RNBHfPO85hBEZJFhXZdcc/aF72jlJI
         IRLEe9iWuPFVp2szVfb+4JMGSoRKefWhUzy4i68GgyUgl10P3UYJ/Me908a6+Y4txtxa
         JaN9k1+IK+AvrEEpJp5YqpnWMCD3jvl6XGAvf3wXf4p5di3a7WBTBmG9ZAdp+MmvGbz7
         uFoNhIInFJFcPkYAPKbgi7qICR563c8dKjj7czawcKPCMIg3Lyeiv6bfo46UlOxUe43R
         R7zSRlo9tapq2TZNmW1bF8jpo4QZPyJzchUis23NOHb2ULIji319QH9SLk3gf8fCrNLD
         tufw==
X-Gm-Message-State: APjAAAUSOKTE+1fPu8HpI2D+KwW2hmBKJXlPplIt5C+nQnwyC+lhPEkH
	LRHEv6MLBR/HB8zPiifWGandQueAERwP/fQv93B8TFBMq1YuR/0fpNI8SHkfAS9BgnwSm6uksaP
	S8FMDPV+QnSyLaF46taAXS77x79EMYH4MIepobrTKcEDgyHiTbpb+jSQVVRa8e6qNBw==
X-Received: by 2002:a24:4211:: with SMTP id i17mr2787936itb.157.1552499472096;
        Wed, 13 Mar 2019 10:51:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWhMWskOccYsnV8mtBgP/yD8FGhACx5ZluGCCWECdxBczBoWbVkuTpNVQGqtll/zxHkwOR
X-Received: by 2002:a24:4211:: with SMTP id i17mr2787886itb.157.1552499470956;
        Wed, 13 Mar 2019 10:51:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552499470; cv=none;
        d=google.com; s=arc-20160816;
        b=wvFy1gv6+GS7Bh9yEg2Ye5kBvCuuwH06TEOlvdUD2WbFLYSk39+80DjMT3GLFEaJLk
         hAp9gJoquG4DLvu9sanAKFO4DmQYIwPYbAh8SalW2CZEkV8tNhXG4dn+rv0zoOUpP5wK
         Q689/0IpvvNPzGd8te+vL9fHEt4SDxm006qKGBhK+4ObbZPYE5OwkjksXSWh1rjb8IEl
         jFMICzlF8a7DwsalTUjNs/wPASgGT1YHrLmM5oPHVnAnH0R+WgGIEQyc29a6dJi0Ro+R
         8yxw6rX/H4x2phd0UuvsiiCbjuCgV3OFqEMIABANo/MGaxv3fPoEIcDZI8tOGFrznqNS
         LwBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RMimn9X+ayHxW3yKR0QTtUya8qLch5jMuq89RAFqKac=;
        b=jhMGP56uVL2qQS4Zr7YSZoUZWj8XwCeTDZxDyML6XmIf8DsztKNe0sbX+7sUmsBURm
         5hgxMi3hB90WUpg/hnbyskB2czbM4RQ94B893+DaF3TXO+z/aMiFvA3LiM+Cnsy/ZR9w
         mNppdlFtcN6IEM49f0R8Ka0ISpOlffP3Z26YhoeGAPFu2dosCK10We3e1vUVqbR2EBW5
         nLJvzLnESSjvrcVFaq6D+2JhJ1c6+0Wb95Ro8Bsj1uznP5CgaFM9uMeCVgU+CZUJ7QIU
         8nE5z0qfSR2WvmYFUWxVN6A78Qv50LJ8oE8VvCp1OYRXb+VQNMZBXooZtX8sQ5ZGXhPk
         Hk7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3VV16VNB;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i16si5895131iol.111.2019.03.13.10.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 10:51:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3VV16VNB;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2DHn4VU152429;
	Wed, 13 Mar 2019 17:51:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=RMimn9X+ayHxW3yKR0QTtUya8qLch5jMuq89RAFqKac=;
 b=3VV16VNBm3L6MCzCWFd5y/4Llk+2zXObtCnzb6fGGKIin14cI/q9IXBuiumwdTZz7jiU
 eb7ZY4/HA8PWO99pJvixJIPEJe9agBfE8Sq0TQSw22MQq+Z9cXyecoiSVzImmQIKUPJu
 8gT+K6q5ODU5XiRN3SZPNOfFehXfX7N9HzaKAZ1jw7zu5Kxvg0yBD25s4l712ecFnpyo
 eTl/yz7NJjeDtgSGGKz/KnjdHbJ2uddGa+gK6Oak1RibCvA5XCdCc7dXz6Lu8fQP7+Wo
 bJCJRjAAucimZsupSdgA7g6alPYCkLwttR6gaGpbvRaXXsSvLfbQlktHkb/AtzVC2tld BA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2r44wucm0j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Mar 2019 17:51:00 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2DHox5d012995
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Mar 2019 17:50:59 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2DHopDf008087;
	Wed, 13 Mar 2019 17:50:51 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Mar 2019 10:50:51 -0700
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
        Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
        Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
        Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
        Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-fsdevel@vger.kernel.org,
        "Dr . David Alan Gilbert"
 <dgilbert@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dd56566e-7b7f-51f6-bf01-ffda530a8073@oracle.com>
Date: Wed, 13 Mar 2019 10:50:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190313060023.GD2433@xz-x1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9194 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903130124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/12/19 11:00 PM, Peter Xu wrote:
> On Tue, Mar 12, 2019 at 12:59:34PM -0700, Mike Kravetz wrote:
>> On 3/11/19 2:36 AM, Peter Xu wrote:
>>>
>>> The "kvm" entry is a bit special here only to make sure that existing
>>> users like QEMU/KVM won't break by this newly introduced flag.  What
>>> we need to do is simply set the "unprivileged_userfaultfd" flag to
>>> "kvm" here to automatically grant userfaultfd permission for processes
>>> like QEMU/KVM without extra code to tweak these flags in the admin
>>> code.
>>
>> Another user is Oracle DB, specifically with hugetlbfs.  For them, we would
>> like to add a special case like kvm described above.  The admin controls
>> who can have access to hugetlbfs, so I think adding code to the open
>> routine as in patch 2 of this series would seem to work.
> 
> Yes I think if there's an explicit and safe place we can hook for
> hugetlbfs then we can do the similar trick as KVM case.  Though I
> noticed that we can not only create hugetlbfs files under the
> mountpoint (which the admin can control), but also using some other
> ways.  The question (of me... sorry if it's a silly one!) is whether
> all other ways to use hugetlbfs is still under control of the admin.
> One I know of is memfd_create() which seems to be doable even as
> unprivileged users.  If so, should we only limit the uffd privilege to
> those hugetlbfs users who use the mountpoint directly?

Wow!  I did not realize that apps which specify mmap(MAP_HUGETLB) do not
need any special privilege to use huge pages.  Honestly, I am not sure if
that was by design or a bug.  The memfd_create code is based on the MAP_HUGETLB
code and also does not need any special privilege.  Not to sidetrack this
discussion, but people on Cc may know if this is a bug or by design.  My
opinion is that huge pages are a limited resource and should be under control.
One needs to be a member of a special group (or root) to access via System V
interfaces.

The DB use case only does mmap of files in an explicitly mounted filesystem.
So, limiting it in that manner would work for them.

> Another question is about fork() of privileged processes - for KVM we
> only grant privilege for the exact process that opened the /dev/kvm
> node, and the privilege will be lost for any forked childrens.  Is
> that the same thing for OracleDB/Hugetlbfs?

I need to confirm with the DB people, but it is my understanding that the
exact process which does the open/mmap will be the one using userfaultfd.
-- 
Mike Kravetz

