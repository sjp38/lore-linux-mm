Date: Mon, 21 May 2007 15:28:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc] increase struct page size?!
Message-Id: <20070521152830.a844d7ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A017BCA67@scsmsx411.amr.corp.intel.com>
References: <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
	<617E1C2C70743745A92448908E030B2A017BCA67@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: clameter@sgi.com, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007 13:37:09 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> > I wonder if there are other uses for the free space?
> 
> 	unsigned long moreflags;
> 
> Nick and Hugh were just sparring over adding a couple (or perhaps 8)
> flag bits.  This would supply 64 new bits ... maybe that would keep
> them happy for a few more years.
> 
- page->zone 
  free some flags bits and makes page_zone() simple.
  and software (fake) zone for memory control can be added ?
or 

-page->some_memory_controler ?
(I don't know whether resource controller people want this or not.)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
