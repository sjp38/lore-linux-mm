Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC608D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 23:10:53 -0400 (EDT)
Received: by yxt33 with SMTP id 33so3560667yxt.14
        for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:10:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110322085755.c4193fc1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<20110322085755.c4193fc1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 22 Mar 2011 08:40:51 +0530
Message-ID: <AANLkTikN4j2EJr+HGXtPeRDph+rB6XXNNq13dYTDMhJU@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg: mark init_section_page_cgroup() properly
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Namhyung Kim <namhyung@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 22, 2011 at 5:27 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 18 Mar 2011 21:54:13 +0900
> Namhyung Kim <namhyung@gmail.com> wrote:
>
>> The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
>> in FLATMEM") removes call to alloc_bootmem() in the function
>> so that it can be marked as __meminit to reduce memory usage
>> when MEMORY_HOTPLUG=n.
>>
>> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
