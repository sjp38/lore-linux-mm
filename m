Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l7MJIEWs014964
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 12:18:14 -0700
Received: from wr-out-0506.google.com (wra70.prod.google.com [10.54.1.70])
	by zps38.corp.google.com with ESMTP id l7MJHL4I015464
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 12:18:04 -0700
Received: by wr-out-0506.google.com with SMTP id 70so201761wra
        for <linux-mm@kvack.org>; Wed, 22 Aug 2007 12:18:04 -0700 (PDT)
Message-ID: <6599ad830708221218t3c1eae51o1605f00b8f204b02@mail.gmail.com>
Date: Wed, 22 Aug 2007 12:18:03 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Memory controller Add Documentation
In-Reply-To: <20070822130612.18981.58696.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On 8/22/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>
>  Documentation/memcontrol.txt |  193 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 193 insertions(+)
>
> diff -puN /dev/null Documentation/memcontrol.txt
> --- /dev/null   2007-06-01 20:42:04.000000000 +0530
> +++ linux-2.6.23-rc2-mm2-balbir/Documentation/memcontrol.txt    2007-08-22 18:29:29.000000000 +0530
> @@ -0,0 +1,193 @@
> +Memory Controller
> +
> +0. Salient features
> +
> +a. Enable control of both RSS and Page Cache pages

s/RSS/anonymous/ (and generally throughout the document)? RSS can
include pages that are part of the page cache too.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
