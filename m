Date: Fri, 27 Oct 2000 12:17:08 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page fault.
Message-ID: <20001027121708.K20050@redhat.com>
References: <Pine.LNX.4.21.0010261752510.15696-100000@duckman.distro.conectiva> <Pine.GSO.4.05.10010262213310.16485-100000@aa.eps.jhu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.05.10010262213310.16485-100000@aa.eps.jhu.edu>; from afei@jhu.edu on Thu, Oct 26, 2000 at 10:14:23PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: afei@jhu.edu
Cc: Rik van Riel <riel@conectiva.com.br>, "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 26, 2000 at 10:14:23PM -0400, afei@jhu.edu wrote:
> You are right. I misunderstood what he wants. To know when the pagefault
> occured, one simply can work on the pagefault handler. It is trivial.

Page faults already produce a SIGSEGV which gets passed a sigcontext
struct describing where the fault occurred.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
