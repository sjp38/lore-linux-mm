Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id E49FB9003CE
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 23:07:26 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so43607082qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:07:26 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id 143si4837114qhw.9.2015.07.01.20.07.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 20:07:26 -0700 (PDT)
Received: by qgii30 with SMTP id i30so27717132qgi.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:07:26 -0700 (PDT)
Date: Wed, 1 Jul 2015 23:07:23 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 45/51] writeback: implement wb_wait_for_single_work()
Message-ID: <20150702030723.GN26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-46-git-send-email-tj@kernel.org>
 <20150701190735.GI7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701190735.GI7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Wed, Jul 01, 2015 at 09:07:35PM +0200, Jan Kara wrote:
> I don't understand, why is the special handling with single_wait,
> single_done necessary. When we fail to allocate work and thus use the
> base_work for submission, we can still use the standard completion mechanism
> to wait for work to finish, can't we?

Indeed.  I'm not sure why I didn't do that.  I'll try.

> BTW: Again it would be easier for me to review this if the implementation
> of this function was in one patch with the use of it so that one can see
> how it gets used...

Same point on this one as before.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
