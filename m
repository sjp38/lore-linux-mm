Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9C8C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13AFA207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:43:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OYJusuUF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13AFA207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B0CF6B0008; Tue,  2 Apr 2019 19:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 961246B0269; Tue,  2 Apr 2019 19:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828C06B026D; Tue,  2 Apr 2019 19:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D59E6B0008
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:43:18 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id j8so4505784ita.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HR8wUym/2SxVAcLGHxRc6/l40dT70VQ5iSSa6f+DwtI=;
        b=VOpK0u+U5jzhofLiBdTYOLBWfKSIAJZOaFJ/qcWz3l+Kbqyz6oHrKFu5cbP8dlEl/t
         drN8oIFB2sMPCfbxn4lUx9el8jSorC9PDNuXY5059yf5QTiZhwmqy6/oH3Q9yBT+xiva
         1PucIElQWJwwurmu8bzlhowec5jLiuRiSGr1SWgHQ+MUkhXVNpAMRdZRsF5FYUO1sXZM
         mwwOUou1fWQ1a+MBO5CBOlfDmCXayaqGw5V1xM2y8kViakYULSddwYElUHc0AVifa4UL
         BOLKckaDTEEUKJS8S/V8nYg3WIxr52wSHI7vOjtD2JAS6qCugJkYy8Pqh6OlsRnB46Cl
         6Grw==
X-Gm-Message-State: APjAAAURPeLRioKOTRVszMQjooohMCMJvkRUnBgsJG/W5wUEVuoLfPlK
	GIashhVx7BMhRbJrxnCM2rYH2ZJP2mzHaiwfamgzIDd/1j7dEUJqCc/U96sLxmaa/hVeH8rsgUn
	jQ1zRUaqszU3sSJ18u7y9JX6PZTk1QYJ10AFv6EtxvJZwq1Kz4St1Utt2mC9aW26vjA==
X-Received: by 2002:a6b:7219:: with SMTP id n25mr48670774ioc.117.1554248598005;
        Tue, 02 Apr 2019 16:43:18 -0700 (PDT)
X-Received: by 2002:a6b:7219:: with SMTP id n25mr48670708ioc.117.1554248596114;
        Tue, 02 Apr 2019 16:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554248596; cv=none;
        d=google.com; s=arc-20160816;
        b=Wvb2w2kNRxV9xwIb/STJNA3LAI7t0KUcCVrc7dkC9m8S5oNqKBOC4kf6MIKvyRPetN
         xkuc4hOUENYbnKL/Wn13jEbrd10BeHrRM7eu7qQ9fLM4TYsPnBrAAfRRk9+cebly1bnp
         ZRDLvsIj4e+eU2n5u56hiyvUhWJ+KeQaIAVWhIcwKlDVDy/TvnaOOFP6yccpd0K4JTzJ
         i2P7BHSUKJNK3i9B6cMTlFZOLH5vzbcMXNvvtdoJno0oHjQhTqgcaO6owDdceWHyHDWs
         TFS2yIu05l6bA+AeRKV/v4AHL3PSPDchuZTby5om2Xuwaic4ZGapi+nY+OYYPOSKtwmx
         FxwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HR8wUym/2SxVAcLGHxRc6/l40dT70VQ5iSSa6f+DwtI=;
        b=Gk644zIi+1Sjcnt4gQYHoLMI6zaSPBVPXhraS7+XC965pbJjS4XUxlDQZmh5HlWq0O
         BXAgjIRyjQHgOwjHEgydScjILs7Z/6x55398L7EdP6U4gukYJTsiGnV66m15V9/qWGhD
         M3KL+Mf/me0bHk9QHUL2BUrqiRPJcxS9XvDJfzzwNYZ+xEAvDmdSKHBLekeogPyko0hb
         loelaO4DozTrCAN6soGORzI3xjizxdvOiDEqXcoe5+LEmfL0WgQTI1ag1SDg57U1TwV3
         Pg7VrM1Bb0qlEKT3SynAfNWiArBf3wEwxzhsbp4ee9aFba9TlxdBnB09GI6D/1XT/jon
         96xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OYJusuUF;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i200sor16154166iti.18.2019.04.02.16.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 16:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OYJusuUF;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HR8wUym/2SxVAcLGHxRc6/l40dT70VQ5iSSa6f+DwtI=;
        b=OYJusuUFySH8spKlILz/GvFjGRnPGDOFz/Sfw8KGgwxkMTxkppkQDe/RXuTuw22bVa
         qd3tNLgZGSqKAdWhPUPbVTws3efRmzcREpIjyU2CUl2e+hpwzCxpEuBnt9bAOV+87s91
         0fr/hKU1N0JlfH42f/nDnFzr9AfjwqFvUB/C1U8seJu0EesxkxiEOvj/tU6yylDONTKy
         v3GBflhwLR8b01yGO2qMKHssB4wRvrVeXpThSwr0cCcPCEb5DMiGyleZnywOlJw/cj+4
         Tux1iJ/QzitDlzUifFbtVOghLngLhzbxMAC+sCZjpvu5nTcX3a99/c6Pg07L7MV91TXB
         5JuA==
X-Google-Smtp-Source: APXvYqzoPyfBDxE5ownLyoSGR6G+BW4pf7rFSajtePVNuXa5NYzqq9Pa4MWCnvECa8cXIdHO411KhDoAWnEBt2IhEAk=
X-Received: by 2002:a24:7c52:: with SMTP id a79mr6957536itd.51.1554248595406;
 Tue, 02 Apr 2019 16:43:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com> <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com> <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org> <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org> <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com> <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com> <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com> <CAKgT0UeqX8Q8BYAo4COfQ2TQGBduzctAf5Ko+0mUmSw-aemOSg@mail.gmail.com>
 <0fdc41fb-b2ba-c6e6-36b9-97ad5a6eb54c@redhat.com>
In-Reply-To: <0fdc41fb-b2ba-c6e6-36b9-97ad5a6eb54c@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 2 Apr 2019 16:43:03 -0700
Message-ID: <CAKgT0UcrkXKjMgYy2H3MKQxG71ScNqhwqxwti7QjvPSxtb8FBg@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 11:53 AM David Hildenbrand <david@redhat.com> wrote:
>
> >>> Why do we need them running in parallel for a single guest? I don't
> >>> think we need the hints so quickly that we would need to have multiple
> >>> VCPUs running in parallel to provide hints. In addition as it
> >>> currently stands in order to get pages into and out of the buddy
> >>> allocator we are going to have to take the zone lock anyway so we
> >>> could probably just assume a single thread for pulling the memory,
> >>> placing it on the ring, and putting it back into the buddy allocator
> >>> after the hint has been completed.
> >>
> >> VCPUs hint when they think the time has come. Hinting in parallel comes
> >> naturally.
> >
> > Actually it doesn't because if we are doing it asynchronously we are
> > having to pull pages out of the zone which requires the zone lock.
>
> Yes, and we already work with zones already when freeing. At least one zone.
>
> > That has been one of the reasons why the patches from Nitesh start
> > dropping in performance when you start enabling more than 1 VCPU. If
> > we are limited by the zone lock it doesn't make sense for us to try to
> > do thing in parallel.
>
> That is an interesting point and I'd love to see some performance numbers.

So the last time I ran data it was with the virtio-balloon patch set I
ended up having to make a number of fixes and tweaks. I believe the
patches can be found online as I emailed them to the list and Nitesh,
but I don't have them handy to point to.

Results w/ THP
Baseline
[root@localhost ~]# cd ~/will-it-scale/; ./runtest.py page_fault1
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,501001,93.72,500312,93.72,501001
2,918688,87.49,837092,87.51,1002002
3,1300535,81.22,1200746,81.39,1503003
4,1718865,75.01,1522041,75.20,2004004
5,2032902,68.77,1826264,69.26,2505005
6,2309724,62.55,1979819,63.89,3006006
7,2609748,56.30,1935436,60.20,3507007
8,2705883,50.07,1913416,57.45,4008008
9,2738392,43.84,2017198,51.24,4509009
10,2913739,37.63,1906649,48.65,5010010
11,2996000,31.41,1973332,41.86,5511011
12,2930790,25.19,1928318,37.33,6012012
13,2876603,18.97,2040026,31.83,6513013
14,2820274,12.77,2060417,27.19,7014014
15,2729018,6.55,2134531,24.33,7515015
16,2682826,0.36,2146440,21.25,8016016

My Patch Set
[root@localhost will-it-scale]# cd ~/will-it-scale/; ./runtest.py page_fault1
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,459575,93.74,458546,93.73,459575
2,901990,87.47,841478,87.49,919150
3,1307078,81.26,1193380,81.43,1378725
4,1717429,75.03,1529761,75.30,1838300
5,2045371,68.79,1765334,70.01,2297875
6,2272685,62.56,1893388,65.42,2757450
7,2583919,56.34,2078468,59.85,3217025
8,2777732,50.10,2009627,57.08,3676600
9,2932699,43.90,1938315,52.00,4136175
10,2935508,37.70,1982124,46.55,4595750
11,2881811,31.45,2162791,41.36,5055325
12,2947880,25.27,2058337,38.93,5514900
13,2925530,19.11,1937080,32.13,5974475
14,2867833,12.89,2023161,25.80,6434050
15,2856156,6.69,2067414,24.67,6893625
16,2775991,0.53,2062535,17.46,7353200

Modified RH Virtio-Balloon based patch set
[root@localhost ~]# cd ~/will-it-scale/; ./runtest.py page_fault1
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,522672,93.73,524206,93.73,524206
2,914612,87.47,828489,87.66,1048412
3,1336109,81.25,1156889,82.15,1572618
4,1638776,75.01,1419247,76.75,2096824
5,1982146,68.77,1676836,71.27,2621030
6,2211653,62.57,1865976,65.60,3145236
7,2456776,56.33,2111887,57.98,3669442
8,2594395,50.10,2101993,54.17,4193648
9,2672871,43.90,1864173,53.01,4717854
10,2695456,37.69,2152126,45.82,5242060
11,2702604,31.44,1962406,42.50,5766266
12,2702415,25.22,2078596,35.01,6290472
13,2677250,19.02,2068953,35.42,6814678
14,2612990,12.80,2053951,30.77,7338884
15,2521812,6.67,1876602,26.42,7863090
16,2472506,0.53,1957658,20.16,8387296

Basically when you compare the direct approach from the patch set I
submitted versus the one using the virtio approach the virtio has
better single thread performance, but doesn't scale as well as my
patch set did. That is why I am thinking that if we can avoid trying
to scale out to per-cpu and instead focus on just having one thread
handle the feeding of the hints to the virtio device we could avoid
the scaling penalty and instead get the best of both worlds.

> >>> Also there isn't a huge priority to report idle memory in real time.
> >>> That would be kind of pointless as it might be pulled back out and
> >>> reused as soon as it is added. What we need is to give the memory a
> >>> bit of time to "cool" so that we aren't constantly hinting away memory
> >>> that is still in use.
> >>
> >> Depending on the setup, you don't want free memory lying around for too
> >> long in your guest.
> >
> > Right, but you don't need it as soon as it is freed either. If it is
> > idle in the guest for a few seconds that shouldn't be an issue. The
> > free page hinting will hurt performance if we are doing it too often
> > simply because we are going to be triggering a much higher rate of
> > page faults.
>
> Valid point.
>
> >
> >>>
> >>>> Your approach sounds very interesting to play with, however
> >>>> at this point I would like to avoid throwing away Nitesh work once again
> >>>> to follow some other approach that looks promising. If we keep going
> >>>> like that, we'll spend another ~10 years working on free page hinting
> >>>> without getting anything upstream. Especially if it involves more
> >>>> core-MM changes. We've been there, we've done that. As long as the
> >>>> guest-host interface is generic enough, we can play with such approaches
> >>>> later in the guest. Important part is that the guest-host interface
> >>>> allows for that.
> >>>
> >>> I'm not throwing anything away. One of the issues in Nitesh's design
> >>> is that he is going to either miss memory and have to run an
> >>> asynchronous thread to clean it up after the fact, or he is going to
> >>> cause massive OOM errors and/or have to start halting VCPUs while
> >>
> >> 1. how are we going to miss memory. We are going to miss memory because
> >> we hint on very huge chunks, but we all agreed to live with that for now.
> >
> > What I am talking about is that some application frees gigabytes of
> > memory. As I recall the queue length for a single cpu is only like 1G.
> > Are we going to be sitting on the backlog of most of system memory
> > while we process it 1G at a time?
>
> I think it is something around "pages that fit into a request" *
> "numbers of entries in a virtqueue".

Right, but then we start spinning if there are no free entries in the
virtqueue. That isn't a very asynchronous way to handle things if we
are just going to peg a VCPU busy waiting for the virtqueue to free up
a buffer.

If we are going to go asynchronous we should be completely
asynchronous. Right now we still can end up eating a large amount of
memory with request size * virtqueue size, and then when we hit that
limit there is a while loop we hit that will spin until we have a free
buffer.

> >
> >> 2. What are the "massive OOM" errors you are talking about? We have the
> >> one scenario we described Nitesh was not even able to reproduce yet. And
> >> we have ways to mitigate the problem (discussed in this thread).
> >
> > So I am referring to the last patch set I have seen. Last I knew all
> > the code was doing was assembling lists if isolated pages and placing
> > them on a queue. I have seen no way that this really limits the length
> > of the virtqueue, and the length of the isolated page lists is the
>
> Ah yes, we are discussing something towards possible capping in this
> thread. Once there would be too much being hinted already, skip hinting
> for now. Which might have good and bad sides. Different discussion.

I'd say that it is another argument for trying to get away from the
per-cpu lists though if we need to put limits on it. Trying to
maintain a reasonable limit while coordinating between CPUs would be a
challenge.

> > only thing that has any specific limits to it. So I see it easily
> > being possible for a good portion of memory being consumed by the
> > queue when you consider that what you have is essentially the maximum
> > length of the isolated page list multiplied by the number of entries
> > in a virtqueue.
> >
> >> We have something that seems to work. Let's work from there instead of
> >> scrapping the general design once more, thinking "it is super easy". And
> >> yes, what you propose is pretty much throwing away the current design in
> >> the guest.
> >
> > Define "work"? The last patch set required massive fixes as it was
> > causing kernel panics if more than 1 VCPU was enabled and list
> > corruption in general. I'm sure there are a ton more bugs lurking as
> > we have only begun to be able to stress this code in any meaningful
> > way.
>
> "work" - we get performance numbers that look promising and sorting out
> issues in the design we find. This is RFC. We are discussing design
> details. If there are issues in the design, let's discuss. If there are
> alternatives, let's discuss. Bashing on the quality of prototypes?
> Please don't.

I'm not so much bashing the quality as the lack of data. It is hard to
say something is "working" when you have a hard time getting it to
stay up long enough to collect any reasonable data. My concern is that
the data looks really great when you don't have all the proper
critical sections handled correctly, but when you add the locking that
needs to be there it can make the whole point of an entire patch set
moot.

> >
> > For example what happens if someone sits on the mm write semaphore for
> > an extended period of time on the host? That will shut down all of the
> > hinting until that is released, and at that point once again any
> > hinting queues will be stuck on the guest until they can be processed
> > by the host.
>
> I remember that is why we are using asynchronous requests. Combined with
> dropping hints when in such a situation (posted hints not getting
> processed), nobody would be stuck. Or am I missing something? Yes, then
> the issue of dropped hints arises, and that is a different discussion.

Right, but while that lock is stuck you have all the memory sitting in
the queues. That is the reason why I want to keep the amount of memory
that can be sitting in these queues on the smaller side and closer to
something like 64M. I don't want the guest to have to be stuck either
dropping hints, or starving a guest for memory because it can't get
the hints serviced.

> >
> >>> waiting on the processing. All I am suggesting is that we can get away
> >>> from having to deal with both by just walking through the free pages
> >>> for the higher order and hinting only a few at a time without having
> >>> to try to provide the host with the hints on what is idle the second
> >>> it is freed.
> >>>
> >>>>>
> >>>>> I view this all as working not too dissimilar to how a standard Rx
> >>>>> ring in a network device works. Only we would want to allocate from
> >>>>> the pool of "Buddy" pages, flag the pages as "Offline", and then when
> >>>>> the hint has been processed we would place them back in the "Buddy"
> >>>>> list with the "Offline" value still set. The only real changes needed
> >>>>> to the buddy allocator would be to add some logic for clearing/merging
> >>>>> the "Offline" setting as necessary, and to provide an allocator that
> >>>>> only works with non-"Offline" pages.
> >>>>
> >>>> Sorry, I had to smile at the phrase "only" in combination with "provide
> >>>> an allocator that only works with non-Offline pages" :) . I guess you
> >>>> realize yourself that these are core-mm changes that might easily be
> >>>> rejected upstream because "the virt guys try to teach core-MM yet
> >>>> another special case". I agree that this is nice to play with,
> >>>> eventually that approach could succeed and be accepted upstream. But I
> >>>> consider this long term work.
> >>>
> >>> The actual patch for this would probably be pretty small and compared
> >>> to some of the other stuff that has gone in recently isn't too far out
> >>> of the realm of possibility. It isn't too different then the code that
> >>> has already done in to determine the unused pages for virtio-balloon
> >>> free page hinting.
> >>>
> >>> Basically what we would be doing is providing a means for
> >>> incrementally transitioning the buddy memory into the idle/offline
> >>> state to reduce guest memory overhead. It would require one function
> >>> that would walk the free page lists and pluck out pages that don't
> >>> have the "Offline" page type set, a one-line change to the logic for
> >>> allocating a page as we would need to clear that extra bit of state,
> >>> and optionally some bits for how to handle the merge of two "Offline"
> >>> pages in the buddy allocator (required for lower order support). It
> >>> solves most of the guest side issues with the free page hinting in
> >>> that trying to do it via the arch_free_page path is problematic at
> >>> best since it was designed for a synchronous setup, not an
> >>> asynchronous one.
> >>
> >> This is throwing away work. No I don't think this is the right path to
> >> follow for now. Feel free to look into it while Nitesh gets something in
> >> shape we know conceptually works and we are starting to know which
> >> issues we are hitting.
> >
> > Yes, it is throwing away work. But if the work is running toward a
> > dead end does it add any value?
>
> "I'm not throwing anything away. " vs. "Yes, it is throwing away work.",
> now we are on the same page.
>
> So your main point here is that you are fairly sure we are are running
> towards an dead end, right?

Yes. There is a ton of code here that is adding complexity and bugs
that I would consider waste. If we can move to a single threaded
approach the code could become much simpler as we will only have a
single queue that we have to service and we could get away from 2
levels of lists and the allocation that goes with them. In addition I
think we could get away with much more code reuse as the
get_free_page_and_send function could likely be adapted to provide a
more generic function for adding a page of a specific size to the
queue versus the current assumption that the only page size is
VIRTIO_BALLOON_FREE_PAGE_ORDER.

> >
> > I've been looking into the stuff Nitesh has been doing. I don't know
> > about others, but I have been testing it. That is why I provided the
> > patches I did to get it stable enough for me to test and address the
> > regressions it was causing. That is the source of some of my concern.
>
> Testing and feedback is very much appreciated. You have concerns, they
> are valid. I do like discussing concerns, discussing possible solutions,
> or finding out that it cannot be solved the easy way. Then throw it away.
>
> Coming up with a clean design that considers problems that are not
> directly visible is something I would like to see. But usually they
> don't jump at you before prototyping.
>
> The simplest approach so far was "scan for zero pages in the
> hypervisor". No changes in the guest needed except setting pages to zero
> when freeing. No additional threads in the guest. No hinting. And still
> we decided against it.

Right, I get that. There is still going to be a certain amount of
overhead for zeroing the pages in adding the scanning on the host will
not come cheap. I had considered something similar when I first looked
into this.

> > I think we have been making this overly complex with all the per-cpu
> > bits and trying to place this in the free path itself. We really need
>
> We already removed complexity, at least that is my impression. There are
> bugs in there, yes.

So one of the concerns I have at this point is the sheer number of
allocations and the list shuffling that is having to take place.

The design of the last patch set had us enqueueing addresses on the
per-cpu "free_pages_obj". Then when we hit a certain threshold it will
call guest_free_page_hinting which is allocated via kmalloc and then
populated with the pages that can be isolated. Then that function
calls guest_free_page_report which will yet again kmalloc a hint_req
object that just contains a pointer to our isolated pages list. If we
can keep the page count small we could just do away with all of that
and instead do something more like get_free_page_and_send.

> > to scale this back and look at having a single thread with a walker of
> > some sort just hinting on what memory is sitting in the buddy but not
> > hinted on. It is a solution that would work, even in a multiple VCPU
> > case, and is achievable in the short term.
> Can you write up your complete proposal and start a new thread. What I
> understood so far is
>
> 1. Separate hinting thread
>
> 2. Use virtio-balloon mechanism similar to Nitesh's work
>
> 3. Iterate over !offline pages in the buddy. Take them temporarily out
> of the buddy (similar to Niteshs work). Send them to the hypervisor.
> Mark them offline, put them back to the buddy.
>
> 4. When a page leaves the buddy, drop the offline marker.

Yep, that is pretty much it. I'll see if I can get a write-up of it tomorrow.

>
> Selected issues to be sorted out:
> - We have to find a way to mask pages offline. We are effectively
> touching pages we don't own (keeping flags set when returning pages to
> the buddy). Core MM has to accept this change.
> - We might teach other users how to treat buddy pages now. Offline
> always has to be cleared.
> - How to limit the cycles wasted scanning? Idle guests?

One thought I had would be to look at splitting nr_free_pages in each
free_area and splitting it into two free running counters, one for the
number of pages added, and one for the number of pages removed. Then
it would be pretty straight forward to determine how many are
available as we could maintain a free running counter for each free
area in the balloon driver to determine if we need to scan a given
area.

> - How to efficiently scan a list that might always change between
> hinting requests?
> - How to avoid OOM that can still happen in corner cases, after all you
> are taking pages out of the buddy temporarily.

Yes, but hopefully it should be a small enough amount that nobody will
notice. In many cases devices such as NICs can consume much more than
this regularly for just their Rx buffers and it is not an issue. There
has to be a certain amount of overhead that any given device is
allowed to consume. If we contain the balloon hinting to just 64M that
should be a small enough amount that nobody would notice in practice.

