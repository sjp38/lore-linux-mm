Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m2B9BorG019003
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:11:50 -0700
Received: from py-out-1112.google.com (pycj37.prod.google.com [10.34.111.37])
	by zps35.corp.google.com with ESMTP id m2B9BD4B019808
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:11:49 -0700
Received: by py-out-1112.google.com with SMTP id j37so2239081pyc.4
        for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:11:49 -0700 (PDT)
Message-ID: <6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com>
Date: Tue, 11 Mar 2008 02:11:49 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
In-Reply-To: <20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47D16004.7050204@openvz.org>
	 <20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <47D63FBC.1010805@openvz.org>
	 <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
	 <20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 11, 2008 at 2:13 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  or remove all relationship among counters of *different* type of resources.
>  user-land-daemon will do enough jobs.
>

Yes, that would be my preferred choice, if people agree that
hierarchically limiting overall virtual memory isn't useful. (I don't
think I have a use for it myself).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
