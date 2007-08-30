Date: Thu, 30 Aug 2007 12:11:10 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC:PATCH 00/07] VM File Tails
Message-ID: <20070830101108.GD29635@lazybastard.org>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com> <20070829213154.GB29635@lazybastard.org> <1188423942.6529.74.camel@norville.austin.ibm.com> <20070829233802.GC29635@lazybastard.org> <1188440111.9221.3.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1188440111.9221.3.camel@norville.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 August 2007 21:15:11 -0500, Dave Kleikamp wrote:
> 
> Once the data is packed into the tail, the page is freed.  Later if the
> page is needed, a new page is allocated and the tail is unpacked into
> it.  Then the tail is freed (via kfree).
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Good.  That part had evaded me.

JA?rn

-- 
There are three principal ways to lose money: wine, women, and engineers.
While the first two are more pleasant, the third is by far the more certain.
-- Baron Rothschild

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
