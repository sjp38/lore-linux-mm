Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FD14C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:40:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A32821479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:40:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zHFthObN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A32821479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95AF48E0004; Tue, 19 Feb 2019 15:40:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90B1B8E0002; Tue, 19 Feb 2019 15:40:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FC2D8E0004; Tue, 19 Feb 2019 15:40:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57F1C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:40:51 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w20so5360339otk.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:40:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=6e/PhI+bFWIx+Lv7REz9NfhuoKNC/7yafPmR49v56Ec=;
        b=WZasSkKis0ILdSFkUZ2koH6UJpMm6oatr3TVKUKon2/vK0TJL+zDxxSCQa7vjCmsec
         OUWWTDep7pBI215cE92f7d4N8N2MpwW1uHgYD/bI9EKxRDiZgEVggtxBm7l0iH9xpAJ+
         fPVPhhfJb7Asd0Dk3NCqoa1zOltKL3Wi4asMyWrMty902VhBMDujPCge85Vd6UvS9XFe
         5ddKFTKK2gfWCtLOSGca1ZPomLwWhMoYECeYD470Cu+C4kbx7viv+rggDyi42Dwhw72T
         4iW2afBW5t1tURiyF9yr5ychxmPcaXBMGgEbsYjn+ZFuLUnmj3eBHW66sVKs8KZNUnvf
         1HIQ==
X-Gm-Message-State: AHQUAubeJbwxZBDUmmaAyeiJ/IrHOCfjUDiCdYpE3zmB+N/ftZyXo4Pw
	D1bcUR/9Q4C2sAtP7zZB3Na0PxLAtq/JV00JlleMUi8TIFl1bqvHrxJZSG3/buLAbOcTfptnqdu
	oysKCYt/5Yyd291FgUhZkEJfX18Gz+Il+d73aX+riy5+qZkx3j2fb/mShMeFRjPKID4w97fBzwf
	rGSH7oGnxDVWWo9LRN+RdoYmp8jn37MPuNjs3kQXnPYEmRs/258DjAKDKoU/1qp+W8hw6/9/Sv5
	cWSApw8DNd51AlonlJnSF+ot/lBPvwWum4BPjzq+M7PWl2Egm1kQ4Xa3IhwNv9hz0H1DyqsEKcA
	j4ARocVqXx0ckAB4pudCDBtTvx/qusM/uopk7ry7d/WN+TTQXXy2MqFHUlTKtkVfch8nHd6ScGT
	2
X-Received: by 2002:aca:3586:: with SMTP id c128mr3830193oia.47.1550608851102;
        Tue, 19 Feb 2019 12:40:51 -0800 (PST)
X-Received: by 2002:aca:3586:: with SMTP id c128mr3830147oia.47.1550608849916;
        Tue, 19 Feb 2019 12:40:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550608849; cv=none;
        d=google.com; s=arc-20160816;
        b=fTnH7UbWyP1ioGddAnwxM414f1TLZg290AIrCChKBvtplw4jnSnuxZgJA93oSj7ueT
         Cqi2hT56fP2VKTgnIsAUuRoTn9OhffUEbVgbeUN/jfPiwiusA/OFxNbi5TM2OXHG73f6
         Px4Qk0n6zFRNIJqnd95EgClTbgaSDbrNWcucfUDHYxocfehg8n2qTHMlQHVpov5n0cOz
         l7/AZObOU3hlHpwoLyDsKr/NVnDs8A4EMPThvu0HiD+LhinOYh4DbE7MPxoJhmUO4Sw8
         lOnv85GHPntZgG8W5Qlt1qGP/DnGAC0Tba5/NSxbLi3RypUaNs3/JvKTRpd5y0wcJItX
         rY6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6e/PhI+bFWIx+Lv7REz9NfhuoKNC/7yafPmR49v56Ec=;
        b=gkJso6mmQztbnBSbf0jR8Mfqvehy9D780OrqFY1gcrpO6pQpKzl8dtOdn4barETWwC
         N39FTIWHrdNY2PNf0D7TMNbDPEjmCZTn1eKRDMjxcL51B/dM6bX1KYIYKtSTZimy8U+K
         5MJEC4gS4FybFemNk0VpV1zGlsZlOul5+Qy5sHi+qWZUs2udOe0MH72iMf0jKNWe1OCq
         XiqZFS+Egi6+1UjIG6+k23/DFQBEBSbFmFprCC1WTXe+bd9g2FTEcoVcHYpua+cjjMA+
         xc9PcAZu96+GKTPnm+Bo1+s09IbiWlJwNcnpRuAEJ7Cz2cDq0+U/+7sOdSPC0cJRDi4t
         2BUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zHFthObN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor10161035otl.54.2019.02.19.12.40.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 12:40:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=zHFthObN;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=6e/PhI+bFWIx+Lv7REz9NfhuoKNC/7yafPmR49v56Ec=;
        b=zHFthObNzMO6Wc7YyDhk+tFHqf2fA8+AsQR1C0Uk7/H4vLUX1k0uvtaDJsKnxkxgcj
         IUfkg9gFC/+5cq5+xvTB293oS25yYNO8YJmq9EhXhShCHaFvYaJoivoa8Gv7oe2GA/Le
         9pvroJIvfoYYDytdtguqQ+TzMFwud3UFetr1OC2HUvWEzMy1rolPY4zN3IRWUqdpykDP
         0vU+KmwMUXGrMyiwW80eyEd0CnPXnvsoKD3vhRYyhkxVC3a3SVg/vqPGrGjKNOxJDrwp
         5P+5iKmDVutU1C5Ozs+45KVHEwPFm+bIq8q+2kRdZG2OpCqIrlpOnjHsKcEfsJIqwi7k
         u/Tg==
X-Google-Smtp-Source: AHgI3IYo5ZwqtOq1nvE1yY2DRXShXZdfdFXpQ5b/aJzu9kNF3d06i32LdvtUyG3xjt4DVHKYvUqI7LjdHhbceRUPRa8=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr9992906ota.229.1550608849540;
 Tue, 19 Feb 2019 12:40:49 -0800 (PST)
MIME-Version: 1.0
References: <20190219200430.11130-1-jglisse@redhat.com> <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com>
In-Reply-To: <20190219203032.GC3959@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Feb 2019 12:40:37 -0800
Message-ID: <CAPcyv4gUFSA6u77dGA6XxO41217zQ27DNteiHRG515Gtm_uGgg@mail.gmail.com>
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

On Tue, Feb 19, 2019 at 12:30 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> > On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> > >
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >
> > > Since last version [4] i added the extra bits needed for the change_p=
te
> > > optimization (which is a KSM thing). Here i am not posting users of
> > > this, they will be posted to the appropriate sub-systems (KVM, GPU,
> > > RDMA, ...) once this serie get upstream. If you want to look at users
> > > of this see [5] [6]. If this gets in 5.1 then i will be submitting
> > > those users for 5.2 (including KVM if KVM folks feel comfortable with
> > > it).
> >
> > The users look small and straightforward. Why not await acks and
> > reviewed-by's for the users like a typical upstream submission and
> > merge them together? Is all of the functionality of this
> > infrastructure consumed by the proposed users? Last time I checked it
> > was only a subset.
>
> Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
> vs UNMAP. Both of which i intend to use. The RDMA folks already ack
> the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
> were ok with it too. I do not want to merge things through Andrew
> for all of this we discussed that in the past, merge mm bits through
> Andrew in one release and bits that use things in the next release.

Ok, I was trying to find the links to the acks on the mailing list,
those references would address my concerns. I see no reason to rush
SOFT_DIRTY and CLEAR ahead of the upstream user.

