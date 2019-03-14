Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 749F8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1161121855
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:58:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FByOVCoQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1161121855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 944F28E0003; Thu, 14 Mar 2019 12:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F3A08E0001; Thu, 14 Mar 2019 12:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 809A08E0003; Thu, 14 Mar 2019 12:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 595F98E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:58:31 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j18so5076312itl.6
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=m0Qhq7RQkG0k0VpgHnhLsAlqR/hbnfn/SgvmpSv7enU=;
        b=YevHkHII0KkmgAgw7sGD428CT70RMv5jdYFBXqLsk6uAknYMf0sO+yZHEOLgC0AgWT
         rL9FVzKQkwnMxjSBRuLIkIYrRQZ50lPGeFxoypwtc2QGs76Pqe5tzJKUuabjioAD5iUV
         dRMF91jQ0DuSkL3SkPnB4spee1rQ9TCHM/b8npU0lvu5ZXsCw92L2dnJt7qKVdjUg9Fs
         VMEpKe9O+xNZQo8zB0d0GVAB4qEW3OZZPjqN8U1Fllv7F2RoZtKYF/AwLrrVRGEmkW8p
         HZ/7k4HzAXUqvZr7cu/dagL8nXv7XBMS0/N60JhQMTryXvdWBIEVnf8RLnmi06To0JPQ
         yPTw==
X-Gm-Message-State: APjAAAWMqO7Km+fax+45kZbaZqujBJQJyDcEOMFZFzkQpk6nyP497030
	TY8ebYn91LpZe7ND4rd7u33M1kKOeLX6U/OZ6D7XvImqVh/BsQcmdliaUIbJxrAG4LAPP1Kikpf
	0QK8b2lTTGnwXBGIe2GeDCFdtGY1ieOsKR6ZtvodBUcNzGdItObJ5dcPVyN/nN5VfTVBcBGMZv8
	bqhO9A8EaM5L44VrRKFVG8YOTT+d1Galo/XKHfS9YUCtiVqtYx9nEHbo8XKQRHPc/sDtHOPVEyP
	9RvArJPhsy2Ih+crlOz23vBNjOINbXWUpJsNFCL+D0CA0YXPQsGvVx1jH2rpF2OgRFryKNhCaId
	kyyfdlTqTmq3eDTLVo3ZkXp47R2JqJj6YZA0mx4yQZCNczyaPk7SVL+CcyIo1dSxdpVx3zLN365
	K
X-Received: by 2002:a24:1751:: with SMTP id 78mr2523852ith.172.1552582711073;
        Thu, 14 Mar 2019 09:58:31 -0700 (PDT)
X-Received: by 2002:a24:1751:: with SMTP id 78mr2523797ith.172.1552582709737;
        Thu, 14 Mar 2019 09:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552582709; cv=none;
        d=google.com; s=arc-20160816;
        b=O0fm9NGLyxXyCZ2roXPn2hnQHiQjGJ539SUTOsG40/XZfedGacxOWDEhuzFc2/n3sD
         Q6Nq/oZO12QQCb+xBgvChFYnHESwVo2mOTp5Xx8I9kfxEyroLIOS6l97r7PWveLkVCGh
         U/O6HRwd+chnmQ+9J3xoFKxcQKIQ8F8QFHqTjD3Cvlk3ewY7/tkQEobDP8Y9yUHWKTBM
         h8Nb+8E8N3QDDq9GOSFviFMrL24wJEDUtShx/KNR0/WX0K1qVo9aQtebIhlf1YNEAezJ
         LUwFYOUTTRNWPYPWQQX6ynxZoDih0MqP0991SoQRYbifPDHFSBUCTnq/lmidT/CSq3n9
         He6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=m0Qhq7RQkG0k0VpgHnhLsAlqR/hbnfn/SgvmpSv7enU=;
        b=Lq1c9GtrQqQEB6DavHBEDrvgah4z2xBWi8kj9QTOIWU7vCjSpCiPSsy2WllrCgi6jV
         vBdwDE2qsVsUVIAHeLnyRo6KqMTjExXguCjqLZVTWUF8zLot7xPETd4GaxzTXvzN/qzC
         Ovw2UIN5TOew3stK9ozSCzBgYRt7EZge5SDJj5eMiPjpCoYEvVN1kMn3eDmdSwiM0RCp
         yDHWNslQu1JR8vBzUJBxcclMAwVFm06r9NR6opw+7WZzrlWvG5rlWcY8bKYMPk7ufMHj
         HurminQIGn3kzpgNKDTRREaK6SzkF2dnqWN2JDJwSW0kwRcRchMrXxMRysenBiO76T1b
         GI6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FByOVCoQ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor2422286jac.8.2019.03.14.09.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 09:58:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FByOVCoQ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=m0Qhq7RQkG0k0VpgHnhLsAlqR/hbnfn/SgvmpSv7enU=;
        b=FByOVCoQHWe+5auSFWp4JPrjHXst6J1LSgRD6Eff5hIoUR4UisMna+9U52eUQ/B6yM
         dz+7zdKIdObcaheGwhW5M9bttT6B9FUUAry4YafJliUh/GQxGj4HGehj4HJoXZbpRQ4X
         9DLq8HaH2Lrdl3DXAhcHvVxhos+bsXLkSyUtdp/MwkVtRSM2PbMVrEx801rKDoCwA3GL
         BXdSBaHagDXXdO6dpHP4rRu0tMoTEXVdEVqovU8lRqMZxZB0erziycEr9hsmAv2zIcM6
         C4h5NRuVIAAP74dlWmgDepWgyNKiBbBLwg77lJIw5zqfkwGnC1cp3R8pXnx7/x8zbOSI
         fW2w==
X-Google-Smtp-Source: APXvYqybQYp8ZSevR7dKJG4NyLLkxZF4sEewwq4/Wcr6s3t1QOvtCl3nL33onHUOqL2oakAGpy6ch4nX6aXI0Retsts=
X-Received: by 2002:a02:1b54:: with SMTP id l81mr11484679jad.87.1552582709196;
 Thu, 14 Mar 2019 09:58:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com> <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
In-Reply-To: <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 14 Mar 2019 09:58:17 -0700
Message-ID: <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.com> wrot=
e:
>
>
> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:
> >> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
> >>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
> >>>> The following patch-set proposes an efficient mechanism for handing =
freed memory between the guest and the host. It enables the guests with no =
page cache to rapidly free and reclaims memory to and from the host respect=
ively.
> >>>>
> >>>> Benefit:
> >>>> With this patch-series, in our test-case, executed on a single syste=
m and single NUMA node with 15GB memory, we were able to successfully launc=
h 5 guests(each with 5 GB memory) when page hinting was enabled and 3 witho=
ut it. (Detailed explanation of the test procedure is provided at the botto=
m under Test - 1).
> >>>>
> >>>> Changelog in v9:
> >>>>    * Guest free page hinting hook is now invoked after a page has be=
en merged in the buddy.
> >>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(cur=
rently defined as MAX_ORDER - 1) are captured.
> >>>>    * Removed kthread which was earlier used to perform the scanning,=
 isolation & reporting of free pages.
> >>>>    * Pages, captured in the per cpu array are sorted based on the zo=
ne numbers. This is to avoid redundancy of acquiring zone locks.
> >>>>         * Dynamically allocated space is used to hold the isolated g=
uest free pages.
> >>>>         * All the pages are reported asynchronously to the host via =
virtio driver.
> >>>>         * Pages are returned back to the guest buddy free list only =
when the host response is received.
> >>>>
> >>>> Pending items:
> >>>>         * Make sure that the guest free page hinting's current imple=
mentation doesn't break hugepages or device assigned guests.
> >>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support=
. (It is currently missing)
> >>>>         * Compare reporting free pages via vring with vhost.
> >>>>         * Decide between MADV_DONTNEED and MADV_FREE.
> >>>>    * Analyze overall performance impact due to guest free page hinti=
ng.
> >>>>    * Come up with proper/traceable error-message/logs.
> >>>>
> >>>> Tests:
> >>>> 1. Use-case - Number of guests we can launch
> >>>>
> >>>>    NUMA Nodes =3D 1 with 15 GB memory
> >>>>    Guest Memory =3D 5 GB
> >>>>    Number of cores in guest =3D 1
> >>>>    Workload =3D test allocation program allocates 4GB memory, touche=
s it via memset and exits.
> >>>>    Procedure =3D
> >>>>    The first guest is launched and once its console is up, the test =
allocation program is executed with 4 GB memory request (Due to this the gu=
est occupies almost 4-5 GB of memory in the host in a system without page h=
inting). Once this program exits at that time another guest is launched in =
the host and the same process is followed. We continue launching the guests=
 until a guest gets killed due to low memory condition in the host.
> >>>>
> >>>>    Results:
> >>>>    Without hinting =3D 3
> >>>>    With hinting =3D 5
> >>>>
> >>>> 2. Hackbench
> >>>>    Guest Memory =3D 5 GB
> >>>>    Number of cores =3D 4
> >>>>    Number of tasks         Time with Hinting       Time without Hint=
ing
> >>>>    4000                    19.540                  17.818
> >>>>
> >>> How about memhog btw?
> >>> Alex reported:
> >>>
> >>>     My testing up till now has consisted of setting up 4 8GB VMs on a=
 system
> >>>     with 32GB of memory and 4GB of swap. To stress the memory on the =
system I
> >>>     would run "memhog 8G" sequentially on each of the guests and obse=
rve how
> >>>     long it took to complete the run. The observed behavior is that o=
n the
> >>>     systems with these patches applied in both the guest and on the h=
ost I was
> >>>     able to complete the test with a time of 5 to 7 seconds per guest=
. On a
> >>>     system without these patches the time ranged from 7 to 49 seconds=
 per
> >>>     guest. I am assuming the variability is due to time being spent w=
riting
> >>>     pages out to disk in order to free up space for the guest.
> >>>
> >> Here are the results:
> >>
> >> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> >> total memory of 15GB and no swap. In each of the guest, memhog is run
> >> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> >> using Free command.
> >>
> >> Without Hinting:
> >>                  Time of execution    Host used memory
> >> Guest 1:        45 seconds            5.4 GB
> >> Guest 2:        45 seconds            10 GB
> >> Guest 3:        1  minute               15 GB
> >>
> >> With Hinting:
> >>                 Time of execution     Host used memory
> >> Guest 1:        49 seconds            2.4 GB
> >> Guest 2:        40 seconds            4.3 GB
> >> Guest 3:        50 seconds            6.3 GB
> > OK so no improvement. OTOH Alex's patches cut time down to 5-7 seconds
> > which seems better. Want to try testing Alex's patches for comparison?
> >
> I realized that the last time I reported the memhog numbers, I didn't
> enable the swap due to which the actual benefits of the series were not
> shown.
> I have re-run the test by including some of the changes suggested by
> Alexander and David:
>     * Reduced the size of the per-cpu array to 32 and minimum hinting
> threshold to 16.
>     * Reported length of isolated pages along with start pfn, instead of
> the order from the guest.
>     * Used the reported length to madvise the entire length of address
> instead of a single 4K page.
>     * Replaced MADV_DONTNEED with MADV_FREE.
>
> Setup for the test:
> NUMA node:1
> Memory: 15GB
> Swap: 4GB
> Guest memory: 6GB
> Number of core: 1
>
> Process: A guest is launched and memhog is run with 6GB. As its
> execution is over next guest is launched. Everytime memhog execution
> time is monitored.
> Results:
>     Without Hinting:
>                  Time of execution
>     Guest1:    22s
>     Guest2:    24s
>     Guest3: 1m29s
>
>     With Hinting:
>                 Time of execution
>     Guest1:    24s
>     Guest2:    25s
>     Guest3:    28s
>
> When hinting is enabled swap space is not used until memhog with 6GB is
> ran in 6th guest.

So one change you may want to make to your test setup would be to
launch the tests sequentially after all the guests all up, instead of
combining the test and guest bring-up. In addition you could run
through the guests more than once to determine a more-or-less steady
state in terms of the performance as you move between the guests after
they have hit the point of having to either swap or pull MADV_FREE
pages.

