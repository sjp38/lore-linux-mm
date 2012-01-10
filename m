Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 388466B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 00:06:40 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2334302ghr.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 21:06:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120110120118.994b0bc4.kamezawa.hiroyu@jp.fujitsu.com>
References: <CAJd=RBBifQggNFtBsq0-Q_fG6mOJ-rJ544Me9pLFXbMi3Xn0gQ@mail.gmail.com>
 <20120110120118.994b0bc4.kamezawa.hiroyu@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 10 Jan 2012 00:06:18 -0500
Message-ID: <CAHGf_=rjpGWz=tcO0tcGYw9zETUoABbtYW5TXAV1XUx0t7dB8w@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: cleanup with s/reclaim_mode/isolate_mode/
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

2012/1/9 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> On Fri, 6 Jan 2012 22:01:03 +0800
> Hillf Danton <dhillf@gmail.com> wrote:
>
>> With tons of reclaim_mode(defined as one field of struct scan_control) already
>> in the file, it is clearer to rename it when setting up the isolation mode.
>>
>>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>
> I like this.
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'm ok too.
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
