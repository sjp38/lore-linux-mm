Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D7C278D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 10:45:18 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p16Fj96p013090
	for <linux-mm@kvack.org>; Sun, 6 Feb 2011 07:45:09 -0800
Received: from qwe4 (qwe4.prod.google.com [10.241.194.4])
	by wpaz13.hot.corp.google.com with ESMTP id p16Fj5su024347
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 6 Feb 2011 07:45:08 -0800
Received: by qwe4 with SMTP id 4so3858171qwe.15
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 07:45:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110117191359.GI2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
Date: Sun, 6 Feb 2011 07:45:05 -0800
Message-ID: <AANLkTin9EwgBRbmrDGcOKV35Z62xHb_T9Z4XPVVgxsao@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Mon, Jan 17, 2011 at 11:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> on the MM summit, I would like to talk about the current state of
> memory control groups, the features and extensions that are currently
> being developed for it, and what their status is.
>
> I am especially interested in talking about the current runtime memory
> overhead memcg comes with (1% of ram) and what we can do to shrink it.
> [...]
> Would other people be interested in discussing this?

Well, YES :)

In addition to what you mentioned, I believe it would be possible to
avoid the duplication of global vs per-cgroup LRU lists. global
scanning would translate into proportional scanning of all per-cgroup
lists. If we could get that done, it would IMO become reasonable to
integrate back the remaining few page_cgroup fields into struct page
itself...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
