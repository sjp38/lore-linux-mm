Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id mBA90i3K022883
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 01:00:44 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by wpaz5.hot.corp.google.com with ESMTP id mBA90gcb009402
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 01:00:43 -0800
Received: by rv-out-0506.google.com with SMTP id b25so348245rvf.39
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 01:00:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <62469.10.75.179.62.1228476245.squirrel@webmail-b.css.fujitsu.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081205172845.2b9d89a5.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812050139l5797f16kaf511f831b09e8f4@mail.gmail.com>
	 <62469.10.75.179.62.1228476245.squirrel@webmail-b.css.fujitsu.com>
Date: Wed, 10 Dec 2008 01:00:42 -0800
Message-ID: <6599ad830812100100i54132600he52504b4785542ec@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/4] New css->refcnt implementation.
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 5, 2008 at 3:24 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> The basic rule is that you're only supposed to increment the css
>> refcount if you have:
>>
>> - a reference to a task in the cgroup (that is pinned via task_lock()
>> so it can't be moved away)
>> or
>> - an existing reference to the css
>>
> My problem is that we can do css_get() after pre_destroy() and
> css's refcnt goes down to 0.

But where are you getting the reference from in order to do css_get()?
Which call in mem cgroup are you concerned about?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
