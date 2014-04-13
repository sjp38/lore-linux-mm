Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 88A9B6B00A7
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 14:05:40 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so5877656eei.0
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 11:05:40 -0700 (PDT)
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
        by mx.google.com with ESMTPS id p8si18104057eew.156.2014.04.13.11.05.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Apr 2014 11:05:39 -0700 (PDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so5752012eek.18
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 11:05:38 -0700 (PDT)
Message-ID: <534AD1EE.3050705@colorfullife.com>
Date: Sun, 13 Apr 2014 20:05:34 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org> <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <1396389751.25314.26.camel@buesod1.americas.hpqcorp.net> <20140401150843.13da3743554ad541629c936d@linux-foundation.org>
In-Reply-To: <20140401150843.13da3743554ad541629c936d@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Andrew,

On 04/02/2014 12:08 AM, Andrew Morton wrote:
> Well, I'm assuming 64GB==infinity. It *was* infinity in the RHEL5 
> timeframe, but infinity has since become larger so pickanumber. 

I think infinity is the right solution:
The only common case where infinity is wrong would be Android - and 
Android disables sysv shm entirely.

There are two patches:
http://marc.info/?l=linux-kernel&m=139730332306185&q=raw
http://marc.info/?l=linux-kernel&m=139727299800644&q=raw

Could you apply one of them?
I wrote the first one, thus I'm biased which one is better.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
