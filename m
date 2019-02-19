Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFA60C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 21:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D6FC2147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 21:19:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="mw3KCraA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6FC2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 068938E0003; Tue, 19 Feb 2019 16:19:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2FD78E0002; Tue, 19 Feb 2019 16:19:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF9EA8E0003; Tue, 19 Feb 2019 16:19:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAF188E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 16:19:21 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id b21so14522995otl.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:19:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ivTKQNMtP2X3qCK3twrbZPzFwkoeeZNha+qut1LdGoU=;
        b=kdW/A2u+krQ+rGuwj4J56IbTETSrknEIvECinSNl16hVnO9dgjMWq9jmwXdkWVEAb1
         5pmo0CJE7Qfp1t5RfmDuq8AzKHP6NT8T1fisJ+s2AmUYEA2vUKnoaHzJ6MWfZo92AOtl
         aEZxaT3Ho3NslOd6xFLaPfpq2+gquDKnD20k1l8i8/YCkPAkrWMsZ6ldPfmKVejC/Szw
         U1iznjwIWUsMUMoi888VKBs04+YUs3GgqyGX3aCYvG9uUNk0Kh2GhuJOblwv+dPZ7Yhq
         nX5LdVbpbwFYLpdB+SdyLW1jE0NJobY5YXK0SXQ0VDUI6NAZO2bkYCASsnOMMLxFMy+O
         zTeg==
X-Gm-Message-State: AHQUAuaUqkX//0b4UaHjWJgQ3rQVH8Fho2CgCXouSeF97KQZmiJFGn5p
	BCHgfM9yfg0OWZnsp5Mw7gAoJMvsLuyauLKLtiz3Zh+/b8WOP4e/IVLHnaHokZS/jh/D4tFxVM+
	8DzaQ/ullExW5eCy6ORU9YiHW7wxYI/zzXh1XnnFwN5mHf6KavZnkg3mxmIEAmH5svi/UPmn9k+
	GCSlwQfQPSmO746yfv7+5JbhKy0jI5Fa8cGs0Tht0EWMj1apaNvRqHKChKT2Ce3lihIth5M/MTk
	e0ZJqjKAw6NO1iOqSqvetU2l/BmLkDt7tQKXDaOWPBgRyGHNZIMY24jPI71vCBYtbDBGrl3gghr
	hwPWZ4Nw058mZTJgW4HI0q78kp6lKNgBponbgFKM1gl8+ImRMzMf7fFk/GF2G3YUyv8FnPSWDiS
	J
X-Received: by 2002:a05:6830:125a:: with SMTP id s26mr10886667otp.74.1550611161387;
        Tue, 19 Feb 2019 13:19:21 -0800 (PST)
X-Received: by 2002:a05:6830:125a:: with SMTP id s26mr10886639otp.74.1550611160694;
        Tue, 19 Feb 2019 13:19:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550611160; cv=none;
        d=google.com; s=arc-20160816;
        b=kIj6tW8k8lo/TX+RCmhR9UaCifiV3ZBLHaayht1qtfLyOigrSIXSJyiliStR6Sj9WR
         iVMqA+qysrHo0u6uMbUcy2CeHgXePqjpaPfv46NEJ2+7QsS7q/VyPAg7ohOtd25UmGMf
         QmR5ACZ4zeLdtc1xVHtruUfR70BSSVp8K5AiEU9gWNZYvJ0Phlm1IJLShnvPhvSCH4oQ
         /eBG1pjOfGKk6MH+t2GOgN+lcHEGtSNMM6NsPJOHAME4E6bj8Y53Y9kZKpMIRQ0Wpkr7
         prA8Xj+uVX1C8Ma0KGRjdHUOElwfav1sU089nTc9CvelL8BtUZkjqKURHTfdA8ZpZUxV
         3fcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ivTKQNMtP2X3qCK3twrbZPzFwkoeeZNha+qut1LdGoU=;
        b=tzha4qefhmUK5Ky4IOprdY8dlC8m/SsY5aB/ZZmEceBS4zKLJcljBYhVcGXAv1x0Pp
         c7qymRnclTbWPfoui4ORzvx2RZIKAqhw//ePFf6EKIDCsRojOfAF1br4Ik/1t8JaWt5w
         +B4YnTT8g3xv0htGG+Hlgoh2tPJICCd83HB2FSCRzoiXBSjtF7fdMqCYIdXf2tvMi56o
         dqSULEcaq2n9DYEsm6HL4Jq+NgpndkB5zNlijRHBJ3ZPt3MiDRlPPuqGsIEX1jPQXCP1
         R8Aa60sV735VIqxA8CpCvtyhKyRLHsmXByc3r7gXx41LMQ55440dShaBd5a88U0qThGN
         VzuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=mw3KCraA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor5337775otq.136.2019.02.19.13.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 13:19:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=mw3KCraA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ivTKQNMtP2X3qCK3twrbZPzFwkoeeZNha+qut1LdGoU=;
        b=mw3KCraAh6U31DL397Vc95iRYXQapjrxWfVJNHMKSffaMwJrRHlKsIkWehqf1oB1rB
         6We2AazkMPhkraX7atDrshsNSGfNReBFNVXTQ9l61c0z/6PnNYd8K2VR4n7la7Upv2Ag
         jqnknScKG+/99v4FDg+RcEU0Xnc9flzu8A39Wcr/qCGXj6+m1cif5A/UvdD6nR4GoN8c
         l7y73quixJ1jqGTnxyOfRh65KvtD/vrgVinwbUwjkocUhTW2VpUD/Fbt5Qerk5kl+enS
         gWeky1JxEobjI6fci9qZcPPGtxRlAXPug2eETyzHVLoQXHuEwDq6hCe2Ju7Ek056pfIw
         jymA==
X-Google-Smtp-Source: AHgI3IbgJChOmrYGePyVfdKLtY6nJfYpTxrsBj/auowQtodHJ+dFuWWDIrwwUilMXIUwWa8TcHS8qqUI681XOYGd2G0=
X-Received: by 2002:a9d:7a87:: with SMTP id l7mr11513781otn.98.1550611159926;
 Tue, 19 Feb 2019 13:19:19 -0800 (PST)
MIME-Version: 1.0
References: <20190219200430.11130-1-jglisse@redhat.com> <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com> <CAPcyv4gUFSA6u77dGA6XxO41217zQ27DNteiHRG515Gtm_uGgg@mail.gmail.com>
 <20190219205751.GD3959@redhat.com>
In-Reply-To: <20190219205751.GD3959@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Feb 2019 13:19:09 -0800
Message-ID: <CAPcyv4hCNSsk5EP7+BcnVp-zJjQyQ701U3QXkQyUteQZr-ZumA@mail.gmail.com>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, 
	Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, 
	Ross Zwisler <zwisler@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, 
	=?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, 
	Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-rdma <linux-rdma@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:58 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Feb 19, 2019 at 12:40:37PM -0800, Dan Williams wrote:
> > On Tue, Feb 19, 2019 at 12:30 PM Jerome Glisse <jglisse@redhat.com> wro=
te:
> > >
> > > On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> > > > On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> > > > >
> > > > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > > >
> > > > > Since last version [4] i added the extra bits needed for the chan=
ge_pte
> > > > > optimization (which is a KSM thing). Here i am not posting users =
of
> > > > > this, they will be posted to the appropriate sub-systems (KVM, GP=
U,
> > > > > RDMA, ...) once this serie get upstream. If you want to look at u=
sers
> > > > > of this see [5] [6]. If this gets in 5.1 then i will be submittin=
g
> > > > > those users for 5.2 (including KVM if KVM folks feel comfortable =
with
> > > > > it).
> > > >
> > > > The users look small and straightforward. Why not await acks and
> > > > reviewed-by's for the users like a typical upstream submission and
> > > > merge them together? Is all of the functionality of this
> > > > infrastructure consumed by the proposed users? Last time I checked =
it
> > > > was only a subset.
> > >
> > > Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
> > > vs UNMAP. Both of which i intend to use. The RDMA folks already ack
> > > the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
> > > were ok with it too. I do not want to merge things through Andrew
> > > for all of this we discussed that in the past, merge mm bits through
> > > Andrew in one release and bits that use things in the next release.
> >
> > Ok, I was trying to find the links to the acks on the mailing list,
> > those references would address my concerns. I see no reason to rush
> > SOFT_DIRTY and CLEAR ahead of the upstream user.
>
> I intend to post user for those in next couple weeks for 5.2 HMM bits.
> So user for this (CLEAR/UNMAP/SOFTDIRTY) will definitly materialize in
> time for 5.2.
>
> ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
> ACKS RDMA https://lkml.org/lkml/2018/12/6/1473

Nice, thanks!

> For KVM Andrea Arcangeli seems to like the whole idea to restore the
> change_pte optimization but i have not got ACK from Radim or Paolo,
> however given the small performance improvement figure i get with it
> i do not see while they would not ACK.

Sure, but no need to push ahead without that confirmation, right? At
least for the piece that KVM cares about, maybe that's already covered
in the infrastructure RDMA and RADEON are using?

