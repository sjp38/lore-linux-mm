Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58123C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1136C2184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A04py3Qh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1136C2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DEFF8E0003; Thu, 14 Mar 2019 11:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9659E8E0001; Thu, 14 Mar 2019 11:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 854968E0003; Thu, 14 Mar 2019 11:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18F838E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:23:28 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id h14so1670422lja.11
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:23:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5TO12yM7WufkWFhciODab08c+uIiLHgK9xAYUtoPnjg=;
        b=FKT7bu/XcfDmN2nhTRvkDOKBxFv9jHztFapEF3L0CuJ43/qGKtNm3Cm9yXqCUvXtZR
         5bRk6ay+DcGF1DmrwltrbZiIvTHmDD2c0n8SLVRIuwWjPq7RnQMfp4tedyMGR1IM94rF
         qDLVgQ5WVHYRhbA1ceiopr6R1mMZlt7W0x/nkkMEUYqfmLSLmGXAwKHbEpKEaNt3HgB5
         SAFmQ1AiTs+MLVMAKV9vqEeNE4tnzFsZbKRhXSmkibT4L50HIwgk+VCNo1w/gOkaTKlf
         zXDYxHGMnmVFOdlIHvRWM1DyLK1srdNGBPMIk2vAPQ6i6n5CXsWV6kv6+u87D3gKHVfg
         j9oA==
X-Gm-Message-State: APjAAAWIkxjjP3B3XeRPkrbDUCl8XG62S9GO5GKOmJ+FrOpVT9Paqvcf
	NnwZHzuVPLb3lK+ovBtVDTedSdGjlr1ItvWi7umJP0H1fsQ4hz4xCcu42w97xbikpsIJ+dQOdy9
	m5fkT3ZCJHT8FY3CDwozVoosbq470FC1IG56vQIT1XGsaPspTiamCfIQJ7nZKNlqbpfE0AH199f
	AQinmOgvojZ42bj5Mk3jwY5s3yJ/MBOjeD7CKezke8fk/8hiVz6LYL2EPs4IaXkNVnIf+CeEKZu
	c2+CD6B2wyYXRltUVSffoNtlsIcJCWyJAGGrgO/BQuC4qKGXq+RrpeIr7LWwNQIs9qO5nPvw1KE
	QB+YPOkp3Fvdwc8IP0XbIR5nmxnuxhcXtqfMWgxthNLlmagrmKaUrDhXNKKz7uQ9fGvbHDDdBqH
	J
X-Received: by 2002:a2e:2f04:: with SMTP id v4mr27070463ljv.129.1552577007214;
        Thu, 14 Mar 2019 08:23:27 -0700 (PDT)
X-Received: by 2002:a2e:2f04:: with SMTP id v4mr27070415ljv.129.1552577006017;
        Thu, 14 Mar 2019 08:23:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552577006; cv=none;
        d=google.com; s=arc-20160816;
        b=yfkYH1RlFxilLU2UnYlYWy1J+rc9GSU/hUUB2DaXjt3FbPfuQSJrh7HeEj1U04Sks7
         /nevkLV8Najn6ld/rHZtlI/+WIf/GYd5mFJ4sxzOuGuKna9SOcEtU6eNyr6YuMwzzdRL
         /WWMOnsSouxw9eISPtul36LrNSynkJFLZhAr2Xayhuj2sHWL6h2JU/cT5dSaOlcDRJCY
         HRceTx5O/uvcy5XfzsRitOjvtjZTWP+1IXSVbVWgrnSc4RXEKt2SSgFgl49dKZsRudpq
         +kwsfyV+v7jhx2GGmEF6J9OB7EO7sCpTSf/Dw87w4yMhYtzN8OnKQu52geB5flRhZKZu
         gtiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5TO12yM7WufkWFhciODab08c+uIiLHgK9xAYUtoPnjg=;
        b=B9b5W9af4Mpn7bdcILpeQlxJJ3Vcj5akPoMF6UkGKdK5v1hvLedym92HX5rlGaOErI
         vbgtuhWgpBeZZw4CWjOyxf4qnQggBGwrUwjVOzIG4dWubrYixICOXuPIT2bH0xgCc6MG
         hBa4o5+aB3RoZnoaQSxj+KBnF27CQ+dK80Px+zHNVry7s2ZUMzsQV9BkVLNNmRh85rgX
         teKXB3t7KkYzT4+f/VMsFZk4r7cm3WC2HbjzOPv3AtqjyKSBLFno98G1yC+2jTEAlpm1
         5I+hAR4Ta+4IwNrO2go4wM0vuArp/9tBijYpbfsFjpXG565iCRTdxhJMzKuGhQPMAygJ
         fdQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A04py3Qh;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor49487lfk.53.2019.03.14.08.23.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 08:23:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A04py3Qh;
       spf=pass (google.com: domain of alexei.starovoitov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexei.starovoitov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5TO12yM7WufkWFhciODab08c+uIiLHgK9xAYUtoPnjg=;
        b=A04py3QhidUEtRAHxPxTRn/F0L8fiHLfTcI3ptvIahJ4eXSUgKDbbwXsW91oGBQsfF
         S08CxrQDGCZasd03tij9Z3xNLDPJq3NpBSbEXuXr1bOTloe1Vfr1F/N8GNB1ZztJFcI6
         2Jwv7i5eR5SHT7+T2ToYx6LSfA7+20TDZL1usrloJSIhi/tkSKCN4uRmDIN7XWyxwn4F
         GrKafH9Ov6adDQ5sqRFjDIyx2w4EJ+eRFiSXwoeJi+yy7x0UgHF6UNGuR3Xf4AUNYOed
         2e0b982fIq3+EdGb3RynlzXo5hqDeuWVdGBZWVXhdZZsz8Y+Nin+76LA+ON3wpr1kHDi
         8D0A==
X-Google-Smtp-Source: APXvYqzRC8LBbbd9Z4o3g/WcEnkmCwELLtyDuivnnwdj+alwtyYDSvB1rYiuEwroOTFRphbRB16BnPKtUiqnNqtLyWU=
X-Received: by 2002:ac2:4343:: with SMTP id o3mr8059614lfl.129.1552577005440;
 Thu, 14 Mar 2019 08:23:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190311093701.15734-1-peterx@redhat.com> <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1> <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com> <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
 <20190313234458.GJ25147@redhat.com> <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
In-Reply-To: <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 14 Mar 2019 08:23:13 -0700
Message-ID: <CAADnVQLakteNHnoUZpOTVNK-ysbmqCRbPDM2XMgM9pWB-mGjhQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Paolo Bonzini <pbonzini@redhat.com>
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Daniel Borkmann <daniel@iogearbox.net>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 4:00 AM Paolo Bonzini <pbonzini@redhat.com> wrote:
>
> On 14/03/19 00:44, Andrea Arcangeli wrote:
> > Then I thought we can add a tristate so an open of /dev/kvm would also
> > allow the syscall to make things more user friendly because
> > unprivileged containers ideally should have writable mounts done with
> > nodev and no matter the privilege they shouldn't ever get an hold on
> > the KVM driver (and those who do, like kubevirt, will then just work).
>
> I wouldn't even bother with the KVM special case.  Containers can use
> seccomp if they want a fine-grained policy.
>
> (Actually I wouldn't bother with the knob at all; the attack surface of
> userfaultfd is infinitesimal compared to the BPF JIT...).

please name _one_ BPF JIT bug that affected unprivileged user space.

