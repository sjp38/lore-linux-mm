Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEEC2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B87E21479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:49:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YumcioM4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B87E21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18D9B8E0003; Tue, 19 Feb 2019 15:49:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13C948E0002; Tue, 19 Feb 2019 15:49:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 051108E0003; Tue, 19 Feb 2019 15:49:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C960E8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:49:48 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o13so19000758otl.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:49:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=vTwMs7LhCBRIWokSUAo3LAC/sg2rWNPJOXIoqkEFMek=;
        b=BwO9FmAv90+a3NgPkDL0h5W/wCieNOaXumE5pssNQc1TJvVn992kd75o8TIpzdRV5F
         qQd1etSWCfG7fa95ZBh5/Uy2up+beR+luX5xo0ZCaBuRZzU3kfoAwGhfPcjJ1aIeWuYt
         bI8GDNjI7+lQAQHWA4ulxcIzUWUSE7S9CROrPz/2UDOVFokn5/BcwgigOnGOkybfgOwC
         CfnJgAJ3IpkL7wlLOG8vgyUS3bjbPlYeE7PYZjPP+H+DZWRpXAzPFIE5PZSSP/fvlzeC
         vDLD36v5TxZ41t0PGNCp7pmqbQP2vcIiV/5ApQChM3sHwN3DCahJIQcYc8AnatHAnM/y
         PCaQ==
X-Gm-Message-State: AHQUAub3shvxQDcqicL+52rtc3xRFY9umXVVYA/Y0+KoSbsrBsC1k1my
	omZ8VoHo2q6VKo/svy3CQIy4V1RwyB2I0pJTshPuhhBzAUV4m7NXjiGlX/POlcjN4tHwj+mxdoh
	NRJDGPEe4VTsHgLSji+W/veW5nuOIaM37ChVCoVS6vgeTbJClDcFzq7PbSptsufwVdEqjHZlv6C
	/ANyUzfc1MWMGAQff3vAj+3otAhEyEEl1CqVNpWt21GcHNbvAR5aL5YwSoHhQsyTDzTViKCOcYc
	/Zab4tKjp7bxlhyWgMPzxLLkWuHnW0wUvyk+fPPWdA2B2uhjJS9CeaOP85iUNzmyLp0yfCPyZFo
	aofCs5Gvh+mIbLOSbFSU+xVz/pQwdVJc1qH/iLKBbc7KCLeT1jK4efX859PoWjmg2TN1AUSehNr
	m
X-Received: by 2002:aca:4008:: with SMTP id n8mr3581940oia.161.1550609388555;
        Tue, 19 Feb 2019 12:49:48 -0800 (PST)
X-Received: by 2002:aca:4008:: with SMTP id n8mr3581918oia.161.1550609387872;
        Tue, 19 Feb 2019 12:49:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550609387; cv=none;
        d=google.com; s=arc-20160816;
        b=JsiIWbzwkF/zc0JkO3SeYCQpIFAm/Q1q4mbPvB577IYY3KLjS9AZblOe6FAz9LbLPg
         QxRBd8KowDBF/RXEG7tJbZ7js4/sEoaVkJceLRqKprpXB+Idn/ZjRRztU7OBsbLAqggQ
         M6gcYqCqD4u8hjm436qBV03osGdbSFF03XAVARkcQ/szjPLPRQqOXiW7At49k1DedXVi
         aq3bViDA4cXDRrlQbce1RhonPIqIG0uWJyOStHE4rsIDC4szRhwnNVuxn0zcHNxo+yu/
         eQG1AWxJnLhdtis3Q3LUnG/fVbvT8J16wD2NWQgT+5M5PuVF6rjpvJXnbj+bfuahpskO
         Ww8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vTwMs7LhCBRIWokSUAo3LAC/sg2rWNPJOXIoqkEFMek=;
        b=pjb16zXWDk03gwq0/UWA+v0y0VcUBtQ+Ag/2Nm1FUtzeCyJqG13dql+VMidkngGb/Z
         3izoa2h5BV3GT+/ln546l2Nof7uwJLBEHMB2kMHq0vqDhMHZeCJhhnd8X8wOzBkHIUv1
         2AzkBFcb6V1M8lYtwdlKSX1bwJY3er/efGIEA/cpnUTpnLr0S8gnmMAXYF99ON7GCKED
         0EN2q8u2abmFKJ2RD7t5Bw7Hhd3y314jKOpUHhzyCNV8Oz49xLqfJ5ssk6zVIocbFQ3R
         /+AQ9Hv39nJvKJSoWTutQzrmv6y5fgGQ8Fie+pftNrBZANq8zJScteJSGGtSlYghpb4P
         gvzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YumcioM4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i130sor9217326oif.95.2019.02.19.12.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 12:49:47 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YumcioM4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=vTwMs7LhCBRIWokSUAo3LAC/sg2rWNPJOXIoqkEFMek=;
        b=YumcioM4qmHVdnvpAAkSBzS5KKalQVl9aUwWD7tjIFoZktrmgw5R2dpVKI+c3AXdrn
         5C25ZgJEJYtn1IOhlL2Bbj10da7+HXls8zmr8vqjVZDXuOge7VqWmIrCadgPyTtu3fSG
         gc9mhS/E0LiYOmVm58yxwsMY738icUQ6jTCFRYJoqTWMdsqxzYb2KJGKP9uWCW/YPG8V
         IHmBIdqSJ2EyWJYWd1N8KA2TRUt44I8XyuoXB5sw7zDzO4/RJvMeTA/GvIZYCHPxrWsu
         wEAjzdpnMdDVg59Ek1qf4F9cuSF7ptRBRSqx5utCRrujMrfT9629rlkJno2IT9JM4mUg
         Rsyw==
X-Google-Smtp-Source: AHgI3IZVGH/kGTid9uP882/dFlhil2xpi85z7X5itIZnkAkdaIaaAhjJuIIoTqjGmZ/y+RZaHUaqk00k8RcuCUYw6z8=
X-Received: by 2002:aca:fc06:: with SMTP id a6mr3841379oii.0.1550609387267;
 Tue, 19 Feb 2019 12:49:47 -0800 (PST)
MIME-Version: 1.0
References: <20190219200430.11130-1-jglisse@redhat.com> <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com> <20190219204017.GP738@mellanox.com>
In-Reply-To: <20190219204017.GP738@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Feb 2019 12:49:36 -0800
Message-ID: <CAPcyv4gZ=aJSixVwOCrxAf_fn4emx68_80SSFQdzGvvN0mHLGg@mail.gmail.com>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, 
	Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Ross Zwisler <zwisler@kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, 
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

On Tue, Feb 19, 2019 at 12:41 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Tue, Feb 19, 2019 at 03:30:33PM -0500, Jerome Glisse wrote:
> > On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> > > On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> > > >
> > > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > >
> > > > Since last version [4] i added the extra bits needed for the change=
_pte
> > > > optimization (which is a KSM thing). Here i am not posting users of
> > > > this, they will be posted to the appropriate sub-systems (KVM, GPU,
> > > > RDMA, ...) once this serie get upstream. If you want to look at use=
rs
> > > > of this see [5] [6]. If this gets in 5.1 then i will be submitting
> > > > those users for 5.2 (including KVM if KVM folks feel comfortable wi=
th
> > > > it).
> > >
> > > The users look small and straightforward. Why not await acks and
> > > reviewed-by's for the users like a typical upstream submission and
> > > merge them together? Is all of the functionality of this
> > > infrastructure consumed by the proposed users? Last time I checked it
> > > was only a subset.
> >
> > Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
> > vs UNMAP. Both of which i intend to use. The RDMA folks already ack
> > the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
> > were ok with it too. I do not want to merge things through Andrew
> > for all of this we discussed that in the past, merge mm bits through
> > Andrew in one release and bits that use things in the next release.
>
> It is usually cleaner for everyone to split patches like this, for
> instance I always prefer to merge RDMA patches via RDMA when
> possible. Less conflicts.
>
> The other somewhat reasonable option is to get acks and send your own
> complete PR to Linus next week? That works OK for tree-wide changes.

Yes, I'm not proposing that they be merged together, instead I'm just
looking for the acked-by / reviewed-by tags even if those patches are
targeting the next merge window.

