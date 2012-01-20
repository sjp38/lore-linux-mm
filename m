Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2CF4F6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 17:12:34 -0500 (EST)
Date: Fri, 20 Jan 2012 14:12:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation
 library
Message-Id: <20120120141232.a7572919.akpm@linux-foundation.org>
In-Reply-To: <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon,  9 Jan 2012 16:51:56 -0600
Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> This patch creates a new memory allocation library named
> zsmalloc.

I haven't really begun to look at this yet.  The code is using many
fields of struct page in new ways.  This is key information for anyone
to effectively review the code.  So please carefully document (within
the code itself) the ways in which the various page fields are used:
semantic meaning of the overload, relationships between them, any
locking rules or assumptions.  Ditto any other data structures.  This
code should be reviewed very carefully by others so please implement it
with that intention.

It appears that a pile of dead code will be generated if CPU hotplug is
disabled.  (That's if it compiles at all!).  Please take a look at users
of hotcpu_notifier() - this facility cunningly causes all the hotplug code
to vanish from vmlinux if it is unneeded.


afacit this code should be added to core mm/.  Addition of code like
this to core mm/ will be fiercely resisted on principle!  Hence the
(currently missing) justifications for adding it had best be good ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
