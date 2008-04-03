From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v6)
Date: Thu, 3 Apr 2008 10:17:44 -0700
Message-ID: <6599ad830804031017m60dc5ca5sebaa434e5bde8633@mail.gmail.com>
References: <20080403073043.3563.63717.sendpatchset@localhost.localdomain>
	 <6599ad830804030845m71d56d88u3508a252fc134ba5@mail.gmail.com>
	 <47F5109D.8060606@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932451AbYDCRSe@vger.kernel.org>
In-Reply-To: <47F5109D.8060606@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 3, 2008 at 10:15 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  > Even better, maybe just pass in the relevant cgroup_subsys_state
>  > objects here, rather than the cgroup objects?
>  >
>
>  Is that better than passing the cgroups? All the callbacks I see usually pass
>  either task_struct or cgroup. Won't it be better, consistent use of API to pass
>  either of those?

I have a long term plan to try to divorce the subsystems from having
to worry too much about actual control groups where possible.

But I guess that for consistency with the current API, passing in the
cgroup is OK.

Paul
