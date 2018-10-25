Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5567D6B0284
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:33:24 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id u21-v6so939291lfc.20
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:33:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h196-v6sor2519205lfe.38.2018.10.25.03.33.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 03:33:21 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Thu, 25 Oct 2018 12:33:12 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181025103312.5oamrqsrdseeatir@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181024160106.29ff3877d06fa1de520cc48a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024160106.29ff3877d06fa1de520cc48a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Wed, Oct 24, 2018 at 04:01:06PM -0700, Andrew Morton wrote:
> On Fri, 19 Oct 2018 19:35:36 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
> > improving vmalloc allocator
> 
> It's about time ;)
> 
> Are you aware of https://lwn.net/Articles/285341/ ?  If not, please do
> take a look through Nick's work and see if there are any good things
> there which can be borrowed.
> 
No, i have not known about that. I will go through that work to see if
there is something there!

Thanks :)

--
Vlad Rezki
