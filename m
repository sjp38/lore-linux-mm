Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 48EDA6B0032
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 14:19:15 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so137776veb.12
        for <linux-mm@kvack.org>; Thu, 12 Sep 2013 11:19:14 -0700 (PDT)
Message-ID: <523205A0.1000102@gmail.com>
Date: Thu, 12 Sep 2013 14:19:12 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com>
In-Reply-To: <52312EC1.8080300@asianux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@gmail.com

> BTW: in my opinion, within mpol_to_str(), the VM_BUG_ON() need be
> replaced by returning -EINVAL.

Nope. mpol_to_str() is not carefully designed since it was born. It
doesn't have a way to get proper buffer size. That said, the function
assume all caller know proper buffer size. So, just adding EINVAL
doesn't solve anything. we need to add a way to get proper buffer length
at least if we take your way. However it is overengineering because
current all caller doesn't need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
