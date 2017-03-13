Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A47D26B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 17:59:28 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o135so251033358qke.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:59:28 -0700 (PDT)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com. [209.85.216.181])
        by mx.google.com with ESMTPS id m49si1486225qtb.168.2017.03.13.14.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 14:59:27 -0700 (PDT)
Received: by mail-qt0-f181.google.com with SMTP id i34so43025338qtc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:59:27 -0700 (PDT)
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
 <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
 <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk>
 <20170306160437.sf7bksorlnw7u372@phenom.ffwll.local>
 <CA+M3ks77Am3Fx-ZNmgeM5tCqdM7SzV7rby4Es-p2F2aOhUco9g@mail.gmail.com>
 <26bc57ae-d88f-4ea0-d666-2c1a02bf866f@redhat.com>
 <CA+M3ks6R=n4n54wofK7pYcWoQKUhzyWQytBO90+pRDRrAhi3ww@mail.gmail.com>
 <CAKMK7uH9NemeM2z-tQvge_B=kABop6O7UQFK3PirpJminMCPqw@mail.gmail.com>
 <6d3d52ba-29a9-701f-2948-00ce28282975@redhat.com>
 <CAF6AEGvs0qVr_=pSp5FYoxM4XNaKLtYB-uhBmDheYcgxgv1_2g@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <ef8ae526-d0e8-83dd-c2d8-656d356ebd91@redhat.com>
Date: Mon, 13 Mar 2017 14:59:23 -0700
MIME-Version: 1.0
In-Reply-To: <CAF6AEGvs0qVr_=pSp5FYoxM4XNaKLtYB-uhBmDheYcgxgv1_2g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, devel@driverdev.osuosl.org, Rom Lemarchand <romlem@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Riley Andrews <riandrews@android.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Mark Brown <broonie@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Vetter <daniel.vetter@intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On 03/13/2017 02:29 PM, Rob Clark wrote:
> On Mon, Mar 13, 2017 at 5:09 PM, Laura Abbott <labbott@redhat.com> wrote:
>>> Hm, we might want to expose all the heaps as individual
>>> /dev/ion_$heapname nodes? Should we do this from the start, since
>>> we're massively revamping the uapi anyway (imo not needed, current
>>> state seems to work too)?
>>> -Daniel
>>>
>>
>> I thought about that. One advantage with separate /dev/ion_$heap
>> is that we don't have to worry about a limit of 32 possible
>> heaps per system (32-bit heap id allocation field). But dealing
>> with an ioctl seems easier than names. Userspace might be less
>> likely to hardcode random id numbers vs. names as well.
> 
> 
> other advantage, I think, is selinux (brought up elsewhere on this
> thread).. heaps at known fixed PAs are useful for certain sorts of
> attacks so being able to restrict access more easily seems like a good
> thing
> 
> BR,
> -R
> 

Some other kind of filtering (BPF/LSM/???) might work as well
(http://kernsec.org/files/lss2015/vanderstoep.pdf ?)

The fixed PA issue is a larger problem. We're never going to
be able to get away from "this heap must exist at address X"
problems but the location of CMA in general should be
randomized. I haven't actually come up with a good proposal
to this though.

I'd like for Ion to be a framework for memory allocation and
not security exploits. Hopefully this isn't a pipe dream.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
