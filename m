Date: Sun, 27 Feb 2005 12:21:05 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS
 cleanup
In-Reply-To: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
Message-ID: <Pine.LNX.4.61.0502271220210.19979@chimarrao.boston.redhat.com>
References: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: stone_wang@sohu.com
Cc: akpm@osdl.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 27 Feb 2005 stone_wang@sohu.com wrote:

> ulimit dont enforce RLIMIT_RSS now,while sys_setrlimit() pretend 
> it(RLIMIT_RSS) is enforced.
> 
> This may cause confusion to users, and may lead to un-guaranteed 
> dependence on "ulimit -m" to limit users/applications.
> 
> The patch fixed the problem. 

Some kernels do enforce the RSS rlimit.  Your patch could break
systems that have the RSS rlimit in their configuration files
because they used to run a kernel that enforces the RSS rlimit.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
