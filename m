Date: Fri, 18 Aug 2000 12:50:23 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: filemap.c SMP bug in 2.4.0-test* (fwd)
Message-ID: <20000818125023.C6993@redhat.com>
References: <Pine.LNX.4.21.0008172017450.16454-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0008172017450.16454-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Aug 17, 2000 at 08:18:39PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 17, 2000 at 08:18:39PM -0300, Rik van Riel wrote:
> 
> it seems that Roger has done some deep puzzling today...
> I'm not sure if he found something or not, could somebody
> else with a more intimate knowledge of the source take a
> look at Roger's idea?

Yes, it looks correct --- read_swap_cache_async() should be using
__find_page_nolock, I think.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
