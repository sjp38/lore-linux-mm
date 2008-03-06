Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m268qhTl016649
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 00:52:43 -0800
Received: from wr-out-0506.google.com (wra69.prod.google.com [10.54.1.69])
	by zps76.corp.google.com with ESMTP id m268qLv6004201
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 00:52:42 -0800
Received: by wr-out-0506.google.com with SMTP id 69so2689957wra.16
        for <linux-mm@kvack.org>; Thu, 06 Mar 2008 00:52:42 -0800 (PST)
Message-ID: <6599ad830803060052w32967983ifcf893063ce9a9be@mail.gmail.com>
Date: Thu, 6 Mar 2008 00:52:41 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [Devel] Re: [RFC/PATCH] cgroup swap subsystem
In-Reply-To: <47CFB065.3080200@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org>
	 <Pine.LNX.4.64.0803051400000.22243@blonde.site>
	 <47CEAAB4.8070208@openvz.org>
	 <20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <47CFA941.4070507@openvz.org>
	 <20080306173347.f6c5c84c.kamezawa.hiroyu@jp.fujitsu.com>
	 <47CFAD69.6000909@openvz.org>
	 <6599ad830803060048sb39735an765a62e6b928657e@mail.gmail.com>
	 <47CFB065.3080200@openvz.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, containers@lists.osdl.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 6, 2008 at 12:50 AM, Pavel Emelyanov <xemul@openvz.org> wrote:
>  > The change that you're referring to is allowing a cgroup to have a
>  > total memory limit for itself and all its children, and then giving
>  > that cgroup's children separate memory limits within that overall
>  > limit?
>
>  Yup. Isn't this reasonable?

Yes, sounds like a good plan.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
