Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9RGgaPB021507
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:42:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RGgZZG130654
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:42:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RGgZb5027556
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:42:35 -0400
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <49059FED.4030202@cs.columbia.edu>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	 <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	 <20081021124130.a002e838.akpm@linux-foundation.org>
	 <20081021202410.GA10423@us.ibm.com>	<48FE82DF.6030005@cs.columbia.edu>
	 <20081022152804.GA23821@us.ibm.com>	<48FF4EB2.5060206@cs.columbia.edu>
	 <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu>
Content-Type: text/plain
Date: Mon, 27 Oct 2008 09:42:32 -0700
Message-Id: <1225125752.12673.79.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-27 at 07:03 -0400, Oren Laadan wrote:
> > In our implementation, we simply refused to checkpoint setid
> programs.
> 
> True. And this works very well for HPC applications.
> 
> However, it doesn't work so well for server applications, for
> instance.
> 
> Also, you could use file system snapshotting to ensure that the file
> system view does not change, and still face the same issue.
> 
> So I'm perfectly ok with deferring this discussion to a later time :)

Oren, is this a good place to stick a process_deny_checkpoint()?  Both
so we refuse to checkpoint, and document this as something that has to
be addressed later?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
