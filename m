From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 2 Apr 2008 21:10:36 -0700
Message-ID: <6599ad830804022110h2090f3efg7c6173df8185679e@mail.gmail.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
	 <47F3D62E.4070808@linux.vnet.ibm.com>
	 <6599ad830804021253y6bf3b37y9bf1167b63c32e70@mail.gmail.com>
	 <47F4577E.5060905@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753123AbYDCELJ@vger.kernel.org>
In-Reply-To: <47F4577E.5060905@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 2, 2008 at 9:05 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I checked to see that cgroup_exit is called after mm_update_new_owner(). We call
>  mm_update_new_owner() from exit_mm(). I did not check for current->cgroups !=
>  new_owner->cgroups, since I did not want to limit the callbacks.

No cgroup subsystem should be concerned about mm ownership changes
between tasks in the same cgroup. So I think that's a valid and useful
optimization.

Paul
