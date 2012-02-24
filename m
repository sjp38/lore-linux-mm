Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4BD426B007E
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 09:51:20 -0500 (EST)
Received: by qauh8 with SMTP id h8so343832qau.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 06:51:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
	<CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
	<4F468888.9090702@fb.com>
	<20120224114748.720ee79a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 24 Feb 2012 20:21:18 +0530
Message-ID: <CAKTCnzk7TgDeYRZK0rCugopq0tO7BtM8jM9U0RJUTqNtz42ZKw@mail.gmail.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Feb 24, 2012 at 8:17 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> They don't have access to each other's VMAs, but if "accidentally" one
>> of them comes across an uninitialized page with data from another task,
>> it's not a violation of the security model.

Can you expand more on the single address space model?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
