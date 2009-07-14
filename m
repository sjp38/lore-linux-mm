Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05C366B005A
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 19:53:19 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n6E0KBc0000544
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 01:20:12 +0100
Received: from bwz10 (bwz10.prod.google.com [10.188.26.10])
	by wpaz5.hot.corp.google.com with ESMTP id n6E0K8av001970
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:20:09 -0700
Received: by bwz10 with SMTP id 10so2240305bwz.20
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:20:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	 <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
Date: Mon, 13 Jul 2009 17:20:08 -0700
Message-ID: <6599ad830907131720j4f7e1649y4866d2ddeae862c5@mail.gmail.com>
Subject: Re: [PATCH 0/2] Memory usage limit notification feature (v3)
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Vladislav Buzov <vbuzov@embeddedalley.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 5:16 PM, Vladislav
Buzov<vbuzov@embeddedalley.com> wrote:
>
> The following sequence of patches introduce memory usage limit notificati=
on
> capability to the Memory Controller cgroup.
>
> This is v3 of the implementation. The major difference between previous
> version is it is based on the the Resource Counter extension to notify th=
e
> Resource Controller when the resource usage achieves or exceeds a configu=
rable
> threshold.
>
> TODOs:
>
> 1. Another, more generic notification mechanism supporting different =A0e=
vents
> =A0 is preferred to use, rather than creating a dedicated file in the Mem=
ory
> =A0 Controller cgroup.

I think that defining the the more generic userspace-API portion of
this TODO should come *prior* to the new feature in this patch, even
if the kernel implementation isn't initially generic.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
