Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 732A06B0332
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 02:42:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g26-v6so1276210edp.13
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 23:42:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t26-v6si2688363ejr.158.2018.10.26.23.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 23:42:42 -0700 (PDT)
Date: Sat, 27 Oct 2018 08:42:40 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181027064240.GG18839@dhcp22.suse.cz>
References: <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <20181026080019.GX18839@dhcp22.suse.cz>
 <CADF2uSobj6fkvwObaU9mkhksyTGeqxQi1Vcyx2=HfJ1fVqfKDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSobj6fkvwObaU9mkhksyTGeqxQi1Vcyx2=HfJ1fVqfKDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>

On Sat 27-10-18 01:31:05, Marinko Catovic wrote:
> Am Fr., 26. Okt. 2018 um 10:02 Uhr schrieb Michal Hocko <mhocko@suse.com>:
> >
> > Sorry for late reply. Busy as always...
> >
> > On Mon 22-10-18 03:19:57, Marinko Catovic wrote:
> > [...]
> > > There we go again.
> > >
> > > First of all, I have set up this monitoring on 1 host, as a matter of
> > > fact it did not occur on that single
> > > one for days and weeks now, so I set this up again on all the hosts
> > > and it just happened again on another one.
> > >
> > > This issue is far from over, even when upgrading to the latest 4.18.12
> > >
> > > https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> > > https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz
> >
> > I cannot download these. I am getting an invalid certificate and
> > 403 when ignoring it
> 
> are you sure about that? I can download both just fine, different
> browsers, the cert seems fine, no 403 there.

Interesting. It works now from my home network. Something must have been
fishy in the office network when I've tried the same thing.

I have it now. Will have a look at monday at earliest.
-- 
Michal Hocko
SUSE Labs
