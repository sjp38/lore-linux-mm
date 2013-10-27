Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CEEE6B00DC
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 08:30:14 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so5294310pbc.24
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:30:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.133])
        by mx.google.com with SMTP id ru9si9371174pbc.78.2013.10.27.05.30.12
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 05:30:13 -0700 (PDT)
Received: by mail-qe0-f52.google.com with SMTP id w7so3349372qeb.25
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:30:11 -0700 (PDT)
Date: Sun, 27 Oct 2013 08:30:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131027123008.GJ14934@mtj.dyndns.org>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 21, 2013 at 04:58:11PM +0800, Wei Yang wrote:
> When a cpu belongs to a new group, there is no cpu has the same group id. This
> means it can be assigned a new group id without checking with every others.
> 
> This patch does this optimiztion.

Does this actually matter?  If so, it'd probably make a lot more sense
to start inner loop at @cpu + 1 so that it becomes O(N).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
