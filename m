Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 222B86B0085
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 08:35:49 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1268249pab.0
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:35:48 -0700 (PDT)
Received: from psmtp.com ([74.125.245.157])
        by mx.google.com with SMTP id ei3si9364201pbc.170.2013.10.27.05.35.47
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 05:35:48 -0700 (PDT)
Received: by mail-qe0-f48.google.com with SMTP id d4so3430213qej.35
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:35:46 -0700 (PDT)
Date: Sun, 27 Oct 2013 08:35:42 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] percpu: merge two loops when setting up group info
Message-ID: <20131027123542.GK14934@mtj.dyndns.org>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1382345893-6644-2-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382345893-6644-2-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 21, 2013 at 04:58:12PM +0800, Wei Yang wrote:
> There are two loops setting up the group info of pcpu_alloc_info. They share
> the same logic, so merge them could be time efficient when there are many
> groups.
> 
> This patch merge these two loops into one.

It *looks* correct to me but I'd rather not change this unless you can
show me this actually matters, which I find extremely doubtful given
nr_groups would be in the order of few thousands even on an extremely
large machine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
