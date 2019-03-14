Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42F63C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2C972184E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C972184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94C7C8E0005; Thu, 14 Mar 2019 12:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FA1A8E0001; Thu, 14 Mar 2019 12:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7744B8E0005; Thu, 14 Mar 2019 12:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 542888E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:00:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f15so5752679qtk.16
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OJe1gwxvTyTyPdvkL07LBwdfdes+uM484E5SG1vLRyc=;
        b=X51AC3wAPOqy5wwgyxyepp26trFqtlwPcgF6KGftehrDlqRMEYghVF93yvUancPnyf
         /CJK4Imjd80bQPZYoWoMu/kK/Ew8PC1ooCcWFrh4TvuL6m3kMryaUi72baF8LerGh82l
         qKvAhOuPYN2UDB0LgsDLUBmLlLTUrSeCMFymcIi2ZTgqPkwoZ59ybwu0Y0rxewcafGYA
         LKa69CiUR1oQxYOGYtiUk/ycOgezoIuV9xUfTxb43bsubyd0faz3bSFczzzHCHbDmlkB
         q2YOneUkt8fSL2t3jL0YiFYu+PhK9u6hI/v6EyIj8mp6WW9sLIrcF3t0xQ48aO3ThTqV
         TT5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3PgbBXoyTukr9PgaUa3h2lsUkxsJihCJoEgT8CdBxP4CpUIbR
	eWqR6wIqxq/b/kWZr4tg8ZHlxoDDHZcN1Xev7x1zGly6jYLYaymiXb5cuYDtGTpqbXgKgaZu4sf
	M8V6HUrFLdvkEEtR9zD2jttDfi/Qtc0hlcQDJJQq4jp/34edapVw+XLb7asfR5iWzNg==
X-Received: by 2002:ac8:610c:: with SMTP id a12mr2116202qtm.46.1552579230132;
        Thu, 14 Mar 2019 09:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnO1TwKWDBCed1JDfNEiDnDpEzuWOBdKBHmn3oYR+cTIklmL2SCEtAeBhzHBJHC2UlF0+d
X-Received: by 2002:ac8:610c:: with SMTP id a12mr2116149qtm.46.1552579229378;
        Thu, 14 Mar 2019 09:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579229; cv=none;
        d=google.com; s=arc-20160816;
        b=lVxkUI/kv+CWVK78sK6v9UUN9yBERH0aml4Vnq5EQb1nwxDwms6Bb67Qm7GuBLhvxr
         mjPbEZRVvsPzSbdiEqsk5rOpkfwwjyTy4Nl0gbq4lUk45IwLCIq7AXCBkx1Pxfev6VfS
         GiT/6CwHaRC2ppBJAG9IGD90yL3XtviftvxAW0lIwRy3f4D4rvDwNgWoqOCPf5PypFpy
         Nk+v0iAZikAK4XuUOB5aoCfh7E7LypmZ01k5OzTaOrKqjDKT7e8GHf7qSL/E+aCKEzDq
         USTTpct2kbsbWUfEK6BY4u68zdoGYNc2fCS4MZVkJZeOV2zcuOGtvdykw2Yp1nDYHuhp
         4bvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=OJe1gwxvTyTyPdvkL07LBwdfdes+uM484E5SG1vLRyc=;
        b=V5l6KJQgPwPxxrLxoSbUlrm3aaLo1MtpgnM5LMDVDvAdOepM11ruYkSJ1Aj3uflCYe
         0h6gPqKPHLtcNTbMZbP5BWE9BTHMlrm454ylndeBtnLflkM+SkBmluZCJTo760u1eULG
         StOd/Xdkyv+UX+wIxVLQkWP2WWIpDhvPcPzlskiN2A/BeGuscSdhVxHkQf6ujlltdEsE
         jI+af9OinQRxhQJ/EtPo0RMkskXc2oO8bekJZLTfpkF9LT6MlutwtX8B0dbp3Kf2A8hR
         3Ee6ngCgeoYv+2/0qEuoOnVSIX6WzC7AX9UB88X1i9P4A439f2uyDw60GZ/YsDf9iyfk
         S6pA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t6si2471011qkd.132.2019.03.14.09.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 13F1E30254BA;
	Thu, 14 Mar 2019 16:00:28 +0000 (UTC)
Received: from [10.36.112.69] (ovpn-112-69.ams2.redhat.com [10.36.112.69])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DB9D6282E4;
	Thu, 14 Mar 2019 16:00:09 +0000 (UTC)
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>,
 Mike Kravetz <mike.kravetz@oracle.com>, LKML <linux-kernel@vger.kernel.org>,
 Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
 Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm <linux-mm@kvack.org>,
 Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>,
 Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
 "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Daniel Borkmann <daniel@iogearbox.net>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com>
 <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
 <20190313234458.GJ25147@redhat.com>
 <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
 <CAADnVQLakteNHnoUZpOTVNK-ysbmqCRbPDM2XMgM9pWB-mGjhQ@mail.gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=pbonzini@redhat.com; prefer-encrypt=mutual; keydata=
 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
 uUHgL9dKIfvpm+rNXRn9wAwGjk0X/A==
Message-ID: <aa38c1f0-d0a3-fc4e-22ac-0359f6f72d84@redhat.com>
Date: Thu, 14 Mar 2019 17:00:07 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAADnVQLakteNHnoUZpOTVNK-ysbmqCRbPDM2XMgM9pWB-mGjhQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 14 Mar 2019 16:00:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/03/19 16:23, Alexei Starovoitov wrote:
> On Thu, Mar 14, 2019 at 4:00 AM Paolo Bonzini <pbonzini@redhat.com> wrote:
>>
>> On 14/03/19 00:44, Andrea Arcangeli wrote:
>>> Then I thought we can add a tristate so an open of /dev/kvm would also
>>> allow the syscall to make things more user friendly because
>>> unprivileged containers ideally should have writable mounts done with
>>> nodev and no matter the privilege they shouldn't ever get an hold on
>>> the KVM driver (and those who do, like kubevirt, will then just work).
>>
>> I wouldn't even bother with the KVM special case.  Containers can use
>> seccomp if they want a fine-grained policy.
>>
>> (Actually I wouldn't bother with the knob at all; the attack surface of
>> userfaultfd is infinitesimal compared to the BPF JIT...).
> 
> please name _one_ BPF JIT bug that affected unprivileged user space.

I didn't say there were any bugs, I talked about attack surface.  The
potential impact would obviously be much bigger and, even leaving the
JIT aside, the userspace API is much more complex.

All this is just about paranoia, not about past experience.

Paolo

