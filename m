Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9AB216B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 18:51:52 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3831376pbc.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 15:51:51 -0800 (PST)
Date: Fri, 24 Feb 2012 15:51:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <CAOJsxLHEAZbN-sPeJ10qAN-HVEj0Rq_RkLt0QCvZHhZitW+9pw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1202241550080.2401@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223150238.GA15427@dhcp231-144.rdu.redhat.com> <alpine.DEB.2.00.1202231505080.26362@chino.kir.corp.google.com> <20120224151025.GA1848@localhost.localdomain>
 <alpine.DEB.2.00.1202241342240.22880@chino.kir.corp.google.com> <CAOJsxLHEAZbN-sPeJ10qAN-HVEj0Rq_RkLt0QCvZHhZitW+9pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1208381419-1330127511=:2401"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Josef Bacik <josef@redhat.com>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1208381419-1330127511=:2401
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 24 Feb 2012, Pekka Enberg wrote:

> On Fri, 24 Feb 2012, Josef Bacik wrote:
> >> Um well yeah, I'm rewriting a chunk of btrfs which was rapantly leaking memory
> >> so the OOM just couldn't keep up with how much I was sucking down.  This is
> >> strictly a developer is doing something stupid and needs help pointing out what
> >> it is sort of moment, not a day to day OOM.
> 
> On Fri, Feb 24, 2012 at 11:45 PM, David Rientjes <rientjes@google.com> wrote:
> > If you're debugging new kernel code and you realize that excessive amount
> > of memory is being consumed so that nothing can even fork, you may want to
> > try cat /proc/slabinfo before you get into that condition the next time
> > around, although I already suspect that you know the cache you're leaking.
> > It doesn't mean we need to add hundreds of lines of code to the kernel.
> > Try kmemleak.
> 
> Kmemleak is a wonderful tool but it's also pretty heavy-weight which
> makes it inconvenient in many cases.
> 

Too heavyweight to enable when debugging issues after "rewriting a chunk" 
of a filesystem that manipulates kernel memory?  I can't imagine a better 
time to enable it.
--397155492-1208381419-1330127511=:2401--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
