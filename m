Date: Sat, 7 Jul 2007 06:57:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070707065712.5abbbe43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<468B3EAA.9070905@yahoo.com.au>
	<20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
	<468C51A7.3070505@yahoo.com.au>
	<20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
	<468C634D.9050306@yahoo.com.au>
	<20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, Mike.stroya@hp.com, y-goto@jp.fujitsu.com, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 10:32:29 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> I am a bit worried about the performance impact of all this flushing? What 
> is the worst case scenario here?
> 

IMHO....
When a user set VM_EXEC to their anonymous memory intentionally and
does many page faults.

I myself don't think (file's) page cache flushing is not so heavy work because
PG_arch_1 guarantees that icache flushing occurs just once at the first 
read in the system.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
