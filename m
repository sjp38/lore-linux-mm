Date: Thu, 8 Jun 2000 20:04:58 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Heard about the 2Q algorithm?
Message-ID: <20000608200458.P3886@redhat.com>
References: <20000608175632.19821.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608175632.19821.qmail@science.horizon.com>; from linux@horizon.com on Thu, Jun 08, 2000 at 05:56:32PM -0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux@horizon.com
Cc: riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 05:56:32PM -0000, linux@horizon.com wrote:
> 
> 
> The idea is that the FIFO absorbs sequential scans and filters out the
> initial burst of accesses.  Only if access to the page is *prolonged*
> do we consider it for longer-term cacheing.

Page aging does that.  The initial age of a page will be fairly low,
relative to pages which are constantly being accessed, and so will 
be evicted from the cache before they can accumulate a high age if we
have a sequential access pattern.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
