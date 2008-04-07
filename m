From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [-mm] Disable the memory controller by default (v2)
Date: Mon, 7 Apr 2008 22:22:34 +0900
Message-ID: <2f11576a0804070622j5cb39f90pb3e190d6153a5439@mail.gmail.com>
References: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758683AbYDGNWq@vger.kernel.org>
In-Reply-To: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

>  Changelog v1
>
>  1. Split cgroup_disable into cgroup_disable and cgroup_enable
>  2. Remove cgroup_toggle
>
>  Due to the overhead of the memory controller. The
>  memory controller is now disabled by default. This patch adds cgroup_enable.
>
>  If everyone agrees on this approach and likes it, should we push this
>  into 2.6.25?

Acked-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
