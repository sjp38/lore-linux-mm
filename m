Date: Thu, 19 Sep 2002 13:07:52 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: [Lse-tech] Rollup patch of basic rmap against 2.5.26
Message-ID: <20020919130752.I642@nightmaster.csn.tu-chemnitz.de>
References: <41260000.1032286918@baldur.austin.ibm.com> <3D879968.B346D1C7@digeo.com> <3D879BD1.D02F645E@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D879BD1.D02F645E@digeo.com>; from akpm@digeo.com on Tue, Sep 17, 2002 at 02:17:05PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Scalability Effort List <lse-tech@lists.sourceforge.net>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 17, 2002 at 02:17:05PM -0700, Andrew Morton wrote:
> rmap's overhead manifests with workloads which are setting
> up and tearing doen pagetables a lot.
> fork/exec/exit/pagefaults/munmap/etc.  I guess forking servers
> may hurt.

Hmm, so we gave up one of our advantages: fork() as fast as
thread creation in other OSes.

Or did someone benchmark shell script execution on 2.4.x, 2.5.x,
a later rmap-Kernel and compare that all with other Unices around?

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
