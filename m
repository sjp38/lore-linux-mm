Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABB59000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 11:59:28 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p93FNel6007340
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 11:23:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p93FxLWW223958
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 11:59:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p93FxKLZ027615
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 11:59:21 -0400
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <863f8de5-a8e5-427d-a329-e69a5402f88a@default>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
	 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
	 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
	 <4E72284B.2040907@linux.vnet.ibm.com>
	 <075c4e4c-a22d-47d1-ae98-31839df6e722@default 4E725109.3010609@linux.vnet.ibm.com>
	 <863f8de5-a8e5-427d-a329-e69a5402f88a@default>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 Oct 2011 08:59:16 -0700
Message-ID: <1317657556.16137.696.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

Hi Dan/Nitin,

I've been reading through Seth's patches a bit and looking over the
locking in general.  I'm wondering why preempt_disable() is used so
heavily.  Preempt seems to be disabled for virtually all of zcache's
operations.  It seems a bit unorthodox, and I guess I'm anticipating the
future screams of the low-latency folks. :)

I think long-term it will hurt zcache's ability to move in to other
code.  Right now, it's pretty limited to being used in conjunction with
memory reclaim called from kswapd.  Seems like something we ought to add
to the TODO list before it escapes from staging/.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
