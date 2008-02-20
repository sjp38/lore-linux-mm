Date: Wed, 20 Feb 2008 04:39:47 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220133742.94a0b1b6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802200436380.7234@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802200355220.3569@blonde.site>
 <20080220133742.94a0b1b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 04:14:58 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > What's needed, I think, is something in struct mm, a flag or a reserved value
> > in mm->mem_cgroup, to say don't do any of this mem_cgroup stuff on me; and a cgroup
> > fs interface to set that, in the same way as force_empty is done.
> 
> I agree here. I believe we need "no charge" flag at least to the root group.
> For root group, it's better to have boot option if not complicated.

I expect we'll end up wanting both the cgroupfs interface and the boot
option for the root; but yes, for now, the boot option would be enough.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
