Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m99GokI1030936
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 12:50:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m99Gog5h238354
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 12:50:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m99Gofjb001262
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 12:50:42 -0400
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081009134415.GA12135@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	 <20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>
	 <20081009134415.GA12135@elte.hu>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 09:50:36 -0700
Message-Id: <1223571036.11830.32.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 15:44 +0200, Ingo Molnar wrote:
> there might be races as well, especially with proxy state - and 
> current->flags updates are not serialized.
> 
> So maybe it should be a completely separate flag after all? Stick it 
> into the end of task_struct perhaps.

What do you mean by proxy state?  nsproxy?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
