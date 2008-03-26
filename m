Date: Wed, 26 Mar 2008 07:18:24 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/12] cpumask: reduce stack pressure from local/passed
	cpumask variables v2
Message-ID: <20080326061824.GB18301@elte.hu>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Modify usage of cpumask_t variables to use pointers as much as 
> possible.

hm, why is there no minimal patch against -git that does nothing but 
introduces the new pointer based generic APIs (without using them) - 
such as set_cpus_allowed_ptr(), etc.? Once that is upstream all the 
remaining changes can trickle one arch and one subsystem at a time, and 
once that's done, the old set_cpus_allowed() can be removed. This is far 
more manageable than one large patch.

and the cpumask_of_cpu() change should be Kconfig based initially - once 
all arches have moved to it (or even sooner) we can remove that.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
