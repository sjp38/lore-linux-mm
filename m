Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD6216B032C
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 19:31:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i17-v6so2287094wre.5
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 16:31:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2-v6sor8814132wrm.40.2018.10.26.16.31.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Oct 2018 16:31:18 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com> <20181026080019.GX18839@dhcp22.suse.cz>
In-Reply-To: <20181026080019.GX18839@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Sat, 27 Oct 2018 01:31:05 +0200
Message-ID: <CADF2uSobj6fkvwObaU9mkhksyTGeqxQi1Vcyx2=HfJ1fVqfKDg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>

Am Fr., 26. Okt. 2018 um 10:02 Uhr schrieb Michal Hocko <mhocko@suse.com>:
>
> Sorry for late reply. Busy as always...
>
> On Mon 22-10-18 03:19:57, Marinko Catovic wrote:
> [...]
> > There we go again.
> >
> > First of all, I have set up this monitoring on 1 host, as a matter of
> > fact it did not occur on that single
> > one for days and weeks now, so I set this up again on all the hosts
> > and it just happened again on another one.
> >
> > This issue is far from over, even when upgrading to the latest 4.18.12
> >
> > https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> > https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz
>
> I cannot download these. I am getting an invalid certificate and
> 403 when ignoring it

are you sure about that? I can download both just fine, different
browsers, the cert seems fine, no 403 there.

> This is worth a separate discussion. Please start a new email thread.

I was merely looking for a real quick-hotfix there in the meantime,
also wondering why '10' is hardcoded
