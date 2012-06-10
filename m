Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 1FFFE6B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 22:15:48 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4993652pbb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 19:15:47 -0700 (PDT)
Date: Sat, 9 Jun 2012 19:15:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oomkillers gone wild.
In-Reply-To: <alpine.LFD.2.02.1206082232570.3086@ionos>
Message-ID: <alpine.DEB.2.00.1206091914560.7832@chino.kir.corp.google.com>
References: <20120604152710.GA1710@redhat.com> <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com> <20120605174454.GA23867@redhat.com> <20120605185239.GA28172@redhat.com> <alpine.DEB.2.00.1206081256330.19054@chino.kir.corp.google.com>
 <alpine.LFD.2.02.1206082232570.3086@ionos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 8 Jun 2012, Thomas Gleixner wrote:

> > If we're leaking task_struct's, meaning that put_task_struct() isn't 
> > actually freeing them when the refcount goes to 0, then it's certainly not 
> > because of the oom killer which only sends a SIGKILL to the selected 
> > process.
> 
> I rather suspect, that this is a asymetry between get_ and
> put_task_struct and refcount just doesn't go to zero.
> 

We found an actual task_struct leak within put_task_struct() because of 
the free task notifiers during the 3.4 -rc cycle, so if kmemleak doesn't 
show anything then would it be possible to bisect the problem Dave?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
