Date: Thu, 6 Jan 2005 15:15:33 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page migration patchset
Message-ID: <20050106231533.GC9636@holomorphy.com>
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de> <20050106223046.GB9636@holomorphy.com> <20050106150842.27b4c97f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050106150842.27b4c97f.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@muc.de, stevel@mvista.com, hugh@veritas.com, raybry@sgi.com, clameter@sgi.com, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>> There is a relatively consistent pattern of my being steamrolled over
>> I'm rather sick of.

On Thu, Jan 06, 2005 at 03:08:42PM -0800, Andrew Morton wrote:
> That's news to me.
> I do recall some months ago that there were a whole bunch of patches doing
> a whole bunch of stuff and I was concerned that there was an absence of a
> central coordinating role.  But then everything went quiet.
> If you have time/inclination to marshall the hugetlb efforts then for
> heavens sake, send in a MAINTAINERS record and let's roll the sleeves up.


I'm being at least sometimes deferred to for hugetlb maintenance.
I also originally wrote the fs methods, and generally get stuck
working on it on a regular basis. So here is a MAINTAINERS entry
reflecting that.


Index: mm2-2.6.10/MAINTAINERS
===================================================================
--- mm2-2.6.10.orig/MAINTAINERS	2005-01-06 09:42:03.000000000 -0800
+++ mm2-2.6.10/MAINTAINERS	2005-01-06 15:10:53.586581112 -0800
@@ -979,6 +979,11 @@
 M:	oliver@neukum.name
 S:	Maintained
 
+HUGETLB FILESYSTEM
+P:	William Irwin
+M:	wli@holomorphy.com
+S:	Maintained
+
 I2C AND SENSORS DRIVERS
 P:	Greg Kroah-Hartman
 M:	greg@kroah.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
