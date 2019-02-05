Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67019C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBFA820844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 13:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBFA820844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BA118E0089; Tue,  5 Feb 2019 08:38:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 572848E001C; Tue,  5 Feb 2019 08:38:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F7A8E0089; Tue,  5 Feb 2019 08:38:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7AA8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 08:38:15 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x64so2393024ywc.6
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 05:38:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zQ6n0WdlJvS56MEW24PPZw5NTVMV8Pk9faYEan8S8tM=;
        b=G8JsOHJM93BpOFQ6tmW/UDqukb4V1JEuhLPjCkue4yxNJECenO6jYmzcRGwLcCHX65
         AYpZiBypfViAvdCIE1rt6kYkbLXThg6AW0cJateb6kN/MOl23vbotlggpyZ+1oTjmKJC
         MuJRdwAVoMKrBHx2kZBsXcU98hJkrqkKHCXuRdTzSVeH4Hp2uLAa2qehGgLidZHk5Cpw
         q4U4x0NtTWdu3j92BpQ43ABy4/cHwBaZx07d89Z2JWUijjKyxBivBV+KVkTFrb/88bwn
         ijDxJfVOT8FGRzu56DfwzTo/QjAW6WDvuTxW3kMPZUPMS80bGMYTHAGMqMaGXqmgtB42
         nXBA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 68.178.252.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
X-Gm-Message-State: AHQUAuZU20jHrFqAqn0vFT4H+CwyG5tCDsTkFCAhFwSZBuQSBFA+UxxM
	A5QtEAK02XgUzbk5jO2kuDwfS7fo/UToJb1x2RR+P5fyHIjT7uTNtume8QylAQQ9zo3GqI1ZWhf
	pw638v1UyJv9ouTxhxFp7Mtdj1bDG9ym6b+x32szdmpRsI8/Y3Vlb88NvrzJzWvk=
X-Received: by 2002:a81:ad09:: with SMTP id l9mr3962366ywh.4.1549373894699;
        Tue, 05 Feb 2019 05:38:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWWmQiK7AR1YpZyJKUQ6f6oDz1E7zggfesaaXzgpwe467Ymoq3BjhZeVpsyJdFNEq4+lpc
X-Received: by 2002:a81:ad09:: with SMTP id l9mr3962302ywh.4.1549373893733;
        Tue, 05 Feb 2019 05:38:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549373893; cv=none;
        d=google.com; s=arc-20160816;
        b=oaOMRRWfFmLyyxHf1IkR79yXGblLCAvLkuq2HDZYDiotzt8jd9qls5FWz/+ICyL8Ld
         2QueYw+/PqSSBRmGggw1qG39Mc3fHnBJIkT7SNT5Zu0HrEFNtME6zuT6FzDCyh3Ul6v0
         X3sTKi/Poyr7sy5wViIG/Eff4Eyb99RyLznMDfAx+i1TPnotWUtXeIok0qknTA9cTKqe
         H3vuXVn+nBv5YdYSo+3PCEuxbrPy+xDpVdBKnYyaJoYO62gtiJC+UDtdqqPkFjwxHMwG
         uCvXN9ZhgcaZLA4vIHV228oRl15iaw6omNs0dO1MV4xOcDEb/Samg6DWCzI8hc5exphC
         IB1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zQ6n0WdlJvS56MEW24PPZw5NTVMV8Pk9faYEan8S8tM=;
        b=rJ4wRjeHnF1swioyVXi2XfXryeLMZpEmHNGR6BXC/GqrgN0r42VJBUPqriw0lUaSTB
         oEbkq2hwz/Ryo9s9FA/kFoomLmgO4+u0DRJfTcb8hHdphfbnZkFWPsAi9RCZpq4tKP9I
         x4yGLmry+jOaaC1Li5Z/tn+i0dvjm/TjMDh8kzDb+k7mjX2hUPxokK8o3NII6ZWXIdcf
         bsyhEPjZNS7oIR9T48amzogJQsUzrDQ0Dv3o738pTJ5/0Lw+44QvOmcoTN/vzXfMWI7W
         F6OeFmqPXU+58wC6xqD3/X+ptr3KZfoGJGt649Hab3jbHCVIZpLbpxbIjgYiHfq51kXw
         pZ7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 68.178.252.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from p3plsmtpa12-10.prod.phx3.secureserver.net (p3plsmtpa12-10.prod.phx3.secureserver.net. [68.178.252.239])
        by mx.google.com with ESMTPS id z18si1762933ybg.481.2019.02.05.05.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 05:38:13 -0800 (PST)
Received-SPF: neutral (google.com: 68.178.252.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) client-ip=68.178.252.239;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 68.178.252.239 is neither permitted nor denied by best guess record for domain of tom@talpey.com) smtp.mailfrom=tom@talpey.com
Received: from [192.168.0.55] ([24.218.182.144])
	by :SMTPAUTH: with ESMTPSA
	id r0vTg40O9TD2Er0vTgUdQL; Tue, 05 Feb 2019 06:38:13 -0700
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>,
 Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>,
 Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
 Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mike Rapoport <rppt@linux.ibm.com>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-fsdevel@vger.kernel.org
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <dbca5400-b0c0-0958-c3ba-ff672f301799@talpey.com>
 <80d503f5-038b-7f0b-90d5-e5b9537ae1df@nvidia.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <303ab506-62b7-ee6d-27a0-a818c7ff6473@talpey.com>
Date: Tue, 5 Feb 2019 08:38:10 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <80d503f5-038b-7f0b-90d5-e5b9537ae1df@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-CMAE-Envelope: MS4wfE3sP9dmfKcdvwJu410G2UxRjEbmm6Bp6I7HmkY03jHAbVJ8gN0XGZjMEc8grcrNKHP027cPIJnqRShJVl+GeERwSBU7SKYnjDo13e/2ROLUnwgzxGWi
 s/qokzrXZU3/VReIjTIS39+fLyK9wffXvjeaDBpbzBGhYSAEOKE1A5X9qlp2opXuxTNKcI1h+fx8GxeB10oiU9PxDUAZinynjeCnCcN5PE9HbppRSiQ1aTIO
 WO+SxL0wqqsHTSnk8gFbpqnye0KQgUlA3VT0cLXo6O0cEm894EWz0ZrpWUJVFyg2APLM1M2FtMlTAyXzL2xoiwV0d6oTYsjLvEhj4MCOO0R3MO6nilxR7sBD
 L8HPz1PD3xaByXrrud5gzvelN0M78eUZlpHbz+VSalYyEQ0lDLpOwlgnZHu3UO7bTjaGiWnonPDLHhT2bVou9s7E92JRDyEiymtUxcedDEaXzsdXfBFeIXlE
 JpA+F+hGjA4uclD9mIMQ5hZWvNY6/DyZbVbSRoSvtLjpwo3AM0EIvUZE0p9nB3wLU9VDR3mBqQsHnbikPxobZaHs+giBiymWgoX0QLFC3LmNslanL3SS+bRP
 loq9GW9DnSY/5pM9IocZfg0RD0ZbypLBXrZxzHyAOBmpmyUF3Se7w0g8GEi0kfvH11XueQTkll898OPjWfuMAiZgKxK4FAb2qssrdjiULQGFFxXYa5DgHtMI
 q6DTPNb1o0Ixb/YIbixT/k2bpmSReUCNXhqEPOihc45hmhEIbKvi6CmbSbhcLCnODeo7DnvuY9Lj/ulDNBPLKzNOwwZjwmSwZ91mLSUc9z4evUqZuLyg/rZr
 U+bUPPeaWAdDt9gpsrE=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/5/2019 3:22 AM, John Hubbard wrote:
> On 2/4/19 5:41 PM, Tom Talpey wrote:
>> On 2/4/2019 12:21 AM, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
>>>
>>>
>>> Performance: here is an fio run on an NVMe drive, using this for the fio
>>> configuration file:
>>>
>>>      [reader]
>>>      direct=1
>>>      ioengine=libaio
>>>      blocksize=4096
>>>      size=1g
>>>      numjobs=1
>>>      rw=read
>>>      iodepth=64
>>>
>>> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 
>>> 4096B-4096B, ioengine=libaio, iodepth=64
>>> fio-3.3
>>> Starting 1 process
>>> Jobs: 1 (f=1)
>>> reader: (groupid=0, jobs=1): err= 0: pid=7011: Sun Feb  3 20:36:51 2019
>>>     read: IOPS=190k, BW=741MiB/s (778MB/s)(1024MiB/1381msec)
>>>      slat (nsec): min=2716, max=57255, avg=4048.14, stdev=1084.10
>>>      clat (usec): min=20, max=12485, avg=332.63, stdev=191.77
>>>       lat (usec): min=22, max=12498, avg=336.72, stdev=192.07
>>>      clat percentiles (usec):
>>>       |  1.00th=[  322],  5.00th=[  322], 10.00th=[  322], 20.00th=[ 
>>> 326],
>>>       | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[ 
>>> 326],
>>>       | 70.00th=[  326], 80.00th=[  330], 90.00th=[  330], 95.00th=[ 
>>> 330],
>>>       | 99.00th=[  478], 99.50th=[  717], 99.90th=[ 1074], 99.95th=[ 
>>> 1090],
>>>       | 99.99th=[12256]
>>
>> These latencies are concerning. The best results we saw at the end of
>> November (previous approach) were MUCH flatter. These really start
>> spiking at three 9's, and are sky-high at four 9's. The "stdev" values
>> for clat and lat are about 10 times the previous. There's some kind
>> of serious queuing contention here, that wasn't there in November.
> 
> Hi Tom,
> 
> I think this latency problem is also there in the baseline kernel, but...
> 
>>
>>>     bw (  KiB/s): min=730152, max=776512, per=99.22%, avg=753332.00, 
>>> stdev=32781.47, samples=2
>>>     iops        : min=182538, max=194128, avg=188333.00, 
>>> stdev=8195.37, samples=2
>>>    lat (usec)   : 50=0.01%, 100=0.01%, 250=0.07%, 500=99.26%, 750=0.38%
>>>    lat (usec)   : 1000=0.02%
>>>    lat (msec)   : 2=0.24%, 20=0.02%
>>>    cpu          : usr=15.07%, sys=84.13%, ctx=10, majf=0, minf=74
>>
>> System CPU 84% is roughly double the November results of 45%. Ouch.
> 
> That's my fault. First of all, I had a few extra, supposedly minor debug
> settings in the .config, which I'm removing now--I'm doing a proper run
> with the original .config file from November, below. Second, I'm not
> sure I controlled the run carefully enough.
> 
>>
>> Did you re-run the baseline on the new unpatched base kernel and can
>> we see the before/after?
> 
> Doing that now, I see:
> 
> -- No significant perf difference between before and after, but
> -- Still high clat in the 99.99th
> 
> =======================================================================
> Before: using commit 8834f5600cf3 ("Linux 5.0-rc5")
> ===================================================
> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 
> 4096B-4096B, ioengine=libaio, iodepth=64
> fio-3.3
> Starting 1 process
> Jobs: 1 (f=1)
> reader: (groupid=0, jobs=1): err= 0: pid=1829: Tue Feb  5 00:08:08 2019
>     read: IOPS=193k, BW=753MiB/s (790MB/s)(1024MiB/1359msec)
>      slat (nsec): min=1269, max=40309, avg=1493.66, stdev=534.83
>      clat (usec): min=127, max=12249, avg=329.83, stdev=184.92
>       lat (usec): min=129, max=12256, avg=331.35, stdev=185.06
>      clat percentiles (usec):
>       |  1.00th=[  326],  5.00th=[  326], 10.00th=[  326], 20.00th=[  326],
>       | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[  326],
>       | 70.00th=[  326], 80.00th=[  326], 90.00th=[  326], 95.00th=[  326],
>       | 99.00th=[  347], 99.50th=[  519], 99.90th=[  529], 99.95th=[  537],
>       | 99.99th=[12125]
>     bw (  KiB/s): min=755032, max=781472, per=99.57%, avg=768252.00, 
> stdev=18695.90, samples=2
>     iops        : min=188758, max=195368, avg=192063.00, stdev=4673.98, 
> samples=2
>    lat (usec)   : 250=0.08%, 500=99.18%, 750=0.72%
>    lat (msec)   : 20=0.02%
>    cpu          : usr=12.30%, sys=46.83%, ctx=253554, majf=0, minf=74
>    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, 
>  >=64=100.0%
>       submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, 
>  >=64=0.0%
>       complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, 
>  >=64=0.0%
>       issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
>       latency   : target=0, window=0, percentile=100.00%, depth=64
> 
> Run status group 0 (all jobs):
>     READ: bw=753MiB/s (790MB/s), 753MiB/s-753MiB/s (790MB/s-790MB/s), 
> io=1024MiB (1074MB), run=1359-1359msec
> 
> Disk stats (read/write):
>    nvme0n1: ios=221246/0, merge=0/0, ticks=71556/0, in_queue=704, 
> util=91.35%
> 
> =======================================================================
> After:
> =======================================================================
> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 
> 4096B-4096B, ioengine=libaio, iodepth=64
> fio-3.3
> Starting 1 process
> Jobs: 1 (f=1)
> reader: (groupid=0, jobs=1): err= 0: pid=1803: Mon Feb  4 23:58:07 2019
>     read: IOPS=193k, BW=753MiB/s (790MB/s)(1024MiB/1359msec)
>      slat (nsec): min=1276, max=41900, avg=1505.36, stdev=565.26
>      clat (usec): min=177, max=12186, avg=329.88, stdev=184.03
>       lat (usec): min=178, max=12192, avg=331.42, stdev=184.16
>      clat percentiles (usec):
>       |  1.00th=[  326],  5.00th=[  326], 10.00th=[  326], 20.00th=[  326],
>       | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[  326],
>       | 70.00th=[  326], 80.00th=[  326], 90.00th=[  326], 95.00th=[  326],
>       | 99.00th=[  359], 99.50th=[  498], 99.90th=[  537], 99.95th=[  627],
>       | 99.99th=[12125]
>     bw (  KiB/s): min=754656, max=781504, per=99.55%, avg=768080.00, 
> stdev=18984.40, samples=2
>     iops        : min=188664, max=195378, avg=192021.00, stdev=4747.51, 
> samples=2
>    lat (usec)   : 250=0.12%, 500=99.40%, 750=0.46%
>    lat (msec)   : 20=0.02%
>    cpu          : usr=12.44%, sys=47.05%, ctx=252127, majf=0, minf=73
>    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, 
>  >=64=100.0%
>       submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, 
>  >=64=0.0%
>       complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, 
>  >=64=0.0%
>       issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
>       latency   : target=0, window=0, percentile=100.00%, depth=64
> 
> Run status group 0 (all jobs):
>     READ: bw=753MiB/s (790MB/s), 753MiB/s-753MiB/s (790MB/s-790MB/s), 
> io=1024MiB (1074MB), run=1359-1359msec
> 
> Disk stats (read/write):
>    nvme0n1: ios=221203/0, merge=0/0, ticks=71291/0, in_queue=704, 
> util=91.19%
> 
> How's this look to you?

Ok, I'm satisfied the four-9's latency spike is in not your code. :-)
Results look good relative to baseline. Thanks for doublechecking!

Tom.

