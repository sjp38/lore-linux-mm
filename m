Date: Mon, 2 Jun 2003 06:13:05 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Always passing mm and vma down (was: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race)
Message-ID: <20030602131305.GA1370@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20030530164150.A26766@us.ibm.com> <20030531104617.J672@nightmaster.csn.tu-chemnitz.de> <20030531234816.GB1408@us.ibm.com> <20030601122200.GB1455@x30.local> <20030601200056.GA1471@us.ibm.com> <1054542770.5187.1.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1054542770.5187.1.camel@laptop.fenrus.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com, pmckenne@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 02, 2003 at 10:32:50AM +0200, Arjan van de Ven wrote:
> On Sun, 2003-06-01 at 22:00, Paul E. McKenney wrote:
> > The immediate motivation is to avoid the race with zap_page_range()
> > when another node writes to the corresponding portion of the file,
> > similar to the situation with vmtruncate().  The thought was to
> > leverage locking within the distributed filesystem, but if the
> > race is solved locally, then, as you say, perhaps this is not 
> > necessary.
> 
> is said distributed filesystem open source by chance ?

At least one soon will be.

					Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
