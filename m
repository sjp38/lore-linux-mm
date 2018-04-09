Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA9B26B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:40:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so5582590pfi.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:40:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si871002plq.547.2018.04.09.13.40.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 13:40:02 -0700 (PDT)
Date: Mon, 9 Apr 2018 13:26:41 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180409202641.j773oepagmhcb2nh@linux-n805>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
 <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
 <20180409185016.GA203367@gmail.com>
 <20180409201232.3rweldbjtvxjj5ql@linux-n805>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180409201232.3rweldbjtvxjj5ql@linux-n805>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Mon, 09 Apr 2018, Davidlohr Bueso wrote:
>So I don't think the pointer is going anywhere, or am I missing
>something?

Ah, yes, wrong pointer, this is sdf->file -- sorry for the noise.
