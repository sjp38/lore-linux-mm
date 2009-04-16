Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3782F5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 23:58:59 -0400 (EDT)
Received: by qyk13 with SMTP id 13so476683qyk.12
        for <linux-mm@kvack.org>; Wed, 15 Apr 2009 20:59:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090416015955.GB7082@balbir.in.ibm.com>
References: <20090415120510.GX7082@balbir.in.ibm.com>
	 <20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090416015955.GB7082@balbir.in.ibm.com>
Date: Thu, 16 Apr 2009 09:29:53 +0530
Message-ID: <344eb09a0904152059w1a0ecfa4l6ff8c5f2130680ba@mail.gmail.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
	controller (v2)
From: Bharata B Rao <bharata.rao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 16, 2009 at 7:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
>
> Feature: Add file RSS tracking per memory cgroup
>
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> Changelog v3 -> v2
> 1. Add corresponding put_cpu() for every get_cpu()
>
> Changelog v2 -> v1
>
> 1. Rename file_rss to mapped_file
> 2. Add hooks into mem_cgroup_move_account for updating MAPPED_FILE statis=
tics
> 3. Use a better name for the statistics routine.
>
>
> We currently don't track file RSS, the RSS we report is actually anon RSS=
.
> All the file mapped pages, come in through the page cache and get account=
ed
> there. This patch adds support for accounting file RSS pages. It should
>
> 1. Help improve the metrics reported by the memory resource controller
> 2. Will form the basis for a future shared memory accounting heuristic
> =A0 that has been proposed by Kamezawa.
>
> Unfortunately, we cannot rename the existing "rss" keyword used in memory=
.stat
> to "anon_rss". We however, add "mapped_file" data and hope to educate the=
 end
> user through documentation.
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Balbir, could you please also update the documentation with the
description about this new metric ?

Regards,
Bharata.
--=20
http://bharata.sulekha.com/blog/posts.htm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
