Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id kAUJr9ee031362
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 19:53:09 GMT
Received: from nf-out-0910.google.com (nfbx29.prod.google.com [10.48.100.29])
	by spaceape10.eur.corp.google.com with ESMTP id kAUJr7ZE027856
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 19:53:07 GMT
Received: by nf-out-0910.google.com with SMTP id x29so3596243nfb
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 11:53:07 -0800 (PST)
Message-ID: <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
Date: Thu, 30 Nov 2006 11:53:06 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <Pine.LNX.4.64.0611292015280.19628@schroedinger.engr.sgi.com>
	 <6599ad830611300245s5c0f40bdu4231832930e9c023@mail.gmail.com>
	 <20061130201232.7d5f5578.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830611300325h3269a185x5794b0c585d985c0@mail.gmail.com>
	 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
	 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
	 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
	 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
	 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Christoph Lameter <clameter@sgi.com> wrote:
>
> We have no problem with the page lock (you actually may not need any
> locking since there are no references remaining to the page). The trouble
> is that the vma may have vanished when we try to reestablish the pte.
>

Why is that a problem? If the vma has gone away, then there's no need
to reestablish the pte. And remove_file_migration_ptes() appears to be
adequately protected against races with unlink_file_vma() since they
both take i_mmap_sem.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
