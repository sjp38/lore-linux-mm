Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1EEF96B0149
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 15:53:50 -0400 (EDT)
Date: Tue, 26 Mar 2013 15:53:44 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: BUG at kmem_cache_alloc
Message-ID: <20130326195344.GA1578@redhat.com>
References: <0000013da2b53120-1c207286-3e36-483e-9fd9-90fc529d48aa-000000@email.amazonses.com>
 <1122269504.6445741.1364290347815.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1122269504.6445741.1364290347815.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

On Tue, Mar 26, 2013 at 05:32:27AM -0400, CAI Qian wrote:

 > Still running and will update ASAP. One thing I noticed was that trinity
 > threw out this error before the kernel crash.
 > 
 > BUG!:       
 > CHILD (pid:28825) GOT REPARENTED! parent pid:19380. Watchdog pid:19379 
 >       
 > BUG!:       
 > Last syscalls: 
 > [0]  pid:28515 call:settimeofday callno:10356 
 > [1]  pid:28822 call:setgid callno:322 
 > [2]  pid:28581 call:init_module callno:3622 
 > [3]  pid:28825 call:readlinkat callno:403 
 > child 28581 exiting 
 > child 28515 exiting 
 >  ...killed. 

When this happens, it usually means that the parent segfaulted.
I've been trying to reproduce a few reports of this for a while
without success.  If you get time, running trinity inside gdb should
be enough to get a useful backtrace.

(Or run with -D, and collect coredumps [there will a lot], and match the
 core to the pid of the process we're interested in)

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
