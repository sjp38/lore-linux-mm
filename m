From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Mon, 2 Apr 2007 17:03:19 -0600
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704021703.19947.bjorn.helgaas@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Monday 02 April 2007 09:37, Christoph Lameter wrote:
> On Sun, 1 Apr 2007, Andi Kleen wrote:
> > Hmm, this means there is at least 2MB worth of struct page on every node?
> > Or do you have overlaps with other memory (I think you have)
> > In that case you have to handle the overlap in change_page_attr()
> 
> Correct. 2MB worth of struct page is 128 mb of memory. Are there nodes 
> with smaller amounts of memory?

Do you deal with max_addr= and mem=?

RHEL4 (2.6.9) blows up if max_addr= happens to leave you with CPU-only
nodes.  So hopefully you can deal with arbitrary-sized nodes caused by
max_addr= or mem=.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
