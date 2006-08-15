Subject: Re: [RFC][PATCH] "challenged" memory controller
From: Dave Hansen <dave@sr71.net>
In-Reply-To: <20060815150721.21ff961e.pj@sgi.com>
References: <20060815192047.EE4A0960@localhost.localdomain>
	 <20060815150721.21ff961e.pj@sgi.com>
Content-Type: text/plain
Date: Tue, 15 Aug 2006 15:24:13 -0700
Message-Id: <1155680653.18883.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, balbir@in.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-15 at 15:07 -0700, Paul Jackson wrote:
>  1) This is missing some cpuset locking - look at the routine
>     kernel/cpuset.c:__cpuset_memory_pressure_bump() for the
>     locking required to reference current->cpuset, using task_lock().
>     Notice that the current->cpuset reference is not valid once
>     the task lock is dropped.

Good to know.

>  3) There appears to be little sympathy for hanging memory controllers
>     off the cpuset structure.  There is probably good technical reason
>     for this; though at a minimum, the folks doing memory sharing
>     controllers and the folks doing big honking NUMA iron placement have
>     different perspectives.

Oh, I don't want to use cpusets in the future.  I was just using them
basically for the task grouping that they can give me.  I don't think
they're a really good long-term fit for these resource group things.

Ignore the cpuset-ish parts for now, if you can. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
