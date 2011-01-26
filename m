Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2076B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 08:40:37 -0500 (EST)
Received: by pvc30 with SMTP id 30so75306pvc.14
        for <linux-mm@kvack.org>; Wed, 26 Jan 2011 05:40:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296030555-3594-1-git-send-email-gthelen@google.com>
References: <1296030555-3594-1-git-send-email-gthelen@google.com>
Date: Wed, 26 Jan 2011 19:10:34 +0530
Message-ID: <AANLkTikZwbmVr-jvOoyd0WZhfxtHvqK=n1B-zWLr3xDa@mail.gmail.com>
Subject: Re: [PATCH] oom: handle overflow in mem_cgroup_out_of_memory()
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 1:59 PM, Greg Thelen <gthelen@google.com> wrote:
> mem_cgroup_get_limit() returns a byte limit as a unsigned 64 bit value,
> which is converted to a page count by mem_cgroup_out_of_memory(). =A0Prio=
r
> to this patch the conversion could overflow on 32 bit platforms
> yielding a limit of zero.
>

Why would the overflow occur? Due to the right shift being used with
unsigned long long? I am afraid I don't have quick access to a 32 bit
box to test the patch. May be I too drained to understand the problem,
can you post the corresponding assembly for analysis?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
