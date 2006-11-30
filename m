Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id kAUIa043015994
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 10:36:00 -0800
Received: from nf-out-0910.google.com (nfcm19.prod.google.com [10.48.114.19])
	by zps75.corp.google.com with ESMTP id kAUIYenP005280
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 10:35:50 -0800
Received: by nf-out-0910.google.com with SMTP id m19so3169142nfc
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 10:35:45 -0800 (PST)
Message-ID: <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
Date: Thu, 30 Nov 2006 10:35:44 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Thu, 30 Nov 2006, Paul Menage wrote:
>
> > OK, so we could do the same, and just assume that pages with a
> > page_mapcount() of 0 are either about to be freed or can be picked up
> > on a later migration sweep. Is it common for a page to have a 0
> > page_mapcount() for a long period of time without being freed or
> > remapped?
>
> page mapcount goes to zero during migration because the references to the
> page are removed.
>

Yes, but I meant for reasons other than migration.

It sounds as though if we come across a page with page_mapcount() = 0
while gathering pages for migration, it's probably in the process of
being swapped out and so is best not to muck around with anyway?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
