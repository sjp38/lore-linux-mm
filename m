Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49AB1C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E592A21537
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GPKt4Xua"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E592A21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 685998E00E0; Thu, 11 Jul 2019 10:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6353A8E00DB; Thu, 11 Jul 2019 10:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54A9D8E00E0; Thu, 11 Jul 2019 10:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 342DB8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:58:44 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so7031604iob.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=67vEZ9LmeiJA+CzGgxouJg1721jdWlihu7rPhmofRvo=;
        b=NIed52ArKww0SxnGCV094tVuONuiz5QNLJP2Y66vpGXM5JXz29CzM48fCedw89LUIZ
         smVTTNSPs50t/fnudMKYdyDWS8wvexthBEBHuDJQMPcLNdKunHmW3KPIV83dbQZg9qCF
         uSIFKYfalTT9UTX3yxLt1HiB7MkEPZNtIMF/BtbHoDOf8bry6UJ5Oh0E/NgSKwodA72f
         An7LcJwObZ0XpRkoSqaDEf8oPQzvc1H8QBfNA9XDV6FgI8gSmtHFsP3zzPE/rrzPls8M
         ucQUnzAU0f/GjQeqtv8sItUFOLBf9ZFweOm/8fZa0WmZyf+IaWPmgJR0JnmW8g/fguhH
         vBlA==
X-Gm-Message-State: APjAAAVCAtA5N2XK0p+jD1Gavj0q9sJFS6DZb7ufihseZuDW8sNP8KDn
	zmL6fEnv2uRpzLBJG4ef1BE45YEmGxlicF6O27RmcBSmZHYDBaLdIuDUTQz8fKXPnpCKE8zmFU5
	6N1qDdfL0azA4fKsDxE2ZJyAuGYJ4lOIrWCVRxWV4UAyHprTTPm9I5HzNa58jU6f9OA==
X-Received: by 2002:a02:c50a:: with SMTP id s10mr5182045jam.106.1562857123920;
        Thu, 11 Jul 2019 07:58:43 -0700 (PDT)
X-Received: by 2002:a02:c50a:: with SMTP id s10mr5181919jam.106.1562857122575;
        Thu, 11 Jul 2019 07:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562857122; cv=none;
        d=google.com; s=arc-20160816;
        b=idJDSrHBdJkZGrixCUf6nq3MFl7wMdqj+xIYO+x0JE5wbDVcW/rQqZaCuS+lBniSgc
         TMlE7mRdoHQVYYLG16Vd7xeBluL4ZZo5jA380sYFSyLcTW0CDWaCPYjhxvbiGYv5MaSy
         90hrtj6jJjko4icI/kkiREqXD5X+h4yHtBvIo4QL1zQ5zZCbybruRYVmN4mEg1qfKwIU
         u4Xh31dTsDg4POcTQnFa7ZrvRkdtvmzMAqnEFiuMPoFnVteNLdrDW/yojvG+L1uUswyi
         hJ2b16+Li5MMF/Sv2Zm357mXqsMyvTzLGdloL4t61z/D3gjiYrrEWh0K1tJOaUZFvJip
         IUiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=67vEZ9LmeiJA+CzGgxouJg1721jdWlihu7rPhmofRvo=;
        b=DGG4xNqoZNBDdeNGqnJeT4JJFPVc+1oGOerjVR1kjqYcQuZV8jLISq942drgVfmsdT
         FRCo6qChwKv9LU8wbzx/BsDvwio2xlS4tvPl0NH2bq0fjUXZheQC6L8jeFG36STc9sXz
         LzUwkHQujeWYuovjqNFUqrCMZgI5kchkqhDSfuRwyui+3O4Z7QYKOx+FvFX0NAY7xzbO
         7X+Hfw/U0Il9X2dkPG+pM9VTT7jCDCv8Gv1SKMO99I1H0wlheycu1cJYPhspKIq58voW
         8j/4PgUKPd/qcRhcK7PX09sj7jf2W1D73W8wAUkc/P+QDiXIlM7o+yRoW+I4EV7fhEUs
         jZug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GPKt4Xua;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor4759715ioj.78.2019.07.11.07.58.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 07:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GPKt4Xua;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=67vEZ9LmeiJA+CzGgxouJg1721jdWlihu7rPhmofRvo=;
        b=GPKt4Xuaraje4BWIvgOYxjwE7k5d8A6LRJO8vVZImQuUCcsnbQ23es68AMJg3XotWr
         /Rm7SNBVniqMRfzTIeYPpy4Lfz+3+EkFUdoM6phponZpQYGmnlkertfK1XopsLZHTokD
         aSH1pzZi7WBoPN9eiKSlifxncS0PcIkFl+GIOjvptkn+9mIEvObfi1yBpv188SZbO1fM
         w9iDEIl43YYE6Bb/gR5kq8XJT98uAvSEOTKZtQw+M3G0HF2rs2GGe7dtEYY/AO8JGnL8
         i5Z8BuO9tK1aRmF5v2S/qwtmslN2i19Y+bpW0c1hhEH+S+oTXpEfZ/iY4P/QNwwT7KcC
         AS8g==
X-Google-Smtp-Source: APXvYqxF5K13fx8Iay8sm+FiEou6IZ3lR42kecxaJ3Wu9CJa7NBI7Fi0H4Z87RTqyKAKQbBVaC0A8VGf084XAPWGgMo=
X-Received: by 2002:a02:6d24:: with SMTP id m36mr5127553jac.87.1562857121987;
 Thu, 11 Jul 2019 07:58:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190710195158.19640-1-nitesh@redhat.com> <CAKgT0Uf3J17zNFc-pBKQjTthSa8GG=TrTwaL4+Ns=Q88sFpxLQ@mail.gmail.com>
 <901cb83e-fb6a-a7fc-a60e-e35b0c89139d@redhat.com>
In-Reply-To: <901cb83e-fb6a-a7fc-a60e-e35b0c89139d@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 11 Jul 2019 07:58:30 -0700
Message-ID: <CAKgT0UdMiArh+H54FvnEZTM9XsgOs_FJXO8VfJ1EXw6hiCqwRA@mail.gmail.com>
Subject: Re: [RFC][PATCH v11 0/2] mm: Support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com, 
	Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 4:31 AM Nitesh Narayan Lal <nitesh@redhat.com> wrot=
e:
>
>
> On 7/10/19 7:40 PM, Alexander Duyck wrote:
> > On Wed, Jul 10, 2019 at 12:52 PM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
> >
> > The results up here were redundant with what is below so I am just
> > dropping them. I would suggest only including one set of results in
> > any future cover page as it is confusing to duplicate it like that.
> >
> >> This approach tracks all freed pages of the order MAX_ORDER - 2 in bit=
maps.
> >> A new hook after buddy merging is used to set the bits in the bitmap.
> >> Currently, the bits are only cleared when pages are hinted, not when p=
ages are
> >> re-allocated.
> >>
> >> Bitmaps are stored on a per-zone basis and are protected by the zone l=
ock. A
> >> workqueue asynchronously processes the bitmaps as soon as a pre-define=
d memory
> >> threshold is met, trying to isolate and report pages that are still fr=
ee.
> >>
> >> The isolated pages are reported via virtio-balloon, which is responsib=
le for
> >> sending batched pages to the host synchronously. Once the hypervisor p=
rocessed
> >> the hinting request, the isolated pages are returned back to the buddy=
.
> >>
> >> Changelog in v11:
> >> * Added logic to take care of multiple NUMA nodes scenarios.
> >> * Simplified the logic for reporting isolated pages to the host. (Eg. =
replaced
> >> dynamically allocated arrays with static ones, introduced wait event i=
nstead of
> >> the loop in order to wait for a response from the host)
> >> * Added a mutex to prevent race condition when page hinting is enabled=
 by
> >> multiple drivers.
> >> * Simplified the logic responsible for decrementing free page counter =
for each
> >> zone.
> >> * Simplified code structuring/naming.
> >>
> >> Known work items for the future:
> >> * Test device assigned guests to ensure that hinting doesn't break it.
> >> * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device-side support.
> >> * Decide between MADV_DONTNEED and MADV_FREE.
> >> * Look into memory hotplug, more efficient locking, better naming conv=
entions to
> >> avoid confusion with VIRTIO_BALLOON_F_FREE_PAGE_HINT support.
> >> * Come up with proper/traceable error-message/logs and look into other=
 code
> >> simplifications. (If necessary).
> >>
> >> Benefit analysis:
> >> 1. Number of 5GB guests (each touching 4GB memory) that can be launche=
d without
> >> swap usage on a system with 15GB:
> >> unmodified kernel - 2, 3rd with 2.5GB
> >> v11 page hinting - 6, 7th with 26MB
> >> v1 bubble hinting - 6, 7th with 1.8GB
> >>
> >> Conclusion - In this particular testcase on using v11 page hinting and
> >> v1 bubble-hinting 4 more guests could be launched without swapping com=
pared
> >> to an unmodified kernel.
> >> For the 7th guest launch, v11 page hinting is slightly better than v1 =
Bubble
> >> hinting as it touches lesser swap space.
> > I'm confused by the comment. From what I can tell bubble hinting came
> > up with 1.8GB of memory while page hinting only managed to achieve
> > .026GB (Using the same units makes it easier to visualize the
> > difference). Also your test says "can be launched without swap usage",
> > yet you say the bubble hinting is touching swap which makes not sense
> > to me.
> I will work on the cover to improve this part.
> Basically, In each case, the first number indicates the number of the
> guest which are launched without touching the swap space. For instance
> with bubble hinting, I was able to launch 6 guests without any swap
> usage. On launching the 7th guests initially there was no swap usage,
> however, as the test app starts allocating 4GB memory the swap came into
> the picture. 1.8 GB is the swap usage after the completion of the test
> application.
> >> Setup & procedure -
> >> Total NUMA Node Memory ~ 15 GB (All guests are run on a single NUMA no=
de)
> >> Guest Memory =3D 5GB
> >> Number of CPUs in the guest =3D 1
> >> Host swap =3D 4GB
> >> Workload =3D test allocation program that allocates 4GB memory, touche=
s it via
> >> memset and exits.
> >> The first guest is launched and once its console is up, the test alloc=
ation
> >> program is executed with 4 GB memory request (Due to this the guest oc=
cupies
> >> almost 4-5 GB of memory in the host in a system without page hinting).=
 Once
> >> this program exits at that time another guest is launched in the host =
and the
> >> same process is followed. It is continued until the swap is not used.
> >>
> >> 2. Memhog execution time (For 3 guests each of 6GB on a system with 15=
GB):
> >> unmodified kernel - Guest1:21s, Guest2:27s, Guest3:2m37s swap used =3D=
 3.7GB
> >> v11 page hinting - Guest1:23s, Guest2:26s, Guest3:21s swap used =3D 0
> >> v1 bubble hinting - Guest1:23, Guest2:11s, Guest3:26s swap used =3D 0
> >>
> >> For this particular test-case in a guest which doesn't require swap ac=
cess
> >> "memhog 6G" execution time lies within a range of 15-30s.
> >> Conclusion -
> >> In the above test case for an unmodified kernel on executing memhog in=
 the
> >> third guest execution time rises to above 2minutes due to swap access.
> >> Using either page-hinting or bubble hinting brings this execution time=
 to a
> >> a normal range of 15-30s.
> > So really this test doesn't add much in value. The whole reason why
> > Guest3 runs so much slower is because it is going to swap. I initially
> > did this to demonstrate a point, but now running this test doesn't
> > prove much as it isn't really meant to be a performance test. It is
> > essentially just a duplicate of the "how many guests can you run" test
> > that is passing itself off as some sort of performance test.
> >
> > We could probably just drop this from future version of this as long
> > as we verify that the memory hinting is freeing most of the memory
> > back and the guest is reporting a size less than the total guest
> > memory size.
> >
> +1, makes sense to keep just one of the above two.
> >> Setup & procedure -
> >> Total NUMA Node Memory ~ 15 GB (All guests are run on a single NUMA no=
de)
> >> Guest Memory =3D 6GB
> >> Number of CPUs in the guest =3D 4
> >> Process =3D 3 Guests are launched and the =E2=80=98memhog 6G=E2=80=99 =
execution time is monitored
> >> one after the other in each of them.
> >> Host swap =3D 4GB
> >>
> >> Performance Analysis:
> >> 1. will-it-scale's page_faul1
> >> Setup -
> >> Guest Memory =3D 6GB
> >> Number of cores =3D 24
> >>
> >> Unmodified kernel -
> >> 0,0,100,0,100,0
> >> 1,514453,95.84,519502,95.83,519502
> >> 2,991485,91.67,932268,91.68,1039004
> >> 3,1381237,87.36,1264214,87.64,1558506
> >> 4,1789116,83.36,1597767,83.88,2078008
> >> 5,2181552,79.20,1889489,80.08,2597510
> >> 6,2452416,75.05,2001879,77.10,3117012
> >> 7,2671047,70.90,2263866,73.22,3636514
> >> 8,2930081,66.75,2333813,70.60,4156016
> >> 9,3126431,62.60,2370108,68.28,4675518
> >> 10,3211937,58.44,2454093,65.74,5195020
> >> 11,3162172,54.32,2450822,63.21,5714522
> >> 12,3154261,50.14,2272290,58.98,6234024
> >> 13,3115174,46.02,2369679,57.74,6753526
> >> 14,3150511,41.86,2470837,54.02,7273028
> >> 15,3134158,37.71,2428129,51.98,7792530
> >> 16,3143067,33.57,2340469,49.54,8312032
> >> 17,3112457,29.43,2263627,44.81,8831534
> >> 18,3089724,25.29,2181879,38.69,9351036
> >> 19,3076878,21.15,2236505,40.01,9870538
> >> 20,3091978,16.95,2266327,35.00,10390040
> >> 21,3082927,12.84,2172578,28.12,10909542
> >> 22,3055282,8.73,2176269,29.14,11429044
> >> 23,3081144,4.56,2138442,24.87,11948546
> >> 24,3075509,0.45,2173753,21.62,12468048
> >>
> >> page hinting -
> >> 0,0,100,0,100,0
> >> 1,491683,95.83,494366,95.82,494366
> >> 2,988415,91.67,919660,91.68,988732
> >> 3,1344829,87.52,1244608,87.69,1483098
> >> 4,1797933,83.37,1625797,83.70,1977464
> >> 5,2179009,79.21,1881534,80.13,2471830
> >> 6,2449858,75.07,2078137,76.82,2966196
> >> 7,2732122,70.90,2178105,73.75,3460562
> >> 8,2910965,66.75,2340901,70.28,3954928
> >> 9,3006665,62.61,2353748,67.91,4449294
> >> 10,3164752,58.46,2377936,65.08,4943660
> >> 11,3234846,54.32,2510149,63.14,5438026
> >> 12,3165477,50.17,2412007,59.91,5932392
> >> 13,3141457,46.05,2421548,57.85,6426758
> >> 14,3135839,41.90,2378021,53.81,6921124
> >> 15,3109113,37.75,2269290,51.76,7415490
> >> 16,3093613,33.62,2346185,48.73,7909856
> >> 17,3086542,29.49,2352140,46.19,8404222
> >> 18,3048991,25.36,2217144,41.52,8898588
> >> 19,2965500,21.18,2313614,38.18,9392954
> >> 20,2928977,17.05,2175316,35.67,9887320
> >> 21,2896667,12.91,2141311,28.90,10381686
> >> 22,3047782,8.76,2177664,28.24,10876052
> >> 23,2994503,4.58,2160976,22.97,11370418
> >> 24,3038762,0.47,2053533,22.39,11864784
> >>
> >> bubble-hinting v1 -
> >> 0,0,100,0,100,0
> >> 1,515272,95.83,492355,95.81,515272
> >> 2,985903,91.66,919653,91.68,1030544
> >> 3,1475300,87.51,1353723,87.65,1545816
> >> 4,1783938,83.36,1586307,83.78,2061088
> >> 5,2093307,79.20,1867395,79.95,2576360
> >> 6,2441370,75.05,2055421,76.65,3091632
> >> 7,2650471,70.89,2246014,72.93,3606904
> >> 8,2926782,66.75,2333601,70.41,4122176
> >> 9,3107617,62.60,2383112,68.46,4637448
> >> 10,3192332,58.44,2441626,65.84,5152720
> >> 11,3268043,54.32,2235964,62.92,5667992
> >> 12,3191105,50.18,2449045,60.49,6183264
> >> 13,3145317,46.05,2377317,57.80,6698536
> >> 14,3161552,41.91,2395814,53.26,7213808
> >> 15,3140443,37.77,2333200,51.42,7729080
> >> 16,3130866,33.65,2150967,46.11,8244352
> >> 17,3112894,29.52,2372068,45.93,8759624
> >> 18,3078424,25.39,2336211,39.85,9274896
> >> 19,3036457,21.27,2224821,35.25,9790168
> >> 20,3046330,17.13,2199755,37.43,10305440
> >> 21,2981130,12.98,2214862,28.67,10820712
> >> 22,3017481,8.84,2195996,29.69,11335984
> >> 23,2979906,4.68,2173395,25.90,11851256
> >> 24,2971170,0.52,2134311,21.89,12366528
> > Okay, so this doesn't match up with the results you gave me last time
> > (https://lore.kernel.org/lkml/afac6f92-74f5-4580-0303-12b7374e5011@redh=
at.com/),
> > and actually more closely matches what I was expecting to see. The
> > bubble-hinting patches are performing within a few percent of what the
> > baseline kernel was doing.
> Interestingly even with an unmodified kernel with every fresh boot, I
> observed a certain amount of variability in the results which I stated
> below.
> > I am assuming the results from before had
> > some additional debugging enabled for the bubble-hinting test that
> > wasn't enabled for the other ones.
>
> Nope, I had debugging options enabled for all the cases. This time
> around I disabled all the debug options.

We can agree to disagree I guess. Those debugging options had reduced
the throughput by over 30% on the guest kernel in my test runs. I was
never able to reproduce the data you reported as enabling the same
debug features on an unmodified kernel had reduced the throughput for
the test just the same as it did for the bubble hinting version. Were
you running the debug options on the host kernel or the guest? I
suppose it is possible that having those debug options enabled on the
host might trigger similar behavior to what you reported since you
were using MADV_FREE versus MADV_DONTNEED so you wouldn't have to
reallocate the pages and could circumvent the page allocation
debugging.

> >
> >> Conclusion -
> >> For an unmodified kernel, with every fresh boot, there is 3-4% delta o=
bserved
> >> in the results wrt the numbers mentioned above. For both bubble-hintin=
g and
> >> page-hinting, there was no noticeable degradation observed other than =
the
> >> expected variability mentioned earlier.
> >>
> >> Page hinting vs bubble hinting:
> >> From the benefits and performance perspective, both solutions look qui=
te similar
> >> so far. However, unlike bubble-hinting which is more invasive, the ove=
rall core
> >> mm changes required for page hinting are minimal.
> >>
> >> [1] https://lkml.org/lkml/2019/6/19/926
> > So I think I called it out in the review of the patch but I think we
> > may want to see what happens if we increase the size of the memory in
> > the guest to something more like 64G or larger. My main concern is
> > that as we increase the size of memory the walk through the bitmap is
> > going to become more and more expensive and I am worried that at some
> > point it will start impacting the results.
> Ok, I can try that scenario.
>
>
>
> --
> Thanks
> Nitesh
>

