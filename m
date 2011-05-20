Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 469898D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:40:53 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2411607pwi.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 11:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
 <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com> <20110520153346.GA1843@barrios-desktop>
 <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com> <20110520161934.GA2386@barrios-desktop>
 <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 20 May 2011 14:40:29 -0400
Message-ID: <BANLkTinEuOHNxRNQGsZSug=MRL-hGN-rvg@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, May 20, 2011 at 2:09 PM, Andrew Lutomirski <luto@mit.edu> wrote:
> I just tested 2.6.38.6 with the attached patch. =A0It survived dirty_ram
> and test_mempressure without any problems other than slowness, but
> when I hit ctrl-c to stop test_mempressure, I got the attached oom.

Reproduced with CONFIG_CGROUP_MEM_RES_CTLR=3Dn.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
