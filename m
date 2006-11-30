Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id kAU0VOiW015718
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 00:31:24 GMT
Received: from ug-out-1314.google.com (ugf39.prod.google.com [10.66.6.39])
	by spaceape14.eur.corp.google.com with ESMTP id kAU0UCce012726
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 00:31:23 GMT
Received: by ug-out-1314.google.com with SMTP id 39so3612068ugf
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 16:31:23 -0800 (PST)
Message-ID: <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
Date: Wed, 29 Nov 2006 16:31:22 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/29/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> 2. AFAIK, migrating pages without taking write lock of any mm->sem will
>    cause problem. anon_vma can be freed while migration.

Hmm, isn't migration just analagous to swapping out and swapping back
in again, but without the actual swapping?

If what you describe is a problem, then wouldn't you have a problem if
you were doing migration on a particular mm structure, but it was
sharing pages with another mm?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
