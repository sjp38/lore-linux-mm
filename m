Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3943BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:22:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E88AA2147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:22:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E88AA2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 814278E0004; Wed, 13 Mar 2019 04:22:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C49E8E0001; Wed, 13 Mar 2019 04:22:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B1848E0004; Wed, 13 Mar 2019 04:22:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 442A98E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:22:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o56so1138357qto.9
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:22:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AYT6kOY7lTM/7O+kk4iJoixqbn7+/YbzDcC91OF5B6Q=;
        b=ijQvqVhQ3JTZuZ02/spbhvf8xb4IkvVPZskzjUGVCOtB5N64xai/5oZqtW8+f9qSOT
         Z91Sm97nh7xl3AxFQAkA9m+oeeOUsj6a6t6KOV8R0DbbiLhAxM3nSMm0gdo6N8lwqFPP
         fgIXxdDes3frRgsUitCRLJPe5+N55hBEGD6AJMikNh81D2ghquAhlO3pb4YEbZyTtquH
         xHNO4johwsoUfkTwYj/7ed1yFdu6M6LVsvyshIoF/1J1FIB8iX2nzvnbwnD4pJFqBqmt
         79oBURIF3pA17ewF969oPt/Bs8mDGE7wrpCQ987lQH8UoRYKUA7AHKs7AOwrSN4TekYD
         IdGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVIvi6SrmRzTveKEHyjFXDObuIWcyxFxLb95dEGKkMgmzpcm2oY
	5cOsHJu8EVvh8vcOEfPRHIUuT7R+XI8zpYpb7VrjqZRKhYR4Zumjrd38kruo2ytJXeZ3f4WRPzp
	I14I2JyXNOMHXEc4F8glOld1H6qaKI+1CShfo4GI2/4xvlq03rl9N8mrz8/FocoCb6g==
X-Received: by 2002:a37:d91d:: with SMTP id u29mr12613529qki.9.1552465366036;
        Wed, 13 Mar 2019 01:22:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDM0tPsEOinBSKDLhy2KpiMNDgWpeEPLyVXsrubmjkVyob/D6VMmUUGkk4ZObRKZ4X3AAs
X-Received: by 2002:a37:d91d:: with SMTP id u29mr12613495qki.9.1552465365370;
        Wed, 13 Mar 2019 01:22:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552465365; cv=none;
        d=google.com; s=arc-20160816;
        b=fsKh1a7n2xbjhNjmo+78I8T8DnnS9CgFT5K3Bg1nJyCZjMJf/U/CbXG7UyBi6U2u/R
         DVFU/80SxeAqyBUurFj1HsDaRqJMYCnLx86l2hZwtV3Efz+1mgdu6rlB3RWqXZ/luop2
         hxxFeUQx0ZO6WmS3C+CcjhL0jkiFsRB1JOC2qopkRLDNCgvgQufbDvWN5oShokUDC9oC
         aMlthR+l0QoewL5OwNmDmzojpDcrO5oc8Sd+K9DT/vmyuTVvcmseGiahUVUdS0hajNbE
         03gCR1kDHZpC9Q2YwomXCPHjS8wavWCmbaLYFbE8yE5wckKMGsuhJd8WnMnIYie/EOK/
         Y9JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=AYT6kOY7lTM/7O+kk4iJoixqbn7+/YbzDcC91OF5B6Q=;
        b=g3MXgDzAcBaxGgs3uRh+t14h+XkO3srhTWwZSIw92ow5yc4y1hQ9cU7wYK4Jkqz6ID
         j2UNkNmIngkfiCQyizRXOSaJC68LSaRjvxLlObAv0vXRPKkegXT4RwZWnUuXvinjp082
         xF/tOz5kQkvxRorSaWuSfIKtDfz/9GFfIzLSc7ZOuskU/7+Mlh7hGrOXTiBEyAKbDONw
         hTGdr1h4TYOayqWvxaDjEBLH1oxW1raKVO3qWLyQkZDCDHd0wuJe+tyV0Ilz+d7qknEh
         s/7bHV65R+eS5yKOazwDNNIBvnqulzKYXJj3SxR73dmmHNwebvUocj/AG/VO9c944UPJ
         rh1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c8si1555974qvp.98.2019.03.13.01.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 01:22:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F626307ACE9;
	Wed, 13 Mar 2019 08:22:43 +0000 (UTC)
Received: from [10.36.112.43] (ovpn-112-43.ams2.redhat.com [10.36.112.43])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3155718258;
	Wed, 13 Mar 2019 08:22:32 +0000 (UTC)
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Peter Xu <peterx@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
 Luis Chamberlain <mcgrof@kernel.org>,
 Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
 Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>,
 Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 linux-fsdevel@vger.kernel.org, "Dr . David Alan Gilbert"
 <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=pbonzini@redhat.com; prefer-encrypt=mutual; keydata=
 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
 uUHgL9dKIfvpm+rNXRn9wAwGjk0X/A==
Message-ID: <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
Date: Wed, 13 Mar 2019 09:22:31 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190313060023.GD2433@xz-x1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 13 Mar 2019 08:22:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/03/19 07:00, Peter Xu wrote:
>> However, I can imagine more special cases being added for other users.  And,
>> once you have more than one special case then you may want to combine them.
>> For example, kvm and hugetlbfs together.
> It looks fine to me if we're using MMF_USERFAULTFD_ALLOW flag upon
> mm_struct, since that seems to be a very general flag that can be used
> by anything we want to grant privilege for, not only KVM?

Perhaps you can remove the fork() limitation, and add a new suboption to
prctl(PR_SET_MM) that sets/resets MMF_USERFAULTFD_ALLOW.  If somebody
wants to forbid unprivileged userfaultfd and use KVM, they'll have to
use libvirt or some other privileged management tool.

We could also add support for this prctl to systemd, and then one could
do "systemd-run -pAllowUserfaultfd=yes COMMAND".

Paolo

