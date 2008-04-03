From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Thu, 3 Apr 2008 11:41:22 -0700
Message-ID: <6599ad830804031141o142bf8c2o1899ca78f8cd434a@mail.gmail.com>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain>
	 <6599ad830804031058l1e2a7ad9p56cff47dca738d79@mail.gmail.com>
	 <47F51DE7.7010204@linux.vnet.ibm.com>
	 <6599ad830804031122y3f6946fbp97dc18073bf02609@mail.gmail.com>
	 <47F5233F.1010108@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758988AbYDCSlu@vger.kernel.org>
In-Reply-To: <47F5233F.1010108@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 3, 2008 at 11:34 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  That is indeed quite bad. Do we have to retire the group_leader to init_css_set?
>  Can we not check for delay_group_leader() there?
>

That might have unintentded consequences, such as leaving a pid in the
cgroup that can't be moved (since it's PF_EXITING) but won't go away
until its threads have all exited.
Maybe that's OK if the other threads are guaranteed to have started
exiting by this point. We'd need some cleanup for when the group
leader finally did exit.

Paul
