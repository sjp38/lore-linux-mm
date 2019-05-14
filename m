Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D584C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23C59216F4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:04:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KHiq4DTx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23C59216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9466B0005; Tue, 14 May 2019 15:04:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 879636B0006; Tue, 14 May 2019 15:04:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 741C06B0007; Tue, 14 May 2019 15:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47D3E6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 15:04:52 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id i21so925otf.4
        for <linux-mm@kvack.org>; Tue, 14 May 2019 12:04:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3MJ8G8iFv7+woc8MxzlUA/t0B24IADDceJ2Iwj8h/Xc=;
        b=TEdCn9c+YmBC5A+2lf5crv+K2mNO8gdrO3c1gIeoxP5OUwTTlBrnZbvnpUFVNPR407
         p2RWa5zcBJQlSeJ3txHPBOFnaMfmERAyFjL6C7KMIqoB26w69qXz/rFDv+iyWf2gYZn6
         h7AP/Cwmc+ZjN8EuBTJYkq5raVeEchs2ZwfDJM7YT7m9KAm4Ir4qmFk1nDCPdb/7Fkbw
         VBVMGEOXdnS59erKmFV/ysebett3CHwhL6YRIXBOpVN0/1rQE+1XMH2vqBgah4syP1cK
         3EVRZlNQ0tFhn7OBjlWHj9i8bBchusjoAR0c8ieWfTvDlKBXheGr5y/6286TNBL02d4Q
         /0rA==
X-Gm-Message-State: APjAAAWejJhRZGIDJx0WLCitd2WClWUtGr85jLHRFZI6Ebl1pJ1CNvOA
	vMk/rUFHqp1c96oP95OpLeYm3E0LFJrs4TDg2zDWOCCwK4/NshGDJdNEk58fF8kRG3IMhMvsFIi
	WJB8PoSzPCKdg9Xl67ssDajZsmOatarW7S2LIt0KPvC/UVkbsQkxfqa7MmeWEG4hndg==
X-Received: by 2002:a05:6830:148e:: with SMTP id s14mr3633024otq.54.1557860691917;
        Tue, 14 May 2019 12:04:51 -0700 (PDT)
X-Received: by 2002:a05:6830:148e:: with SMTP id s14mr3632979otq.54.1557860691143;
        Tue, 14 May 2019 12:04:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557860691; cv=none;
        d=google.com; s=arc-20160816;
        b=IpXlFb8SP7Kyw/GXqAT9E9nSKBjCW1WuqhkZsR247U9NE2lL6EAFwE0Fz2jHIS+CsA
         K09QC2UKjUdb0Mm8UaurO48dIpDQ8rXGBet9XtYDlQE2+m0o4YfMsCjBs0pRnZLSViYJ
         nxRcT2NgvrPOtjFjh+eY4cR9H2/HyzS0+k13RHyljE0ybr4ZCIvPXfxWX/uSEAB+iexb
         gJLe/ytcIShikYQNXBkJQEV1GZB3TNp2zzs4rXB+h8YFy2dz8mGi53y+bfIQPqFuzYQr
         mBqTDkexzFrtmTY9efozLL0JaN9zqi9UStXB6jJv+TGCiEnqiXxWk/P/irwiJr25CAT2
         ucWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3MJ8G8iFv7+woc8MxzlUA/t0B24IADDceJ2Iwj8h/Xc=;
        b=Gwn1BYhpHl2wYNJ79mUbbkZxo/JSro4XiGCVl/h86CRWtgzUqkdicN4PpZiVLw9tEe
         74cPJRqPC8sP/GPIZwBfct7vZfk5M0jilYNy/t11XFt37/iIehE2BMHd/+jgCmb4ZOPq
         Ty57CwuGsOdgvT/gzh+vtciUlMtpt4G8eoUS8L1zu25qL+mY/dqURH6cfb34gXztbDjr
         p0Nw66gbtm1LKjAGRQ1j2O5QMJlUZZbz3luptIFG8yRtrh83eZ27nWiQPQsEOJA7aQ7h
         DwG4pN1x92jDDPUQvs+j4+ibc483bHVkOKsZiLNDlnaCmouenAh+Cyzo2gB0HuVr3FZ4
         3GnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KHiq4DTx;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s130sor5279377oie.27.2019.05.14.12.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 12:04:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KHiq4DTx;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3MJ8G8iFv7+woc8MxzlUA/t0B24IADDceJ2Iwj8h/Xc=;
        b=KHiq4DTxHeWZ7ZhUHDu3H0zQSi38koEkJT4e3DrcIHpodiGs1HmKFmBuIkUh6+Jaa6
         Y/6A3+PwUYWdyOE3xHPlQjkdirSldkEQvcF+hSK5PhGF+ve9zGZzPoeGLFq3W6qtz6NA
         kemlQvGyqbc8CBla4gR77VFkJN2TIyWfePCyJM6m/C4rSu7hdxOK6qSS5wXzCwiLJPjR
         EFV9Qt/uXDgOed+YJWpYGiaa+/VXmapf3qo/gqjYzLasnINwuvH9MOZ9oX19+TJjCCEw
         7PVMvruc5jDesaE1Kc1h+pAZwRVdmIsHKWevuatJQOKhRbc7N2LS+/XL5FBeHjMz/aOi
         iGTQ==
X-Google-Smtp-Source: APXvYqx10sN10v6S3En1NMksHnyYHTQr2N9LW12pza7Vp5Lf8RW1bTEysUgnoVyxZuM89zNVotYaW0eHbtxS8r7LtXQ=
X-Received: by 2002:aca:ab07:: with SMTP id u7mr73100oie.73.1557860689951;
 Tue, 14 May 2019 12:04:49 -0700 (PDT)
MIME-Version: 1.0
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com> <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
 <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
In-Reply-To: <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 14 May 2019 12:04:38 -0700
Message-ID: <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Jane Chu <jane.chu@oracle.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, Andrew Morton <akpm@linux-foundation.org>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 11:53 AM Jane Chu <jane.chu@oracle.com> wrote:
>
> On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:
>
> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
>
> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>
> Changes since v1 [1]:
> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>
> - Refresh the p2pdma patch headers to match the format of other p2pdma
>    patches (Bjorn)
>
> - Collect Ira's reviewed-by
>
> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
>
> This series looks good to me:
>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>
> However, I haven't tested it yet but I intend to later this week.
>
> I've tested libnvdimm-pending which includes this series on my setup and
> everything works great.
>
> Just wondering in a difference scenario where pmem pages are exported to
> a KVM guest, and then by mistake the user issues "ndctl destroy-namespace -f",
> will the kernel wait indefinitely until the user figures out to kill the guest
> and release the pmem pages?

It depends on whether the pages are pinned. Typically DAX memory
mappings assigned to a guest are not pinned in the host and can be
invalidated at any time. The pinning only occurs with VFIO and
device-assignment which isn't the common case, especially since that
configuration is blocked by fsdax. However, with devdax, yes you can
arrange for the system to go into an indefinite wait.

This somewhat ties back to the get_user_pages() vs DAX debate. The
indefinite stall issue with device-assignment could be addressed with
a requirement to hold a lease and expect that a lease revocation event
may escalate to SIGKILL in response to 'ndctl destroy-namespace'. The
expectation with device-dax is that it is already a raw interface with
pointy edges and caveats, but I would not be opposed to introducing a
lease semantic.

