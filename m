Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D94716B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:01:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p89-v6so5046505pfj.12
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 16:01:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t62-v6si6199638pfd.133.2018.10.24.16.01.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 16:01:08 -0700 (PDT)
Date: Wed, 24 Oct 2018 16:01:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-Id: <20181024160106.29ff3877d06fa1de520cc48a@linux-foundation.org>
In-Reply-To: <20181019173538.590-1-urezki@gmail.com>
References: <20181019173538.590-1-urezki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Fri, 19 Oct 2018 19:35:36 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> improving vmalloc allocator

It's about time ;)

Are you aware of https://lwn.net/Articles/285341/ ?  If not, please do
take a look through Nick's work and see if there are any good things
there which can be borrowed.
