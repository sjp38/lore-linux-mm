Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l66K6Z6r019139
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 16:06:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l66LABij554664
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 17:10:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l66LAA7A028884
	for <linux-mm@kvack.org>; Fri, 6 Jul 2007 17:10:10 -0400
Subject: Re: [-mm PATCH 1/8] Memory controller resource counters (v2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <468EAE3E.4050802@linux.vnet.ibm.com>
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop>
	 <20070706052043.11677.56208.sendpatchset@balbir-laptop>
	 <1183742642.10287.151.camel@localhost>
	 <468EAE3E.4050802@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Fri, 06 Jul 2007 14:10:05 -0700
Message-Id: <1183756205.10287.212.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-06 at 14:03 -0700, Balbir Singh wrote:
> 
> >> +ssize_t res_counter_read(struct res_counter *cnt, int member,
> >> +            const char __user *userbuf, size_t nbytes, loff_t
> *pos)
> >> +{
> >> +    unsigned long *val;
> >> +    char buf[64], *s;
> >> +
> >> +    s = buf;
> >> +    val = res_counter_member(cnt, member);
> >> +    s += sprintf(s, "%lu\n", *val);
> >> +    return simple_read_from_buffer((void __user *)userbuf, nbytes,
> >> +                    pos, buf, s - buf);
> >> +}
> > 
> > Why do we need that cast?  
> > 
> 
> u mean the __user? If I remember correctly it's a attribute for
> sparse.

The userbuf is already __user.  This just appears to be making a 'const
char *' into a 'void *'.  I wondered what the reason for that part is.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
