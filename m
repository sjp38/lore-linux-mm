Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C3E56B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 12:34:33 -0400 (EDT)
Message-ID: <4CA21906.1080002@redhat.com>
Date: Tue, 28 Sep 2010 18:34:14 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com> <20100928151218.GJ14068@sgi.com>
In-Reply-To: <20100928151218.GJ14068@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

  On 09/28/2010 05:12 PM, Robin Holt wrote:
> >  Why not update sysfs directory creation to be fast, for example by
> >  using an rbtree instead of a linked list.  This fixes an
> >  implementation problem in the kernel instead of working around it
> >  and creating a new ABI.
>
> Because the old ABI creates 129,000+ entries inside
> /sys/devices/system/memory with their associated links from
> /sys/devices/system/node/node*/ back to those directory entries.
>
> Thankfully things like rpm, hald, and other miscellaneous commands scan
> that information.  On our 8 TB test machine, hald runs continuously
> following boot for nearly an hour mostly scanning useless information
> from /sys/

I see - so the problem wasn't just kernel internal; the ABI itself was 
unsuitable.  Too bad this wasn't considered at the time it was added.

(129k entries / 1 hour = 35 entries/sec; not very impressive)

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
