Date: Tue, 10 Apr 2007 14:42:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
Message-Id: <20070410144249.b0e70a67.akpm@linux-foundation.org>
In-Reply-To: <20070410204711.GB1283@redhat.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
	<20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
	<20070410133137.e366a16b.akpm@linux-foundation.org>
	<20070410204711.GB1283@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007 16:47:11 -0400
Dave Jones <davej@redhat.com> wrote:

> On Tue, Apr 10, 2007 at 01:31:37PM -0700, Andrew Morton wrote:
>  
>  > > an object have not been compromised.
>  > > 
>  > > A single slabcache can be checked by writing a 1 to the "validate" file.
>  > > 
>  > > i.e.
>  > > 
>  > > echo 1 >/sys/slab/kmalloc-128/validate
>  > > 
>  > > or use the slabinfo tool to check all slabs
>  > > 
>  > > slabinfo -v
>  > > 
>  > > Error messages will show up in the syslog.
>  > 
>  > Neato.
> 
> I had a patch (I think originally from Manfred Spraul) that I carried
> in Fedora for a while which this patch reminded me of.
> Instead of a /sys file however, it ran off a timer every few
> minutes to check redzones of unfreed objects.

yup.  Of course, that can be done with a cronjob with slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
