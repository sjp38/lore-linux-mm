Date: Tue, 2 May 2000 23:34:39 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
Message-ID: <20000502233439.A10012@redhat.com>
References: <20000502221405.O1389@redhat.com> <Pine.LNX.4.21.0005021837080.10610-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005021837080.10610-100000@duckman.conectiva>; from riel@conectiva.com.br on Tue, May 02, 2000 at 06:42:31PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 02, 2000 at 06:42:31PM -0300, Rik van Riel wrote:
> On Tue, 2 May 2000, Stephen C. Tweedie wrote:
> Ermmm, a few days ago (yesterday?) you told me on irc that we
> needed to balance between zones ... 

On a single NUMA node, definitely.  We need balance between all of
the zones which may be in use in a specific allocation class.

NUMA is a very different issue.  _Some_ memory pressure between nodes is
necessary: if one node is completely out of memory then we may have to 
start allocating memory on other nodes to tasks tied to the node under
pressure.  But in the normal case, you really do want NUMA memory classes
to be as independent of each other as possible.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
