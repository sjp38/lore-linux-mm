Date: Fri, 13 Jul 2007 15:42:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
In-Reply-To: <20070713235121.538ddcaf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0707131541540.26109@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky> <E1I9LJY-00006o-GK@hellhawk.shadowen.org>
 <20070713235121.538ddcaf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, npiggin@suse.de, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, KAMEZAWA Hiroyuki wrote:

> On Fri, 13 Jul 2007 14:36:08 +0100
> Andy Whitcroft <apw@shadowen.org> wrote:
> 
> > SPARSEMEM is a pretty nice framework that unifies quite a bit of
> > code over all the arches. It would be great if it could be the
> > default so that we can get rid of various forms of DISCONTIG and
> > other variations on memory maps. So far what has hindered this are
> > the additional lookups that SPARSEMEM introduces for virt_to_page
> > and page_address. This goes so far that the code to do this has to
> > be kept in a separate function and cannot be used inline.
> > 
> Maybe it will be our(my or Goto-san's) work to implement MEMORY_HOTADD support
> for this. Could you add !MEMORY_HOTPLUG in Kconfig ? Then, we'll write
> patch later.
> Or..If you'll add memory hotplug support by yourself, It's great, 

Why would hotadd not work as is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
