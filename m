Date: Wed, 22 Mar 2000 17:37:32 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322173732.E2850@redhat.com>
References: <20000321022937.B4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org> <20000322171045.D2850@redhat.com> <20000322183307.B7271@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322183307.B7271@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Wed, Mar 22, 2000 at 06:33:07PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 06:33:07PM +0100, Jamie Lokier wrote:
> 
> Fwiw, I don't think MADV_ZERO is particularly useful.
> You can just read /dev/zero over that memory range.

Exactly.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
