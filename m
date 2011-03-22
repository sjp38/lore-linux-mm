Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD3078D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 03:35:19 -0400 (EDT)
Date: Tue, 22 Mar 2011 08:35:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: cgroup: real meaning of memory.usage_in_bytes
Message-ID: <20110322073514.GB12940@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
 <20110321093419.GA26047@tiehlicka.suse.cz>
 <AANLkTimkcYcZVifaq4pH4exkWUVNXpwXA=9oyeAn_EqR@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimkcYcZVifaq4pH4exkWUVNXpwXA=9oyeAn_EqR@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 21-03-11 10:22:41, Ying Han wrote:
[...]
> 
> Michal,
> 
> Can you help to post the test result after applying the patch?

The result of the LTP test is:
TEST 4: MEMORY CONTROLLER TESTING
RUNNING SETUP.....
WARN:/dev/memctl already exist..overwriting
Cleanup called
TEST STARTED: Please avoid using system while this test executes
memory usage from memory.usage_in_bytes= 62955520
memory usage from memory.stat= 62955520
TINFO   Memory Resource Controller: stat check test passes first run
Test continues to run the second step.
memory usage from memory.usage_in_bytes= 78643200
memory usage from memory.stat=78643200
TPASS   Memory Resource Controller: stat check test PASSED
Memory Resource Controller test executed successfully.
Cleanup called

The attached simple test case result is:
# mkdir /dev/memctl; mount -t cgroup -omemory cgroup /dev/memctl; cd /dev/memctl
# mkdir group_1; cd group_1; echo 100M > memory.limit_in_bytes
# cat memory.{usage_in_bytes,stat} 
0
cache 0
rss 0
[start the test case, add its pid to the group and let it fault in]

# cat memory.{usage_in_bytes,stat} 
4096
cache 0
rss 4096

[let it finish]
# cat memory.{usage_in_bytes,stat} 
0
cache 0
rss 0

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
