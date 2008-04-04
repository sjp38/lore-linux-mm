From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [-mm] Make the memory controller more desktop responsive (v2)
Date: Fri, 4 Apr 2008 23:02:51 +0900
Message-ID: <2f11576a0804040702j854653ble14fe655d25b922f@mail.gmail.com>
References: <20080404132116.5217.14401.sendpatchset@localhost.localdomain>
	 <2f11576a0804040701s5b6267b0w430c29b5010bf841@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758606AbYDDODL@vger.kernel.org>
In-Reply-To: <2f11576a0804040701s5b6267b0w430c29b5010bf841@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Fri, Apr 4, 2008 at 11:01 PM, KOSAKI Motohiro
<m-kosaki@ceres.dti.ne.jp> wrote:
> Hi
>
>
>  >  @@ -612,7 +611,7 @@ retry:
>  >         pc->page = page;
>  >         pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
>  >         if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
>  >  -               pc->flags |= PAGE_CGROUP_FLAG_CACHE;
>  >  +               pc->flags = PAGE_CGROUP_FLAG_CACHE;
>  >
>  >         lock_page_cgroup(page);
>  >         if (page_get_page_cgroup(page)) {
>
>  Yes.
>  in general, cache page create as cold page.
>  if not, large file copy or streaming file drop all cache easily.
>
>  Reviewd-by: KOSAKI

sorry, I sent premature document.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
