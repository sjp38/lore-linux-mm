Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 926376B00D1
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 08:36:54 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so4158076pad.41
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:36:54 -0700 (PDT)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id js8si9377472pbc.104.2013.10.27.05.36.53
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 05:36:53 -0700 (PDT)
Received: by mail-qe0-f53.google.com with SMTP id cy11so3389410qeb.12
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:36:51 -0700 (PDT)
Date: Sun, 27 Oct 2013 08:36:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] percpu: little optimization on calculating
 pcpu_unit_size
Message-ID: <20131027123634.GL14934@mtj.dyndns.org>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1382345893-6644-3-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382345893-6644-3-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 21, 2013 at 04:58:13PM +0800, Wei Yang wrote:
> pcpu_unit_size exactly equals to ai->unit_size.
> 
> This patch assign this value instead of calculating from pcpu_unit_pages. Also
> it reorder them to make it looks more friendly to audience.

Ditto.  I'd rather not change unless this is clearly better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
