Subject: Re: PATCH: SHM Bug in Highmem machines
References: <ytt4s87tam1.fsf@vexeta.dc.fi.udc.es>
From: Christoph Rohland <cr@sap.com>
Date: 10 May 2000 13:17:28 +0200
In-Reply-To: "Juan J. Quintela"'s message of "10 May 2000 04:14:30 +0200"
Message-ID: <qwwr9balkmv.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi juan,


"Juan J. Quintela" <quintela@fi.udc.es> writes:
>         I think that SHM can't work in recent kernels, due to the fact 
> that We call prepare_highmem_swapout without locking the page (that is
> necesary with the new semantics).  If we don't do that change, the
> page returned by prepare_highmem_swapout will be already
> locked and our call to lock will sleep forever.
> 
> Later, Juan.
> 
> PD. Christoph, could you see if that helps your problems (you are the only
> person that I know that use highmem & shm).

Yes, your patch fixes the lockup.

Thanks
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
