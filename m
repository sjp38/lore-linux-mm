From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Disable the memory controller by default
Date: Mon, 7 Apr 2008 10:48:23 -0700
Message-ID: <6599ad830804071048u5e0687dfy4313467fd95dab1c@mail.gmail.com>
References: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
	 <20080407120340.GB16647@one.firstfloor.org>
	 <47FA0D85.201@linux.vnet.ibm.com>
	 <2f11576a0804070516r185bff87t449c315bd7787c7e@mail.gmail.com>
	 <47FA10BB.9000305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753476AbYDGRs6@vger.kernel.org>
In-Reply-To: <47FA10BB.9000305@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Mon, Apr 7, 2008 at 5:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  No, it is not all bad. That can be done, but we need to guard against a usage like
>
>  cgroup_disable=memory cgroup_enable=memory
>
>  The user will probably get what he/she deserves for it.

I don't think we need to guard against that. It seems perfectly valid
to have a lilo config with

  append="cgroup_disable=memory"

and then want to boot with the memory controller enabled you can do

  lilo -R <image> cgroup_enable=memory

The kernel command line will then look like

  "... cgroup_disable=memory cgroup_enable=memory"

and the last switch should win.

Paul
