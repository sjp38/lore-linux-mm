Message-ID: <3D4A3002.FFED947E@zip.com.au>
Date: Fri, 02 Aug 2002 00:08:50 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: large page patch
References: <15690.9727.831144.67179@napali.hpl.hp.com> <868823061.1028244804@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: davidm@hpl.hp.com, "David S. Miller" <davem@redhat.com>, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >   DaveM>    In my opinion the proposed large-page patch addresses a
> >   DaveM> relatively pressing need for databases (primarily).
> >
> >   DaveM> Databases want large pages with IPC_SHM, how can this
> >   DaveM> special syscal hack address that?
> >
> > I believe the interface is OK in that regard.  AFAIK, Oracle is happy
> > with it.
> 
> Is Oracle now the world's only database? I think not.

Is a draft of Simon's patch available against 2.5?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
