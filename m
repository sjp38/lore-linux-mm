Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC476007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 17:48:13 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id nB2Mm83k003464
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 14:48:08 -0800
Received: from pwi19 (pwi19.prod.google.com [10.241.219.19])
	by zps38.corp.google.com with ESMTP id nB2Mlj5g000557
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 14:48:06 -0800
Received: by pwi19 with SMTP id 19so521592pwi.9
        for <linux-mm@kvack.org>; Wed, 02 Dec 2009 14:48:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091202043046.420815285@intel.com>
References: <20091202031231.735876003@intel.com>
	 <20091202043046.420815285@intel.com>
Date: Wed, 2 Dec 2009 14:48:03 -0800
Message-ID: <6599ad830912021448h6f939623y43fbe5fde2c36b85@mail.gmail.com>
Subject: Re: [PATCH 21/24] cgroup: define empty css_put() when !CONFIG_CGROUPS
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 1, 2009 at 7:12 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> --- linux-mm.orig/include/linux/cgroup.h =A0 =A0 =A0 =A02009-11-02 10:18:=
41.000000000 +0800
> +++ linux-mm/include/linux/cgroup.h =A0 =A0 2009-11-02 10:26:22.000000000=
 +0800
> @@ -581,6 +581,9 @@ static inline int cgroupstats_build(stru
> =A0 =A0 =A0 =A0return -EINVAL;
> =A0}
>
> +struct cgroup_subsys_state;
> +static inline void css_put(struct cgroup_subsys_state *css) {}
> +
> =A0#endif /* !CONFIG_CGROUPS */

This doesn't sound like the right thing to do - if !CONFIG_CGROUPS,
then the code shouldn't be able to see a css structure to pass to this
function.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
