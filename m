Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l667Vp7Y316884
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 17:31:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l667Ck0M186948
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 17:12:49 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6679Aef023546
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 17:09:11 +1000
Message-ID: <468DEA8C.6090000@linux.vnet.ibm.com>
Date: Fri, 06 Jul 2007 00:09:00 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 0/8] Memory controller introduction (v2)
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop> <468DD969.1040104@linux.vnet.ibm.com>
In-Reply-To: <468DD969.1040104@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:

In mem_container_move_lists()

> +		/*
> +		 * Check if the meta page went away from under us
> +		 */
> +		if (!list_empty(&mp->list)

You'll need an extra brace here to get it compile.
I forgot to refpatch :(


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
