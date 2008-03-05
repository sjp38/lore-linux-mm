Message-ID: <47CEAAB4.8070208@openvz.org>
Date: Wed, 05 Mar 2008 17:14:12 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org> <Pine.LNX.4.64.0803051400000.22243@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0803051400000.22243@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 5 Mar 2008, Pavel Emelyanov wrote:
>> Daisuke Nishimura wrote:
>>> Todo:
>>>   - rebase new kernel, and split into some patches.
>>>   - Merge with memory subsystem (if it would be better), or
>>>     remove dependency on CONFIG_CGROUP_MEM_CONT if possible
>>>     (needs to make page_cgroup more generic one).
>> Merge is a must IMHO. I can hardly imagine a situation in which
>> someone would need these two separately.
> 
> Strongly agree.  Nobody's interested in swap as such: it's just
> secondary memory, where RAM is primary memory.  People want to
> control memory as the sum of the two; and I expect they may also
> want to control primary memory (all that the current memcg does)
> within that.  I wonder if such nesting of limits fits easily
> into cgroups or will be problematic.

This nesting would affect the res_couter abstraction, not the
cgroup infrastructure. Current design of resource counters doesn't
allow for such thing, but the extension is a couple-of-lines patch :)

> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
