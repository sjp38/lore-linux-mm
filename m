Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D260E6B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 01:06:59 -0400 (EDT)
From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Tue, 19 May 2009 13:06:11 +0800
Subject: RE: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <4D05DB80B95B23498C72C700BD6C2E0B2EF6E313@pdsmsx502.ccr.corp.intel.com>
References: <20090519102634.4EB4.A69D9226@jp.fujitsu.com>
 <4D05DB80B95B23498C72C700BD6C2E0B2EF6E29A@pdsmsx502.ccr.corp.intel.com>
 <20090519125744.4EC3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090519125744.4EC3.A69D9226@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>>-----Original Message-----
>>From: KOSAKI Motohiro [mailto:kosaki.motohiro@jp.fujitsu.com]
>>Sent: 2009=1B$BG/=1B(B5=1B$B7n=1B(B19=1B$BF|=1B(B 12:31
>>To: Zhang, Yanmin
>>Cc: kosaki.motohiro@jp.fujitsu.com; Wu, Fengguang; LKML; linux-mm; Andrew
>>Morton; Rik van Riel; Christoph Lameter
>>Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
>>
>>> >>-----Original Message-----
>>> >>From: KOSAKI Motohiro [mailto:kosaki.motohiro@jp.fujitsu.com]
>>> >>Sent: 2009=1B$B%H!&%d%D=1B(B19=1B$B%M%f=1B(B 10:54
>>> >>To: Wu, Fengguang
>>> >>Cc: kosaki.motohiro@jp.fujitsu.com; LKML; linux-mm; Andrew Morton; Ri=
k van
>>> >>Riel; Christoph Lameter; Zhang, Yanmin
>>> >>Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
>>> >>
>>> >>> On Wed, May 13, 2009 at 12:08:12PM +0900, KOSAKI Motohiro wrote:
>>> >>> > Subject: [PATCH] zone_reclaim_mode is always 0 by default
>>> >>> >
>>> >>> > Current linux policy is, if the machine has large remote node dis=
tance,
>>> >>> >  zone_reclaim_mode is enabled by default because we've be able to=
 assume
>>> >>Fortunately (or Unfortunately), typical workload and machine size had
>>> >>significant mutuality.
>>> >>Thus, the current default setting calculation had worked well in past=
 days.
>>> [YM] Your analysis is clear and deep.
>>
>>Thanks!
>>
>>
>>> >>Now, it was breaked. What should we do?
>>> >>Yanmin, We know 99% linux people use intel cpu and you are one of
>>> >>most hard repeated testing
>>> [YM] It's very easy to reproduce them on my machines. :) Sometimes, bec=
ause
>>the
>>> issues only exist on machines with lots of cpu while other community
>>developers
>>> have no such environments.
>>>
>>>
>>>  guy in lkml and you have much test.
>>> >>May I ask your tested machine and benchmark?
>>> [YM] Usually I started lots of benchmark testing against the latest ker=
nel,
>>but
>>> as for this issue, it's reported by a customer firstly. The customer ru=
ns
>>apache
>>> on Nehalem machines to access lots of files. So the issue is an example=
 of
>>file
>>> server.
>>
>>hmmm.
>>I'm surprised this report. I didn't know this problem. oh..
[YM] Did you run file server workload on such NUMA machine with
 zone_reclaim_mode=3D1? If all nodes have the same memory, the behavior is
obvious.


>>
>>Actually, I don't think apache is only file server.
>>apache is one of killer application in linux. it run on very widely
>>organization.
[YM] I know that. Apache could support document, ecommerce, and lots of oth=
er
usage models. What I mean is one of customers hit it with their
workload.


>>you think large machine don't run apache? I don't think so.
>>
>>
>>
>>> BTW, I found many test cases of fio have big drop after I upgraded BIOS=
 of
>>one
>>> Nehalem machine. By checking vmstat data, I found almost a half memory =
is
>>always free. It's also related to zone_reclaim_mode because new BIOS chan=
ges
>>the node
>>> distance to a large value. I use numactl --interleave=3Dall to walkarou=
nd the
>>problem temporarily.
>>>
>>> I have no HPC environment.
>>
>>Yeah, that's ok. I and cristoph have. My worries is my unknown workload b=
ecome
>>regression.
>>so, May I assume you run your benchmark both zonre reclaim 0 and 1 and yo=
u
>>haven't seen regression by non-zone reclaim mode?
[YM] what is non-zone reclaim mode? When zone_reclaim_mode=3D0?
I didn't do that intentionally. Currently I just make sure FIO has a big dr=
op
 when zone_reclaim_mode=3D1. I might test it with other benchmarks on 2 Neh=
alem machines.


>>if so, it encourage very much to me.
>>
>>if zone reclaim mode disabling don't have regression, I'll pushing to
>>remove default zone reclaim mode completely again.
[YM] I run lots of benchmarks, but it doesn't mean I run all benchmarks, es=
pecially
no HPC.=20


>>
>>
>>> >>if zone_reclaim=3D0 tendency workload is much than zone_reclaim=3D1 t=
endency
>>> >>workload,
>>> >> we can drop our afraid and we would prioritize your opinion, of cour=
ce.
>>> So it seems only file servers have the issue currently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
