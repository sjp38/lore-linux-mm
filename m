Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0D36B4C40
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:27:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g18-v6so2426371edg.14
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:27:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b50-v6si4253468edc.408.2018.08.29.08.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 08:27:18 -0700 (PDT)
Date: Wed, 29 Aug 2018 17:27:16 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180829152716.GB10223@dhcp22.suse.cz>
References: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz>
 <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On Wed 29-08-18 17:13:59, Marinko Catovic wrote:
> >
> > trace data which starts _before_ the cache dropdown starts and while it
> > is decreasing should be the first step. Ideally along with /proc/vmstat
> > gathered at the same time. I am pretty sure you have some high order
> > memory consumer which forces the reclaim and we over reclaim. Last data
> > was not really conclusive as it didn't really captured the dropdown
> > IIRC.
> >
> 
> with before you mean in a totally healthy state?

yep

> as I can not tell when decreasing starts this would mean collecting data
> over days perhaps. however, I have no issue with that.

yeah, you can pipe the trace buffer to gzip and reduce the output
considerably.

> As I do not want to miss anything that might help you, could you please
> provide the commands for all the data you require?

Use the same set of commands for tracing I have provided earlier + add
the compresssion

cat /debug/trace/trace_pipe | gzip > file.gz

+ the loop to gather vmstat

while true
do
	cp /proc/vmstat vmstat.$(date +%s)
	sleep 5s
done

> one host is at a healthy state right now, I'd run that over there immediately.

Let's see what we can get from here.
-- 
Michal Hocko
SUSE Labs
