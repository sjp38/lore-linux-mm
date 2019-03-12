Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA7C6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7684220449
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:00:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HNfNGy6M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7684220449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CAE78E0003; Tue, 12 Mar 2019 16:00:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A1C48E0002; Tue, 12 Mar 2019 16:00:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191918E0003; Tue, 12 Mar 2019 16:00:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E565B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:00:00 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 9so3128897ita.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:00:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=A9gtozJFv5iJI4Lopf5E2MEM4Cit9pl4LJXAm7hrIaU=;
        b=Sd/7c8mcWZtR/R4hdwtYCxaKnP/PMsByVlaPk5C5zAuRSTW4MiRpavabQfmsvV/4KO
         /0VBIA2wBsXMSbfBRwCRCwdu/ZVm3ftzEYsLS5jG8EgY+VTtrB/wd+Y3ZO4312HOw4E4
         4ebc0j4q90xMyIULK9ismdUw8I5OHFi27eawlU0/D0+v6R9YkQuGAJlD9h/PWpblCFJh
         Y7ooXb2gZ7F+OJzxoo7/30lKPlWbBR6SJq2Kb3DmJSkUK2rxuUGDOPJFawS6N9GVOLuP
         r0e75MN06P9J2768jiufXek+hdKyxOJYVyNujFIPMMmbJaV71CeZZkyeJ/RqzOBhH3aD
         0LBA==
X-Gm-Message-State: APjAAAX+Vz+KqDeyVjMdKsBQ4sJtPVm1UC9dnwcQ1Xf0QvVIrKzcP0kA
	E7IAqJp4tCo/4lxy6eCgc90lynoNuFANTKqbMuqYOqkXcUWHaThh/mjkwaXoe8lPE9u8NbuEozt
	MnWO+GkXHgQR1r2GYhLW3FT48y6V2RlefD6lO2cUdwx2VF1E5vmAXjtNfQZNrkb/uTA==
X-Received: by 2002:a02:660e:: with SMTP id k14mr22482626jac.34.1552420800695;
        Tue, 12 Mar 2019 13:00:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza/UYECJ5ZtJIpyzkPm8OG51IIhWOsrtrD+5TOL00ibUoY3UgNKnnx0McG9eQSpMPDxvnR
X-Received: by 2002:a02:660e:: with SMTP id k14mr22482585jac.34.1552420799789;
        Tue, 12 Mar 2019 12:59:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552420799; cv=none;
        d=google.com; s=arc-20160816;
        b=JbgShe697+iLR9VRdaew/L4EE7ideWqSDOeR2xjYOrS1uBY8Eo68QDi5jtzlWlzdmp
         EM/B0FNb+CeJh4AgKXlId+C1Nz/GCM/Ac5s7H+DoAkXRCQ4bhRWnJJVpQ0VRv9R1AfeI
         +aqABolp7vfQ4wdygTT7YVbbabPDf6ghVf6Srms07JkJc2kcEutx7gdQHcO7AZxct1nS
         IyF4CjbfxORjNuOKVjNARhaSX/fXOatKadQXxjUPu/7R+JP9kDz6PJYHH+qusa9I7jdu
         T6f1I2zdBceO1G2k6lttGyc13HOAAEFOH8/gpEBD788mh5E0wFYoaw/QGyHGOTG75T7H
         rUMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=A9gtozJFv5iJI4Lopf5E2MEM4Cit9pl4LJXAm7hrIaU=;
        b=jlIY5YgERUhmaU/qrfN96ay1Iv+ulNRz08zH68TnWSjyi7p6B5edEbZPow9K1nQ5ol
         3TZmH/uTq8Xdverj5qCVN+Q5qjdN5tjSAqh1MqYi82uq4nZb5ei9lhm13T+9ULQaYJtU
         5djEW3Vnn9j1ePJRXvL01Z3WG6pjpgSokCl+cX6YwkqlpXh6gnmgwwHMEA5drkwSZC8x
         E/eHC4gzV+o1cGXaEGVKbtRU8k6VbtevL2T77BR1TFcRC7Dmz5k7sA0PGHrOEjz2nFUy
         9NrVEY1z8AQM0LV5Z0ES/w3Olo195UQLKCYZeaAIah1LDvH1/sxMBqXDVHQTT/Tz3BMc
         odpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HNfNGy6M;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y72si1920347ity.16.2019.03.12.12.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:59:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HNfNGy6M;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2CJx5MX109207;
	Tue, 12 Mar 2019 19:59:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=A9gtozJFv5iJI4Lopf5E2MEM4Cit9pl4LJXAm7hrIaU=;
 b=HNfNGy6MLKML/gftAsYYxKcbb5V2y/J95OrbzuvtCMlRlroDupWboAUPv6W2O30oYMH3
 ncwOenKTSc0IrwSt9A3qYnSVWRluJGESnk5sjN3vjVW7aTSPQmdNXjpWt4YEnnrtKoa6
 JF6gUNTa/wls2MtPfUvnrqu+savyt/Nfvo/vc6kqFyds8BSDgVl9zn0/mJCChlEAyhgu
 FB+t84+PjLGD/M4P79fuI+t4fXhgUFvRtz6t0p0Dp5gainpkfW40/LpfYsLm31TtG1t9
 XPwJNkEEqvHugD4944rzrqiwu92EygE1hbnPSr+3JJKwjEQOZQ1v5PBAyGlH05P+kvhd ag== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2r430eqf9m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 19:59:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2CJxhY9015680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 19:59:43 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2CJxbr9011784;
	Tue, 12 Mar 2019 19:59:37 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Mar 2019 12:59:36 -0700
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>, Hugh Dickins <hughd@google.com>,
        Luis Chamberlain <mcgrof@kernel.org>,
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
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
Date: Tue, 12 Mar 2019 12:59:34 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9193 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=681 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903120135
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/11/19 2:36 AM, Peter Xu wrote:
> 
> The "kvm" entry is a bit special here only to make sure that existing
> users like QEMU/KVM won't break by this newly introduced flag.  What
> we need to do is simply set the "unprivileged_userfaultfd" flag to
> "kvm" here to automatically grant userfaultfd permission for processes
> like QEMU/KVM without extra code to tweak these flags in the admin
> code.

Another user is Oracle DB, specifically with hugetlbfs.  For them, we would
like to add a special case like kvm described above.  The admin controls
who can have access to hugetlbfs, so I think adding code to the open
routine as in patch 2 of this series would seem to work.

However, I can imagine more special cases being added for other users.  And,
once you have more than one special case then you may want to combine them.
For example, kvm and hugetlbfs together.
-- 
Mike Kravetz

