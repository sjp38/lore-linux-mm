Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 545836B0103
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 03:52:17 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so7321546pde.8
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 00:52:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bg3si15890125pbc.95.2014.11.10.00.52.15
        for <linux-mm@kvack.org>;
        Mon, 10 Nov 2014 00:52:16 -0800 (PST)
From: "Qin, Xiaokang" <xiaokang.qin@intel.com>
Subject: RE: [PATCH] proc/smaps: add proportional size of anonymous page
Date: Mon, 10 Nov 2014 08:48:12 +0000
Message-ID: <6212C327DC2094488C1AAAD903AF062B01BCE1E6@SHSMSX104.ccr.corp.intel.com>
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com>
 <545D3AFB.1080308@intel.com>
In-Reply-To: <545D3AFB.1080308@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Yin, Fengwei" <fengwei.yin@intel.com>

Hi, Dave

For some case especially under Android, anonymous page sharing is common, f=
or example:
70323000-70e41000 rw-p 00000000 fd:00 120004                             /d=
ata/dalvik-cache/x86/system@framework@boot.art
Size:              11384 kB
Rss:                8840 kB
Pss:                 927 kB
Shared_Clean:       5720 kB
Shared_Dirty:       2492 kB
Private_Clean:        16 kB
Private_Dirty:       612 kB
Referenced:         7896 kB
Anonymous:          3104 kB
PropAnonymous:       697 kB
AnonHugePages:         0 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
The only Anonymous here is confusing to me. What I really want to know is h=
ow many anonymous page is there in Pss. After exposing PropAnonymous, we co=
uld know 697/927 is anonymous in Pss.
I suppose the Pss - PropAnonymous =3D Proportional Page cache size for file=
 based memory and we want to break down the page cache into process level, =
how much page cache each process consumes.

Regards,
Xiaokang


-----Original Message-----
From: Hansen, Dave=20
Sent: Saturday, November 08, 2014 5:35 AM
To: Qin, Xiaokang; linux-mm@kvack.org
Cc: Yin, Fengwei
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page

On 11/07/2014 12:31 AM, Xiaokang Qin wrote:
> The "proportional anonymous page size" (PropAnonymous) of a process is=20
> the count of anonymous pages it has in memory, where each anonymous=20
> page is devided by the number of processes sharing it.

This seems like the kind of thing that should just be accounted for in the =
existing pss metric.  Why do we need a new, separate one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
