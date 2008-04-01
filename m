Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m3166Eig025953
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 07:06:14 +0100
Received: from py-out-1112.google.com (pyef47.prod.google.com [10.34.157.47])
	by zps76.corp.google.com with ESMTP id m3166CGR008979
	for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:06:13 -0700
Received: by py-out-1112.google.com with SMTP id f47so2151790pye.8
        for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:06:12 -0700 (PDT)
Message-ID: <6599ad830803312306l59fabaa0o2f62feb0d59b2ce3@mail.gmail.com>
Date: Mon, 31 Mar 2008 23:06:12 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
In-Reply-To: <20080401060330.743815A02@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain>
	 <20080401060330.743815A02@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, Mar 31, 2008 at 11:03 PM, YAMAMOTO Takashi
<yamamoto@valinux.co.jp> wrote:
>
>  changing mm->owner without notifying controllers makes it difficult to use.
>  can you provide a notification mechanism?
>

Yes, I think that call will need to be in the task_lock() critical
section in which we update mm->owner.

Right now I think the only user that needs to be notified at that
point is Balbir's virtual address limits controller.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
