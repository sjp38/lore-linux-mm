Date: Fri, 26 May 2000 18:46:00 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526184600.T10082@redhat.com>
References: <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com> <200005261655.JAA90389@apollo.backplane.com> <20000526190555.B21856@pcep-jamie.cern.ch> <200005261735.KAA90570@apollo.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200005261735.KAA90570@apollo.backplane.com>; from dillon@apollo.backplane.com on Fri, May 26, 2000 at 10:35:30AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 26, 2000 at 10:35:30AM -0700, Matthew Dillon wrote:
> 
>     Hmm.  I know apps which use madvise() to manage allocated/free pages
>     efficiently, but not any that use mprotect().

Persistent and distributed data stores use it to mark existing
pages as PROT_NONE, so that they can trap accesses to the data
and perform the necessary locking to make the local storage
consistent with the on-disk data (persistent object stores) or
with other machines in the cluster (for distributed shared 
memory).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
