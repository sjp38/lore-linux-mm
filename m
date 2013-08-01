Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 071CF6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 10:43:28 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:43:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V5 0/8] Add memcg dirty/writeback page accounting
Message-ID: <20130801144326.GI5198@dhcp22.suse.cz>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

On Thu 01-08-13 19:43:22, Sha Zhengju wrote:
[...]
> Some perforcemance numbers got by Mel's pft test (On a 4g memory and 4-core
> i5 CPU machine):

I am little bit confused what is this testcase actually testing... AFAIU
it produces a lot of page faults but they are all anonymous and very
short lived. So neither dirty nor writeback accounting is done.

I would have expected a testcase which generates a lot of IO.

Also as a general note. It would be better to mention the number of runs
and standard deviation so that we have an idea about variability of the
load.

> vanilla  : memcg enabled, patch not applied
> patched  : all patches are patched
> 
> * Duration numbers:
>              vanilla     patched
> User          385.38      379.47
> System         65.12       66.46
> Elapsed       457.46      452.21
> 
> * Summary numbers:
> vanilla:
> Clients User        System      Elapsed     Faults/cpu  Faults/sec  
> 1       0.03        0.18        0.21        931682.645  910993.850  
> 2       0.03        0.22        0.13        760431.152  1472985.863 
> 3       0.03        0.29        0.12        600495.043  1620311.084 
> 4       0.04        0.37        0.12        475380.531  1688013.267
> 
> patched:
> Clients User        System      Elapsed     Faults/cpu  Faults/sec  
> 1       0.02        0.19        0.22        915362.875  898763.732  
> 2       0.03        0.23        0.13        757518.387  1464893.996 
> 3       0.03        0.30        0.12        592113.126  1611873.469 
> 4       0.04        0.38        0.12        472203.393  1680013.271
> 
> We can see the performance gap is minor.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
