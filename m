Date: Thu, 3 Jul 2008 21:27:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
Message-Id: <20080703212707.e0f6bbda.akpm@linux-foundation.org>
In-Reply-To: <486D970F.2000607@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0807032143110.10641@blonde.site>
	<20080703160117.b3781463.akpm@linux-foundation.org>
	<486D81B9.9030704@linux.vnet.ibm.com>
	<20080703190123.1d72e9d1.akpm@linux-foundation.org>
	<486D970F.2000607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 04 Jul 2008 08:50:47 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > I was referring to the below (which is where the conversation ended).
> > 
> > It questions the basis of the whole feature.
> > 
> 
> In the email below, I referred to Hugh's comment on tracking total_vm as a more
> achievable target and it gives a rough approximation of something worth
> limiting. I agree with him on those points and mentioned my motivation for the
> memrlimit patchset. We also look forward to enhancing memrlimit to control
> mlock'ed pages (as it provides the generic infrastructure to control RLIMIT'ed
> resources). Given Hugh's comment, I looked at it from the more positive side
> rather the pessimistic angle. I've had discussions along these lines with Paul
> Menage and Kamezawa. In the past we've discussed and there are cases where
> memrlimit is not useful (large VM allocations with sparse usage), but there are
> cases as mentioned below in the motivation for memrlimits as to why and where
> they are useful.
> 
> If there are suggestions to help improve the feature or provide similar
> functionality without the noise; I am all ears

Well I've never reeeeeeealy understood what the whole feature is for.

+Advantages of providing this feature
+
+1. Control over virtual address space allows for a cgroup to fail gracefully
+   i.e., via a malloc or mmap failure as compared to OOM kill when no
+   pages can be reclaimed.
+2. It provides better control over how many pages can be swapped out when
+   the cgroup goes over its limit. A badly setup cgroup can cause excessive
+   swapping. Providing control over the address space allocations ensures
+   that the system administrator has control over the total swapping that
+   can take place.

umm, OK.  I'm not sure _why_ someone would want to do that.  Perhaps
some use-cases would help motivate us.  Perhaps desriptions of
real-world operational problems would would be improved or solved were
this feature available to the operator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
