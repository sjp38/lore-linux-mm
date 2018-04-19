Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0544C6B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:44:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q22so2878944pfh.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:43:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r14si3005833pgt.292.2018.04.19.07.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 07:43:58 -0700 (PDT)
Date: Thu, 19 Apr 2018 07:43:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419144356.GC25406@bombadil.infradead.org>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419143825.GA3519@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 10:38:25AM -0400, Jerome Glisse wrote:
> Oh can i get one more small slot for fs ? I want to ask if they are
> any people against having a callback everytime a struct file is added
> to a task_struct and also having a secondary array so that special
> file like device file can store something opaque per task_struct per
> struct file.

Do you really want something per _thread_, and not per _mm_?
