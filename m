Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBC58E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:26:02 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a18so7852093pga.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 22:26:02 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p189si38899199pfb.0.2019.01.10.22.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 22:26:00 -0800 (PST)
Date: Fri, 11 Jan 2019 07:25:56 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 1/5] fs: kernfs: add poll file operation
Message-ID: <20190111062556.GA348@kroah.com>
References: <20190110220718.261134-1-surenb@google.com>
 <20190110220718.261134-2-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110220718.261134-2-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Thu, Jan 10, 2019 at 02:07:14PM -0800, Suren Baghdasaryan wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Kernfs has a standardized poll/notification mechanism for waking all
> pollers on all fds when a filesystem node changes. To allow polling
> for custom events, add a .poll callback that can override the default.
> 
> This is in preparation for pollable cgroup pressure files which have
> per-fd trigger configurations.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Reviewed-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
