Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Wed, 8 May 2002 18:06:37 +0200
References: <Pine.LNX.4.44L.0205081143091.32261-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0205081143091.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175Txf-0003o9-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Momchil Velikov <velco@fadata.bg>, William Lee Irwin III <wli@holomorphy.com>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 08 May 2002 16:43, Rik van Riel wrote:
> On Wed, 8 May 2002, Daniel Phillips wrote:
> 
> > To make this concrete, what would copy_page_range look like, using this
> > mechanism?
> 
> Or maybe copy_page_range should be behind this mechanism and
> modify the data structures directly ?

It already modifies the data structures directly.  You're proposing that 
copy_page_range should be per_arch?

> Remember that the goal is not to abstract out all of the VM,
> the goal is to make _most_ of the VM more readable and maintainable.

remap_page_range has the same problem.  So which of the bulk memory 
operations actually gets cleaner?

If the answer to 'can the proposed api handle copy_page_range?' is 'no', then 
it's not a very interesting api.  And by 'handling' I don't mean 'make it 
per-arch', that's going backwards.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
