Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m1K621Zj032298
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:02:01 -0800
Received: from py-out-1112.google.com (pyhf31.prod.google.com [10.34.233.31])
	by zps19.corp.google.com with ESMTP id m1K61muj018100
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:02:00 -0800
Received: by py-out-1112.google.com with SMTP id f31so2872783pyh.17
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:02:00 -0800 (PST)
Message-ID: <6599ad830802192202t19c1f597jb7927e975eb80aa6@mail.gmail.com>
Date: Tue, 19 Feb 2008 22:02:00 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 0/2] cgroup map files: Add a key/value map file type to cgroups
In-Reply-To: <20080220054809.86BFC1E3C58@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220051544.018684000@menage.corp.google.com>
	 <20080220054809.86BFC1E3C58@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 9:48 PM, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
>
> it changes the format from "%s %lld" to "%s: %llu", right?
> why?
>

The colon for consistency with maps in /proc. I think it also makes it
slightly more readable.

For %lld versus %llu - I think that cgroup resource APIs are much more
likely to need to report unsigned rather than signed values. In the
case of the memory.stat file, that's certainly the case.

But I guess there's an argument to be made that nothing's likely to
need the final 64th bit of an unsigned value, whereas the ability to
report negative numbers could potentially be useful for some cgroups.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
