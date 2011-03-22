Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF44C8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 23:13:14 -0400 (EDT)
Received: by gyg10 with SMTP id 10so2786648gyg.14
        for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:13:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110322085844.31041d40.kamezawa.hiroyu@jp.fujitsu.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-2-git-send-email-namhyung@gmail.com>
	<20110322085844.31041d40.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 22 Mar 2011 08:43:08 +0530
Message-ID: <AANLkTikDXLtGXmya72UL_hU2prKtaO3fNJ-ZpxssXXzJ@mail.gmail.com>
Subject: Re: [PATCH 2/3] memcg: fix off-by-one when calculating swap cgroup
 map length
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Namhyung Kim <namhyung@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 22, 2011 at 5:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 18 Mar 2011 21:54:14 +0900
> Namhyung Kim <namhyung@gmail.com> wrote:
>
>> It allocated one more page than necessary if @max_pages was
>> a multiple of SC_PER_PAGE.
>>
>> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
