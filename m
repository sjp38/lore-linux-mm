Date: Sat, 28 Sep 2002 00:30:42 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.5.38-mm3
In-Reply-To: <20020927092020.GS3530@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0209280026100.32347-100000@montezuma.mastecende.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Sep 2002, William Lee Irwin III wrote:

> On Fri, Sep 27, 2002 at 01:57:43PM +0530, Dipankar Sarma wrote:
> > What application were you all running ?
> > Thanks
> 
> Basically, the workload on my "desktop" system consists of numerous ssh
> sessions in and out of the machine, half a dozen IRC clients, xmms,
> Mozilla, and X overhead.

That box is my development/main box, i run a lot of xterms, xmms, network 
applications (ssh, browsers, irc etc...). Heavy simulator usage (i believe 
thats where the poll stuff comes from, due to its virtual ethernet 
interface) all done in X and the box is also local NFS server for the 
various testboxes i have (heavy I/O, disk load) as well as kernel 
compiles.

	Zwane

--
function.linuxpower.ca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
