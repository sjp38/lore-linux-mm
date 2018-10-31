Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 991E56B000A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 03:34:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m45-v6so10385186edc.2
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 00:34:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20-v6si5781551ejj.20.2018.10.31.00.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 00:34:12 -0700 (PDT)
Date: Wed, 31 Oct 2018 08:34:11 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181031073411.GI32673@dhcp22.suse.cz>
References: <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <CADF2uSry7SNQE0NPazAtra-4OELPonnWzzhbrBcqGRiVKWRg5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSry7SNQE0NPazAtra-4OELPonnWzzhbrBcqGRiVKWRg5Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On Tue 30-10-18 19:26:32, Marinko Catovic wrote:
[...]
> > > I would not really know whether this is a NUMA, it is some usual
> > > server running with a i7-8700
> > > and ECC RAM. How would I find out?
> >
> > Please provide /proc/zoneinfo and we'll see.
> 
> there you go: cat /proc/zoneinfo     https://pastebin.com/RMTwtXGr

Nope, a single node machine so no NUMA.
-- 
Michal Hocko
SUSE Labs
