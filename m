Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m2791oJY018137
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 01:01:50 -0800
Received: from py-out-1112.google.com (pycj37.prod.google.com [10.34.111.37])
	by zps37.corp.google.com with ESMTP id m2791nnw016492
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 01:01:49 -0800
Received: by py-out-1112.google.com with SMTP id j37so445167pyc.4
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 01:01:48 -0800 (PST)
Message-ID: <6599ad830803070101t18c4814jeabf9c8a10a35dc5@mail.gmail.com>
Date: Fri, 7 Mar 2008 01:01:48 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
In-Reply-To: <alpine.DEB.1.00.0803070055020.3470@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>
	 <47D0C76D.8050207@linux.vnet.ibm.com>
	 <alpine.DEB.1.00.0803062111560.26462@chino.kir.corp.google.com>
	 <6599ad830803070040i5e54f5f3u9b4c753ac5a87771@mail.gmail.com>
	 <alpine.DEB.1.00.0803070055020.3470@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 7, 2008 at 12:56 AM, David Rientjes <rientjes@google.com> wrote:
>
>  Ok, so the cgroup_disable= parameter should be a list of subsystem names
>  delimited by anything other than a space that the user wants disabled.
>  That makes more sense, thanks.
>

As the code stands now, it should be just a single name. Disabling
multiple subsystems requires multiple cgroup_disable= options.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
