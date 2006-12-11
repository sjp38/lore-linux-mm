From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: Status of buffered write path (deadlock fixes)
Date: Mon, 11 Dec 2006 16:12:32 +0000
Message-ID: <1165853552.3752.1015.camel@quoit.chygwyn.com>
References: <45751712.80301@yahoo.com.au>
	 <20061207195518.GG4497@ca-server1.us.oracle.com>
	 <4578DBCA.30604@yahoo.com.au>
	 <20061208234852.GI4497@ca-server1.us.oracle.com>
	 <457D20AE.6040107@yahoo.com.au>  <457D7EBA.7070005@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <457D7EBA.7070005@yahoo.com.au>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-Id: linux-mm.kvack.org

Hi,

On Tue, 2006-12-12 at 02:52 +1100, Nick Piggin wrote:
> Nick Piggin wrote:
> > Mark Fasheh wrote:
> 
> >> ->commit_write() would probably do fine. Currently, block_prepare_write()
> >> uses it to know which buffers were newly allocated (the file system 
> >> specific
> >> get_block_t sets the bit after allocation). I think we could safely move
> >> the clearing of that bit to block_commit_write(), thus still allowing 
> >> us to
> >> detect and zero those blocks in generic_file_buffered_write()
> > 
> > 
> > OK, great, I'll make a few patches and see how they look. What did you
> > think of those other uninitialised buffer problems in my first email?
> 
> Hmm, doesn't look like we can do this either because at least GFS2
> uses BH_New for its own special things.
> 
What makes you say that? As far as I know we are not doing anything we
shouldn't with this flag, and if we are, then I'm quite happy to
consider fixing it up so that we don't,

Steve.


