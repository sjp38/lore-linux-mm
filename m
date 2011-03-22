Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFF58D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 13:06:44 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2MH6Xen006572
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 10:06:35 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by kpbe17.cbf.corp.google.com with ESMTP id p2MH5ivS027088
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 10:06:32 -0700
Received: by qyk32 with SMTP id 32so5716298qyk.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 10:06:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110322073514.GB12940@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
	<20110321093419.GA26047@tiehlicka.suse.cz>
	<AANLkTimkcYcZVifaq4pH4exkWUVNXpwXA=9oyeAn_EqR@mail.gmail.com>
	<20110322073514.GB12940@tiehlicka.suse.cz>
Date: Tue, 22 Mar 2011 10:06:27 -0700
Message-ID: <AANLkTi=2t_tL=Vt4athAyQ1tDhLDGpqtmu-iAOjdbPBJ@mail.gmail.com>
Subject: Re: cgroup: real meaning of memory.usage_in_bytes
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 22, 2011 at 12:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 21-03-11 10:22:41, Ying Han wrote:
> [...]
>>
>> Michal,
>>
>> Can you help to post the test result after applying the patch?
>
> The result of the LTP test is:
> TEST 4: MEMORY CONTROLLER TESTING
> RUNNING SETUP.....
> WARN:/dev/memctl already exist..overwriting
> Cleanup called
> TEST STARTED: Please avoid using system while this test executes
> memory usage from memory.usage_in_bytes=3D 62955520
> memory usage from memory.stat=3D 62955520
> TINFO =A0 Memory Resource Controller: stat check test passes first run
> Test continues to run the second step.
> memory usage from memory.usage_in_bytes=3D 78643200
> memory usage from memory.stat=3D78643200
> TPASS =A0 Memory Resource Controller: stat check test PASSED
> Memory Resource Controller test executed successfully.
> Cleanup called
>
> The attached simple test case result is:
> # mkdir /dev/memctl; mount -t cgroup -omemory cgroup /dev/memctl; cd /dev=
/memctl
> # mkdir group_1; cd group_1; echo 100M > memory.limit_in_bytes
> # cat memory.{usage_in_bytes,stat}
> 0
> cache 0
> rss 0
> [start the test case, add its pid to the group and let it fault in]
>
> # cat memory.{usage_in_bytes,stat}
> 4096
> cache 0
> rss 4096
>
> [let it finish]
> # cat memory.{usage_in_bytes,stat}
> 0
> cache 0
> rss 0
>
> Thanks

Thanks Michal for fixing it up. Regardless of the performance
overhead, the change make sense to me.

--Ying

> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
