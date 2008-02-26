Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m1Q8w7QH005303
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 00:58:07 -0800
Received: from py-out-1112.google.com (pyef47.prod.google.com [10.34.157.47])
	by zps19.corp.google.com with ESMTP id m1Q8w6p5011326
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 00:58:07 -0800
Received: by py-out-1112.google.com with SMTP id f47so2790693pye.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2008 00:58:06 -0800 (PST)
Message-ID: <6599ad830802260058m28d8f46djc83f47e19e2946a7@mail.gmail.com>
Date: Tue, 26 Feb 2008 00:58:06 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
In-Reply-To: <47C38127.2000109@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
	 <20080225115550.23920.43199.sendpatchset@localhost.localdomain>
	 <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>
	 <47C2F86A.9010709@linux.vnet.ibm.com>
	 <6599ad830802250932s5eaa3bcchbfc49fe0e76d3f7d@mail.gmail.com>
	 <47C2FCC1.7090203@linux.vnet.ibm.com> <47C30EDC.4060005@google.com>
	 <47C38127.2000109@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2008 at 7:01 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>  >
>  > - foo doesn't show up in /proc/cgroups
>
>  Or we can print out the disable flag, maybe this will be better?
>  Because we can distinguish from disabled and not compiled in from
>
> /proc/cgroups.

Certainly possible, if people felt it was useful.

>
>  > - foo isn't auto-mounted if you mount all cgroups in a single hierarchy
>  > - foo isn't visible as an individually mountable subsystem
>
>  You mentioned in a previous mail if we mount a disabled subsystem we
>  will get an error. Here we just ignore the mount option. Which makes
>  more sense ?
>

No, we don't ignore the mount option - we give an error since it
doesn't refer to a valid subsystem. (And in the first case there is no
mount option).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
