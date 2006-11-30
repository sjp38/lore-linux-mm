Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id kAUJ9RAs028172
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 11:09:28 -0800
Received: from ug-out-1314.google.com (ugn78.prod.google.com [10.66.14.78])
	by zps76.corp.google.com with ESMTP id kAUJ7wQM002865
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 11:09:23 -0800
Received: by ug-out-1314.google.com with SMTP id 78so2120800ugn
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 11:09:23 -0800 (PST)
Message-ID: <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
Date: Thu, 30 Nov 2006 11:09:23 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
	 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
	 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
	 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
	 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
	 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
	 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
>
> F.e. A page cache page may have mapcount == 0.

OK, I was thinking just about anon pages.

For pagecache pages, it's safe to access the mapping as long as we've
locked the page, even if mapcount is 0? So we don't have the same
races?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
